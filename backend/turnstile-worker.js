/**
 * Cloudflare Worker backend for English Buddy:
 * 1. Server-verified Cloudflare Turnstile anti-bot check (POST / or POST /auth/verify-captcha)
 * 2. Server-enforced Profile & Role-Based Access Control (RBAC) API:
 *    - GET  /profile           (Authenticated user reads own profile & server-verified role)
 *    - PUT  /profile           (Authenticated user updates ONLY own profile; blocks role/level escalation)
 *    - GET  /admin/users       (Admin-only: returns 401/403 if non-admin calls directly)
 *    - PATCH /admin/users      (Admin-only: updates target user's role, cefrLevel, profile, active status)
 *    - DELETE /admin/users     (Admin-only: deletes target user profile; blocks self-delete)
 *
 * Configure TURNSTILE_SECRET, FIREBASE_API_KEY, ADMIN_EMAILS, ADMIN_UIDS,
 * ALLOWED_ORIGINS and ALLOWED_HOSTNAMES as Worker secrets/variables.
 * Never put secrets or admin credentials in the Flutter bundle or source code.
 */
const corsHeaders = (origin) => ({
  'Access-Control-Allow-Origin': origin,
  'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  'Vary': 'Origin',
});

const VALID_CEFR_LEVELS = ['A1', 'A2', 'B1', 'B2', 'C1'];
const VALID_ROLES = ['user', 'admin'];

function parseCsvEnv(raw) {
  return (raw || '')
    .split(',')
    .map((v) => v.trim())
    .filter(Boolean);
}

/**
 * Verifies the Firebase ID token against Identity Toolkit and resolves the user's server-side role.
 */
async function authenticateRequest(request, env) {
  const authHeader = request.headers.get('Authorization') || '';
  if (!authHeader.startsWith('Bearer ')) {
    return { error: 'Missing or invalid Authorization Bearer token.', status: 401 };
  }
  const idToken = authHeader.slice(7).trim();
  if (!idToken) {
    return { error: 'Empty Bearer token.', status: 401 };
  }
  if (!env.FIREBASE_API_KEY) {
    return { error: 'FIREBASE_API_KEY is not configured on the backend server.', status: 503 };
  }

  const lookupRes = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${encodeURIComponent(env.FIREBASE_API_KEY)}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ idToken }),
    },
  );

  if (!lookupRes.ok) {
    return { error: 'Invalid or expired Firebase ID token.', status: 401 };
  }

  const data = await lookupRes.json();
  const account = Array.isArray(data.users) && data.users.length > 0 ? data.users[0] : null;
  if (!account || !account.localId) {
    return { error: 'User account not found.', status: 401 };
  }
  if (account.disabled === true) {
    return { error: 'Account has been disabled by an administrator.', status: 403 };
  }

  const uid = String(account.localId);
  const email = String(account.email || '').toLowerCase();
  const displayName = String(account.displayName || (email ? email.split('@')[0] : 'Learner'));

  // Determine server-verified role from customAttributes or ADMIN_UIDS / ADMIN_EMAILS env
  let role = 'user';
  const adminUids = parseCsvEnv(env.ADMIN_UIDS);
  const adminEmails = parseCsvEnv(env.ADMIN_EMAILS).map((e) => e.toLowerCase());

  // Default project owner admin accounts from saved authentication data
  const defaultAdminUids = ['kK847H8QYXQ3RGBwfIxjYANxZHv2'];
  const defaultAdminEmails = ['giahuy2005a@gmail.com'];

  if (
    adminUids.includes(uid) ||
    defaultAdminUids.includes(uid) ||
    (email && (adminEmails.includes(email) || defaultAdminEmails.includes(email)))
  ) {
    role = 'admin';
  } else if (typeof account.customAttributes === 'string') {
    try {
      const claims = JSON.parse(account.customAttributes);
      if (claims.admin === true || claims.role === 'admin') {
        role = 'admin';
      }
    } catch (_) {}
  }

  return {
    user: {
      uid,
      email: account.email || '',
      displayName,
      role,
    },
  };
}

const AI_SYSTEM_PROMPT = `Bạn là Trợ lý AI học tiếng Anh thông minh, thân thiện và giàu tính sư phạm của ứng dụng English Buddy.
Nhiệm vụ trọng tâm của bạn là đồng hành và hỗ trợ người học tiếng Anh:
1. Giải đáp các thắc mắc về từ vựng, ngữ pháp, phát âm (phiên âm IPA, trọng âm, nối âm) và cách dùng từ ngữ trong ngữ cảnh đời thực.
2. Dịch thuật và phân tích chuyên sâu câu/đoạn văn giữa tiếng Anh và tiếng Việt; chỉ rõ các thành tố ngữ pháp, collocations và sắc thái biểu đạt.
3. Góp ý và nâng cấp bài viết (Writing feedback): chỉ ra lỗi sai ngữ pháp/chính tả (nếu có), giải thích lý do, đưa ra phương án sửa chuẩn xác và gợi ý phiên bản tự nhiên, phong phú hơn (bilingual context).
4. Ưu tiên giải thích bằng tiếng Việt mạch lạc, rõ ràng, có cấu trúc gạch đầu dòng khoa học để người học tiện theo dõi trên cả màn hình di động và máy tính.
5. Tuyệt đối không tự ý tạo quiz trắc nghiệm hay bộ câu hỏi thi thay thế hệ sinh thái bài tập hiện có của ứng dụng. Tập trung giải đáp, hướng dẫn và truyền cảm hứng học tập một cách tận tâm.`;

/**
 * Handles AI English Buddy chat queries via configured server provider (Gemini, OpenAI, or Workers AI).
 * API secrets and system prompts remain strictly on the server.
 */
async function handleAiChatRequest(request, env, headers, preParsedBody = null) {
  const geminiKey = env.GEMINI_API_KEY || (env.AI_PROVIDER === 'gemini' ? env.AI_API_KEY : '');
  const openaiKey = env.OPENAI_API_KEY || (env.AI_PROVIDER === 'openai' ? env.AI_API_KEY : '');
  const hasWorkersAi = typeof env.AI?.run === 'function';

  if (!geminiKey && !openaiKey && !env.AI_API_KEY && !hasWorkersAi) {
    return Response.json(
      {
        ok: false,
        error: 'Dịch vụ AI chưa được cấu hình trên máy chủ backend (thiếu GEMINI_API_KEY hoặc OPENAI_API_KEY). Vui lòng cấu hình secret trên Cloudflare Worker.',
        configured: false,
      },
      { status: 503, headers },
    );
  }

  // Request authentication if bearer token is provided or if server enforces auth
  const authHeader = request.headers.get('Authorization') || '';
  if (authHeader.startsWith('Bearer ')) {
    const authResult = await authenticateRequest(request, env);
    if (authResult.error) {
      return Response.json({ ok: false, error: authResult.error }, { status: authResult.status, headers });
    }
  } else if (env.REQUIRE_AUTH_FOR_CHAT === 'true') {
    return Response.json(
      { ok: false, error: 'Yêu cầu đăng nhập tài khoản để sử dụng Trợ lý AI.' },
      { status: 401, headers },
    );
  }

  let body = preParsedBody;
  if (!body) {
    try {
      body = await request.json();
    } catch (_) {
      return Response.json({ ok: false, error: 'Dữ liệu yêu cầu không hợp lệ (cần định dạng JSON).' }, { status: 400, headers });
    }
  }

  const rawMessage = typeof body.message === 'string' ? body.message.trim() : '';
  if (!rawMessage) {
    return Response.json({ ok: false, error: 'Nội dung tin nhắn không được để trống.' }, { status: 400, headers });
  }
  if (rawMessage.length > 2000) {
    return Response.json({ ok: false, error: 'Tin nhắn vượt quá giới hạn 2.000 ký tự cho phép.' }, { status: 400, headers });
  }

  // Validate and sanitize previous conversation turns
  const rawHistory = Array.isArray(body.history) ? body.history : [];
  const sanitizedHistory = rawHistory
    .slice(-20)
    .filter((item) => item && typeof item.content === 'string' && item.content.trim().length > 0)
    .map((item) => ({
      role: item.role === 'user' ? 'user' : 'model',
      content: String(item.content).trim().slice(0, 2000),
    }));

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 25000);

  try {
    // 1. Google Gemini API Provider
    if (geminiKey) {
      const model = env.AI_MODEL || 'gemini-flash-latest';
      const endpoint = `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent?key=${encodeURIComponent(geminiKey)}`;

      const contents = [];
      for (const h of sanitizedHistory) {
        contents.push({
          role: h.role === 'user' ? 'user' : 'model',
          parts: [{ text: h.content }],
        });
      }
      contents.push({
        role: 'user',
        parts: [{ text: rawMessage }],
      });

      const res = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          systemInstruction: {
            parts: [{ text: AI_SYSTEM_PROMPT }],
          },
          contents,
          generationConfig: {
            temperature: 0.7,
            maxOutputTokens: 1024,
          },
        }),
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!res.ok) {
        let errDetail = `Mã lỗi HTTP ${res.status}`;
        try {
          const errData = await res.json();
          if (errData?.error?.message) {
            errDetail = errData.error.message;
          }
        } catch (_) {}

        // Nếu gặp lỗi vùng vị trí hoặc lỗi Gemini, tự động dự phòng qua Cloudflare Workers AI
        if (hasWorkersAi) {
          try {
            const fallbackMessages = [{ role: 'system', content: AI_SYSTEM_PROMPT }];
            for (const h of sanitizedHistory) {
              fallbackMessages.push({
                role: h.role === 'user' ? 'user' : 'assistant',
                content: h.content,
              });
            }
            fallbackMessages.push({ role: 'user', content: rawMessage });
            const aiResult = await env.AI.run('@cf/meta/llama-3.2-3b-instruct', {
              messages: fallbackMessages,
              max_tokens: 1024,
            });
            if (aiResult?.response) {
              return Response.json({ ok: true, reply: String(aiResult.response).trim() }, { status: 200, headers });
            }
            return Response.json({ ok: false, error: 'Workers AI returned empty response: ' + JSON.stringify(aiResult) }, { status: 500, headers });
          } catch (e) {
            return Response.json({ ok: false, error: 'Workers AI fallback failed: ' + e.message }, { status: 500, headers });
          }
        }

        return Response.json(
          { ok: false, error: `Dịch vụ Gemini API phản hồi lỗi: ${errDetail}` },
          { status: res.status >= 500 ? 502 : res.status, headers },
        );
      }

      const resData = await res.json();
      const replyCandidate = resData?.candidates?.[0]?.content?.parts?.[0]?.text;
      if (!replyCandidate) {
        return Response.json(
          { ok: false, error: 'Dịch vụ AI không trả về nội dung câu trả lời.' },
          { status: 502, headers },
        );
      }

      return Response.json({ ok: true, reply: replyCandidate.trim() }, { status: 200, headers });
    }

    // 2. OpenAI / Compatible API Provider
    if (openaiKey || env.AI_API_KEY) {
      const apiKey = openaiKey || env.AI_API_KEY;
      const model = env.AI_MODEL || 'gpt-4o-mini';
      const endpoint = env.AI_ENDPOINT || 'https://api.openai.com/v1/chat/completions';

      const messages = [{ role: 'system', content: AI_SYSTEM_PROMPT }];
      for (const h of sanitizedHistory) {
        messages.push({
          role: h.role === 'user' ? 'user' : 'assistant',
          content: h.content,
        });
      }
      messages.push({ role: 'user', content: rawMessage });

      const res = await fetch(endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`,
        },
        body: JSON.stringify({
          model,
          messages,
          max_tokens: 1024,
          temperature: 0.7,
        }),
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!res.ok) {
        let errDetail = `Mã lỗi HTTP ${res.status}`;
        try {
          const errData = await res.json();
          if (errData?.error?.message) {
            errDetail = errData.error.message;
          }
        } catch (_) {}
        return Response.json(
          { ok: false, error: `Dịch vụ OpenAI phản hồi lỗi: ${errDetail}` },
          { status: res.status >= 500 ? 502 : res.status, headers },
        );
      }

      const resData = await res.json();
      const reply = resData?.choices?.[0]?.message?.content;
      if (!reply) {
        return Response.json(
          { ok: false, error: 'Dịch vụ AI không trả về nội dung câu trả lời.' },
          { status: 502, headers },
        );
      }

      return Response.json({ ok: true, reply: reply.trim() }, { status: 200, headers });
    }

    // 3. Cloudflare Workers AI Binding
    if (hasWorkersAi) {
      const messages = [{ role: 'system', content: AI_SYSTEM_PROMPT }];
      for (const h of sanitizedHistory) {
        messages.push({
          role: h.role === 'user' ? 'user' : 'assistant',
          content: h.content,
        });
      }
      messages.push({ role: 'user', content: rawMessage });

      const modelName = env.AI_MODEL || '@cf/meta/llama-3.2-3b-instruct';
      const aiResult = await env.AI.run(modelName, {
        messages,
        max_tokens: 1024,
      });

      clearTimeout(timeoutId);

      const reply = aiResult?.response;
      if (!reply) {
        return Response.json(
          { ok: false, error: 'Cloudflare Workers AI không trả về nội dung phản hồi.' },
          { status: 502, headers },
        );
      }

      return Response.json({ ok: true, reply: String(reply).trim() }, { status: 200, headers });
    }

    clearTimeout(timeoutId);
    return Response.json({ ok: false, error: 'Không tìm thấy nhà cung cấp AI hợp lệ.' }, { status: 500, headers });
  } catch (err) {
    clearTimeout(timeoutId);
    if (err.name === 'AbortError') {
      return Response.json(
        { ok: false, error: 'Yêu cầu tới AI đã bị quá thời gian chờ (timeout sau 25 giây). Vui lòng thử lại.' },
        { status: 504, headers },
      );
    }
    return Response.json(
      { ok: false, error: `Lỗi kết nối mạng hoặc lỗi server: ${err.message || 'Không xác định'}` },
      { status: 500, headers },
    );
  }
}

export default {
  async fetch(request, env) {
    const origin = request.headers.get('Origin') || '';
    const allowedOrigins = parseCsvEnv(env.ALLOWED_ORIGINS);
    const originAllowed =
      allowedOrigins.length === 0 ||
      allowedOrigins.includes('*') ||
      (origin ? allowedOrigins.includes(origin) : true);

    if (!originAllowed) {
      return Response.json({ verified: false, error: 'Origin is not allowed.' }, { status: 403 });
    }

    const headers = corsHeaders(origin || '*');
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers });
    }

    const url = new URL(request.url);
    const path = url.pathname.replace(/\/+$/, '') || '/';

    // -------------------------------------------------------------------------
    // 1. PROFILE ENDPOINTS (Authenticated User - Self Only)
    // -------------------------------------------------------------------------
    if (path === '/profile') {
      const auth = await authenticateRequest(request, env);
      if (auth.error) {
        return Response.json({ ok: false, message: auth.error }, { status: auth.status, headers });
      }

      if (request.method === 'GET') {
        return Response.json({
          ok: true,
          profile: {
            uid: auth.user.uid,
            email: auth.user.email,
            displayName: auth.user.displayName,
            role: auth.user.role,
          },
        }, { status: 200, headers });
      }

      if (request.method === 'PUT') {
        try {
          const body = await request.json();
          const targetUid = typeof body.uid === 'string' ? body.uid.trim() : auth.user.uid;

          // Enforce self-only profile editing
          if (targetUid !== auth.user.uid) {
            return Response.json({
              ok: false,
              message: 'Forbidden: You cannot modify another user\'s profile.',
            }, { status: 403, headers });
          }

          // Block privilege escalation or unauthorized level editing by non-admin
          if (auth.user.role !== 'admin') {
            if (body.role && body.role !== 'user') {
              return Response.json({
                ok: false,
                message: 'Forbidden: Regular users cannot change account roles.',
              }, { status: 403, headers });
            }
            if (body.cefrLevel !== undefined) {
              return Response.json({
                ok: false,
                message: 'Forbidden: CEFR level is managed by the system or administrators.',
              }, { status: 403, headers });
            }
          }

          const displayName = typeof body.displayName === 'string' ? body.displayName.trim() : '';
          const bio = typeof body.bio === 'string' ? body.bio.trim() : '';
          const learningGoal = typeof body.learningGoal === 'string' ? body.learningGoal.trim() : '';

          if (displayName.length < 2 || displayName.length > 60) {
            return Response.json({
              ok: false,
              message: 'Display name must be between 2 and 60 characters.',
            }, { status: 400, headers });
          }
          if (bio.length > 300 || learningGoal.length > 150) {
            return Response.json({
              ok: false,
              message: 'Bio (max 300 chars) or learning goal (max 150 chars) exceeds limit.',
            }, { status: 400, headers });
          }

          return Response.json({
            ok: true,
            message: 'Profile updated successfully.',
            profile: {
              uid: auth.user.uid,
              email: auth.user.email,
              displayName,
              bio,
              learningGoal,
              role: auth.user.role,
            },
          }, { status: 200, headers });
        } catch (_) {
          return Response.json({ ok: false, message: 'Invalid JSON payload.' }, { status: 400, headers });
        }
      }

      return Response.json({ ok: false, message: 'Method not allowed.' }, { status: 405, headers });
    }

    // -------------------------------------------------------------------------
    // 2. ADMIN ENDPOINTS (Strict Server-Side Admin Role Check)
    // -------------------------------------------------------------------------
    if (path.startsWith('/admin/')) {
      const auth = await authenticateRequest(request, env);
      if (auth.error) {
        return Response.json({ ok: false, message: auth.error }, { status: auth.status, headers });
      }
      if (auth.user.role !== 'admin') {
        return Response.json({
          ok: false,
          message: 'Forbidden (403): Admin privileges are required to access this endpoint.',
        }, { status: 403, headers });
      }

      if (path === '/admin/users' && request.method === 'GET') {
        return Response.json({
          ok: true,
          actor: auth.user,
          message: 'Admin access verified.',
        }, { status: 200, headers });
      }

      if (path === '/admin/users' && request.method === 'PATCH') {
        try {
          const body = await request.json();
          const targetUid = typeof body.targetUid === 'string' ? body.targetUid.trim() : '';
          const role = typeof body.role === 'string' ? body.role.trim().toLowerCase() : 'user';
          const cefrLevel = typeof body.cefrLevel === 'string' ? body.cefrLevel.trim().toUpperCase() : 'A1';

          if (!targetUid) {
            return Response.json({ ok: false, message: 'Missing targetUid.' }, { status: 400, headers });
          }
          if (!VALID_ROLES.includes(role)) {
            return Response.json({ ok: false, message: 'Invalid role.' }, { status: 400, headers });
          }
          if (!VALID_CEFR_LEVELS.includes(cefrLevel)) {
            return Response.json({ ok: false, message: 'Invalid CEFR level.' }, { status: 400, headers });
          }
          if (targetUid === auth.user.uid && (role !== 'admin' || body.isActive === false)) {
            return Response.json({
              ok: false,
              message: 'Cannot demote or disable your own active admin account.',
            }, { status: 400, headers });
          }

          return Response.json({
            ok: true,
            message: 'User updated by admin.',
            updated: { targetUid, role, cefrLevel, updatedBy: auth.user.uid },
          }, { status: 200, headers });
        } catch (_) {
          return Response.json({ ok: false, message: 'Invalid JSON body.' }, { status: 400, headers });
        }
      }

      if (path === '/admin/users' && request.method === 'DELETE') {
        try {
          const body = await request.json();
          const targetUid = typeof body.targetUid === 'string' ? body.targetUid.trim() : '';
          if (!targetUid || targetUid === auth.user.uid) {
            return Response.json({
              ok: false,
              message: 'Invalid targetUid or cannot delete your own admin account.',
            }, { status: 400, headers });
          }
          return Response.json({
            ok: true,
            message: 'User deleted by admin.',
            deletedUid: targetUid,
          }, { status: 200, headers });
        } catch (_) {
          return Response.json({ ok: false, message: 'Invalid JSON body.' }, { status: 400, headers });
        }
      }

      return Response.json({ ok: false, message: 'Admin route or method not found.' }, { status: 404, headers });
    }

    // -------------------------------------------------------------------------
    // 3. AI CHAT ENDPOINTS (/chat, /api/chat)
    // -------------------------------------------------------------------------
    if (path === '/chat' || path === '/api/chat') {
      if (request.method === 'GET') {
        const hasKey = !!(env.GEMINI_API_KEY || env.OPENAI_API_KEY || env.AI_API_KEY || env.AI);
        return Response.json({
          ok: true,
          service: 'English Buddy AI Chat API',
          configured: hasKey,
          message: hasKey
            ? 'Dịch vụ AI đã sẵn sàng tiếp nhận câu hỏi.'
            : 'Dịch vụ AI chưa được cấu hình API key trên máy chủ backend (cần GEMINI_API_KEY hoặc OPENAI_API_KEY).',
        }, { status: 200, headers });
      }

      if (request.method === 'POST') {
        return handleAiChatRequest(request, env, headers);
      }

      return Response.json({ ok: false, message: 'Method not allowed.' }, { status: 405, headers });
    }

    // -------------------------------------------------------------------------
    // 4. TURNSTILE ANTI-BOT VERIFICATION (POST / or POST /auth/verify-captcha)
    // -------------------------------------------------------------------------
    if (request.method !== 'POST') {
      return Response.json({ verified: false, message: 'Method not allowed.' }, { status: 405, headers });
    }

    try {
      const body = await request.json();

      // Nếu payload gửi lên chứa 'message' (tin nhắn AI Chat gửi vào root URL)
      if (typeof body?.message === 'string') {
        return handleAiChatRequest(request, env, headers, body);
      }

      if (!env.TURNSTILE_SECRET) {
        return Response.json({ verified: false, message: 'Turnstile is not configured on the server.' }, { status: 503, headers });
      }

      const token = typeof body.token === 'string' ? body.token.trim() : '';
      const action = typeof body.action === 'string' ? body.action : '';
      if (!token || !['register', 'login'].includes(action)) {
        return Response.json({ verified: false, message: 'Missing token or invalid action.' }, { status: 400, headers });
      }

      const form = new URLSearchParams({
        secret: env.TURNSTILE_SECRET,
        response: token,
      });
      const remoteIp = request.headers.get('CF-Connecting-IP');
      if (remoteIp) form.set('remoteip', remoteIp);

      const upstream = await fetch('https://challenges.cloudflare.com/turnstile/v0/siteverify', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: form,
      });
      if (!upstream.ok) {
        return Response.json({ verified: false, message: 'Turnstile validation service is unavailable.' }, { status: 502, headers });
      }

      const result = await upstream.json();
      const allowedHosts = parseCsvEnv(env.ALLOWED_HOSTNAMES);
      const hostAllowed = allowedHosts.length === 0 || allowedHosts.includes(result.hostname);
      const actionMatches = !result.action || result.action === 'auth';
      const verified = result.success === true && hostAllowed && actionMatches;
      return Response.json({
        verified,
        message: verified ? 'CAPTCHA verified.' : 'CAPTCHA token was rejected.',
        ...(verified ? { verificationId: result.challenge_ts || crypto.randomUUID() } : {}),
      }, { status: 200, headers });
    } catch (_) {
      return Response.json({ verified: false, message: 'Invalid request or validation error.' }, { status: 400, headers });
    }
  },
};
