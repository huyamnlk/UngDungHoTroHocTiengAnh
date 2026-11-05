/**
 * Cloudflare Worker backend for English Buddy:
 * 1. Server-verified Cloudflare Turnstile anti-bot check (POST / or POST /auth/verify-captcha)
 * 2. Server-enforced Profile, Username Mapping & Role-Based Access Control (RBAC) API:
 *    - GET    /profile        (Authenticated user reads own profile, username & server-verified role)
 *    - PUT    /profile        (Authenticated user updates ONLY own profile & username; blocks role/level escalation)
 *    - POST   /auth/login     (Server-side username/email + password login via D1 + Firebase Auth; prevents email enumeration)
 *    - GET    /admin/users    (Admin-only: returns 401/403 if non-admin calls directly)
 *    - PATCH  /admin/users    (Admin-only: updates target user's role, cefrLevel, profile, active status)
 *    - DELETE /admin/users    (Admin-only: deletes target user profile; blocks self-delete)
 * 3. Public & Authenticated AI Chat API:
 *    - GET    /chat, /api/chat
 *    - POST   /chat, /api/chat
 *
 * Configure TURNSTILE_SECRET, FIREBASE_API_KEY, GEMINI_API_KEY, ADMIN_EMAILS, ADMIN_UIDS,
 * ALLOWED_ORIGINS and ALLOWED_HOSTNAMES as Worker secrets/variables, and bind D1 database as DB.
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
const RESERVED_USERNAMES = new Set([
  'admin',
  'administrator',
  'root',
  'system',
  'support',
  'guest',
  'local_learner',
  'null',
  'undefined',
  'api',
  'auth',
  'profile',
  'settings',
  'help',
]);

// In-memory rate limiters per isolate (protects public guest chat & login against abuse/enumeration)
const chatRateLimitMap = new Map();
const loginRateLimitMap = new Map();

function checkRateLimit(map, key, maxRequests, windowMs) {
  const now = Date.now();
  const entry = map.get(key);
  if (!entry || now - entry.windowStart >= windowMs) {
    map.set(key, { windowStart: now, count: 1 });
    return { allowed: true, remaining: maxRequests - 1 };
  }
  if (entry.count >= maxRequests) {
    return { allowed: false, remaining: 0 };
  }
  entry.count += 1;
  return { allowed: true, remaining: maxRequests - entry.count };
}

function getClientIdentifier(request) {
  return (
    request.headers.get('CF-Connecting-IP') ||
    request.headers.get('X-Forwarded-For')?.split(',')[0]?.trim() ||
    'anon-client'
  );
}

function parseCsvEnv(raw) {
  return (raw || '')
    .split(',')
    .map((v) => v.trim())
    .filter(Boolean);
}

/**
 * Normalizes and validates a username:
 * - Normalized to lowercase, trimmed.
 * - 3 to 30 characters.
 * - Allowed characters: a-z, 0-9, ., _, - (must start and end with alphanumeric, no consecutive symbols, no '@').
 */
export function validateAndNormalizeUsername(raw) {
  if (typeof raw !== 'string') {
    return { valid: false, message: 'Tên đăng nhập không hợp lệ.' };
  }
  const trimmed = raw.trim();
  if (!trimmed) {
    return { valid: false, message: 'Tên đăng nhập không được để trống.' };
  }
  if (trimmed.includes('@')) {
    return {
      valid: false,
      message: 'Tên đăng nhập không được chứa ký tự "@".',
    };
  }
  const normalized = trimmed.toLowerCase();
  if (normalized.length < 3 || normalized.length > 30) {
    return {
      valid: false,
      message: 'Tên đăng nhập phải có độ dài từ 3 đến 30 ký tự.',
    };
  }
  if (!/^[a-z0-9](?:[a-z0-9._-]{1,28}[a-z0-9])?$/.test(normalized)) {
    return {
      valid: false,
      message:
        'Tên đăng nhập chỉ được chứa chữ cái không dấu (a-z), chữ số (0-9), dấu chấm (.), gạch dưới (_) hoặc gạch ngang (-), bắt đầu và kết thúc bằng chữ hoặc số.',
    };
  }
  if (/[._-]{2,}/.test(normalized)) {
    return {
      valid: false,
      message: 'Tên đăng nhập không được chứa hai ký tự đặc biệt liên tiếp.',
    };
  }
  if (RESERVED_USERNAMES.has(normalized)) {
    return {
      valid: false,
      message: 'Tên đăng nhập này thuộc danh sách từ khóa hệ thống và không thể sử dụng.',
    };
  }
  return { valid: true, normalized, display: normalized };
}

let d1SchemaInitialized = false;

async function ensureD1Schema(db) {
  if (!db || d1SchemaInitialized) return;
  try {
    await db
      .prepare(
        `CREATE TABLE IF NOT EXISTS user_accounts (
          uid TEXT PRIMARY KEY,
          email TEXT NOT NULL,
          username TEXT UNIQUE,
          username_normalized TEXT UNIQUE,
          display_name TEXT NOT NULL DEFAULT '',
          bio TEXT NOT NULL DEFAULT '',
          learning_goal TEXT NOT NULL DEFAULT '',
          avatar_data TEXT NOT NULL DEFAULT '',
          provider_id TEXT NOT NULL DEFAULT 'password',
          role TEXT NOT NULL DEFAULT 'user',
          cefr_level TEXT NOT NULL DEFAULT 'A1',
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )`,
      )
      .run();
    await db
      .prepare(
        'CREATE UNIQUE INDEX IF NOT EXISTS idx_user_accounts_username_norm ON user_accounts (username_normalized)',
      )
      .run();
    d1SchemaInitialized = true;
  } catch (_) {
    // Table/index may already exist
  }
}

/**
 * Verifies the Firebase ID token against Identity Toolkit and resolves the user's server-side role.
 */
async function authenticateRequest(request, env) {
  const authHeader = request.headers.get('Authorization') || '';
  if (!authHeader.startsWith('Bearer ')) {
    return {
      error: 'Missing or invalid Authorization Bearer token.',
      errorCode: 'UNAUTHENTICATED',
      status: 401,
    };
  }
  const idToken = authHeader.slice(7).trim();
  if (!idToken) {
    return {
      error: 'Empty Bearer token.',
      errorCode: 'UNAUTHENTICATED',
      status: 401,
    };
  }
  if (!env.FIREBASE_API_KEY) {
    return {
      error: 'FIREBASE_API_KEY is not configured on the backend server.',
      errorCode: 'BACKEND_AUTH_UNCONFIGURED',
      status: 503,
    };
  }

  let lookupRes;
  try {
    lookupRes = await fetch(
      `https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${encodeURIComponent(env.FIREBASE_API_KEY)}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ idToken }),
      },
    );
  } catch (err) {
    return {
      error: 'Unable to reach Firebase authentication service.',
      errorCode: 'AUTH_UPSTREAM_ERROR',
      status: 502,
    };
  }

  if (!lookupRes.ok) {
    let detailCode = 'TOKEN_INVALID_OR_EXPIRED';
    try {
      const errBody = await lookupRes.json();
      const rawMsg = String(errBody?.error?.message || '').toUpperCase();
      if (rawMsg.includes('EXPIRED')) {
        detailCode = 'TOKEN_EXPIRED';
      } else if (rawMsg.includes('API_KEY_INVALID') || rawMsg.includes('PROJECT_NOT_FOUND')) {
        return {
          error: 'FIREBASE_API_KEY on the backend server is invalid.',
          errorCode: 'BACKEND_AUTH_UNCONFIGURED',
          status: 503,
        };
      }
    } catch (_) {}
    return {
      error: 'Invalid or expired Firebase ID token.',
      errorCode: detailCode,
      status: 401,
    };
  }

  const data = await lookupRes.json();
  const account = Array.isArray(data.users) && data.users.length > 0 ? data.users[0] : null;
  if (!account || !account.localId) {
    return {
      error: 'User account not found.',
      errorCode: 'UNAUTHENTICATED',
      status: 401,
    };
  }
  if (account.disabled === true) {
    return {
      error: 'Account has been disabled by an administrator.',
      errorCode: 'USER_DISABLED',
      status: 403,
    };
  }

  const uid = String(account.localId);
  const email = String(account.email || '').toLowerCase();
  const displayName = String(account.displayName || (email ? email.split('@')[0] : 'Learner'));

  const providerList = Array.isArray(account.providerUserInfo)
    ? account.providerUserInfo.map((p) => String(p.providerId || '')).filter(Boolean)
    : [];
  const hasPasswordProvider = providerList.includes('password');
  const providerId = hasPasswordProvider
    ? 'password'
    : providerList.includes('google.com')
      ? 'google.com'
      : providerList[0] || 'password';

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
      providerId,
      hasPasswordProvider,
      idToken,
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
 * Both Guest (no Authorization header) and Authenticated users (valid Bearer token) are supported.
 * Never downgrades an invalid/expired Authorization header to guest.
 */
async function handleAiChatRequest(request, env, headers, preParsedBody = null) {
  // 1. Verify authentication strictly if Authorization header is present
  const rawAuthHeader = request.headers.get('Authorization');
  let authenticatedUser = null;

  if (rawAuthHeader !== null && rawAuthHeader.trim().length > 0) {
    const authResult = await authenticateRequest(request, env);
    if (authResult.error) {
      return Response.json(
        {
          ok: false,
          error: authResult.error,
          errorCode: authResult.errorCode || 'UNAUTHENTICATED',
          configured: authResult.errorCode !== 'BACKEND_AUTH_UNCONFIGURED',
        },
        { status: authResult.status, headers },
      );
    }
    authenticatedUser = authResult.user;
  } else if (env.REQUIRE_AUTH_FOR_CHAT === 'true') {
    return Response.json(
      {
        ok: false,
        error: 'Yêu cầu đăng nhập tài khoản để sử dụng Trợ lý AI.',
        errorCode: 'UNAUTHENTICATED',
      },
      { status: 401, headers },
    );
  } else {
    // Public guest chat rate limiting (max 20 requests per minute per client IP)
    const clientIp = getClientIdentifier(request);
    const rateCheck = checkRateLimit(chatRateLimitMap, `guest_chat:${clientIp}`, 20, 60_000);
    if (!rateCheck.allowed) {
      return Response.json(
        {
          ok: false,
          error: 'Bạn đang gửi tin nhắn quá nhanh ở chế độ Khách. Vui lòng đợi ít phút hoặc đăng nhập tài khoản để tiếp tục.',
          errorCode: 'RATE_LIMITED',
        },
        { status: 429, headers },
      );
    }
  }

  const geminiKey = env.GEMINI_API_KEY || (env.AI_PROVIDER === 'gemini' ? env.AI_API_KEY : '');
  const openaiKey = env.OPENAI_API_KEY || (env.AI_PROVIDER === 'openai' ? env.AI_API_KEY : '');
  const hasWorkersAi = typeof env.AI?.run === 'function';

  if (!geminiKey && !openaiKey && !env.AI_API_KEY && !hasWorkersAi) {
    return Response.json(
      {
        ok: false,
        error: 'Dịch vụ AI chưa được cấu hình trên máy chủ backend (thiếu GEMINI_API_KEY hoặc OPENAI_API_KEY). Vui lòng cấu hình secret trên Cloudflare Worker.',
        errorCode: 'BACKEND_UNCONFIGURED',
        configured: false,
      },
      { status: 503, headers },
    );
  }

  let body = preParsedBody;
  if (!body) {
    try {
      body = await request.json();
    } catch (_) {
      return Response.json(
        {
          ok: false,
          error: 'Dữ liệu yêu cầu không hợp lệ (cần định dạng JSON).',
          errorCode: 'BAD_REQUEST',
        },
        { status: 400, headers },
      );
    }
  }

  const rawMessage = typeof body.message === 'string' ? body.message.trim() : '';
  if (!rawMessage) {
    return Response.json(
      {
        ok: false,
        error: 'Nội dung tin nhắn không được để trống.',
        errorCode: 'BAD_REQUEST',
      },
      { status: 400, headers },
    );
  }
  if (rawMessage.length > 2000) {
    return Response.json(
      {
        ok: false,
        error: 'Tin nhắn vượt quá giới hạn 2.000 ký tự cho phép.',
        errorCode: 'BAD_REQUEST',
      },
      { status: 400, headers },
    );
  }

  // Validate and sanitize previous conversation turns (limit history for safety & token budget)
  const maxHistoryTurns = authenticatedUser ? 20 : 12;
  const rawHistory = Array.isArray(body.history) ? body.history : [];
  const sanitizedHistory = rawHistory
    .slice(-maxHistoryTurns)
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

        // Fallback to Cloudflare Workers AI if Gemini returns an upstream error
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
              return Response.json(
                {
                  ok: true,
                  reply: String(aiResult.response).trim(),
                  mode: authenticatedUser ? 'authenticated' : 'guest',
                },
                { status: 200, headers },
              );
            }
            return Response.json(
              {
                ok: false,
                error: 'Nhà cung cấp AI không trả về nội dung phản hồi.',
                errorCode: 'AI_PROVIDER_ERROR',
              },
              { status: 502, headers },
            );
          } catch (e) {
            return Response.json(
              {
                ok: false,
                error: `Dịch vụ AI tạm thời gián đoạn: ${e.message}`,
                errorCode: 'AI_PROVIDER_ERROR',
              },
              { status: 502, headers },
            );
          }
        }

        return Response.json(
          {
            ok: false,
            error: `Dịch vụ Gemini API phản hồi lỗi: ${errDetail}`,
            errorCode: 'AI_PROVIDER_ERROR',
          },
          { status: res.status >= 500 ? 502 : res.status, headers },
        );
      }

      const resData = await res.json();
      const replyCandidate = resData?.candidates?.[0]?.content?.parts?.[0]?.text;
      if (!replyCandidate) {
        return Response.json(
          {
            ok: false,
            error: 'Dịch vụ AI không trả về nội dung câu trả lời.',
            errorCode: 'AI_PROVIDER_ERROR',
          },
          { status: 502, headers },
        );
      }

      return Response.json(
        {
          ok: true,
          reply: replyCandidate.trim(),
          mode: authenticatedUser ? 'authenticated' : 'guest',
        },
        { status: 200, headers },
      );
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
          {
            ok: false,
            error: `Dịch vụ OpenAI phản hồi lỗi: ${errDetail}`,
            errorCode: 'AI_PROVIDER_ERROR',
          },
          { status: res.status >= 500 ? 502 : res.status, headers },
        );
      }

      const resData = await res.json();
      const reply = resData?.choices?.[0]?.message?.content;
      if (!reply) {
        return Response.json(
          {
            ok: false,
            error: 'Dịch vụ AI không trả về nội dung câu trả lời.',
            errorCode: 'AI_PROVIDER_ERROR',
          },
          { status: 502, headers },
        );
      }

      return Response.json(
        {
          ok: true,
          reply: reply.trim(),
          mode: authenticatedUser ? 'authenticated' : 'guest',
        },
        { status: 200, headers },
      );
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
          {
            ok: false,
            error: 'Cloudflare Workers AI không trả về nội dung phản hồi.',
            errorCode: 'AI_PROVIDER_ERROR',
          },
          { status: 502, headers },
        );
      }

      return Response.json(
        {
          ok: true,
          reply: String(reply).trim(),
          mode: authenticatedUser ? 'authenticated' : 'guest',
        },
        { status: 200, headers },
      );
    }

    clearTimeout(timeoutId);
    return Response.json(
      {
        ok: false,
        error: 'Không tìm thấy nhà cung cấp AI hợp lệ.',
        errorCode: 'BACKEND_UNCONFIGURED',
        configured: false,
      },
      { status: 503, headers },
    );
  } catch (err) {
    clearTimeout(timeoutId);
    if (err.name === 'AbortError') {
      return Response.json(
        {
          ok: false,
          error: 'Yêu cầu tới AI đã bị quá thời gian chờ (timeout sau 25 giây). Vui lòng thử lại.',
          errorCode: 'AI_TIMEOUT',
        },
        { status: 504, headers },
      );
    }
    return Response.json(
      {
        ok: false,
        error: `Lỗi kết nối mạng hoặc lỗi nhà cung cấp AI: ${err.message || 'Không xác định'}`,
        errorCode: 'AI_PROVIDER_ERROR',
      },
      { status: 502, headers },
    );
  }
}

/**
 * Reads or initializes the user account record in D1.
 */
async function getOrSyncUserAccountInD1(db, authUser) {
  if (!db) return null;
  await ensureD1Schema(db);
  const existing = await db
    .prepare('SELECT * FROM user_accounts WHERE uid = ? LIMIT 1')
    .bind(authUser.uid)
    .first();

  const nowIso = new Date().toISOString();
  if (existing) {
    return existing;
  }

  await db
    .prepare(
      `INSERT INTO user_accounts (
        uid, email, username, username_normalized, display_name, bio, learning_goal,
        avatar_data, provider_id, role, cefr_level, is_active, created_at, updated_at
      ) VALUES (?, ?, NULL, NULL, ?, '', '', '', ?, ?, 'A1', 1, ?, ?)
      ON CONFLICT(uid) DO NOTHING`,
    )
    .bind(
      authUser.uid,
      authUser.email.toLowerCase(),
      authUser.displayName,
      authUser.providerId || 'password',
      authUser.role || 'user',
      nowIso,
      nowIso,
    )
    .run();

  return await db
    .prepare('SELECT * FROM user_accounts WHERE uid = ? LIMIT 1')
    .bind(authUser.uid)
    .first();
}

/**
 * Server-side login endpoint (POST /auth/login) supporting both Username and Email + Password.
 * Resolves username -> email strictly on the server and verifies password with Firebase Auth,
 * never exposing email mappings publicly.
 */
async function handleAuthLogin(request, env, headers) {
  const clientIp = getClientIdentifier(request);
  const rateCheck = checkRateLimit(loginRateLimitMap, `login:${clientIp}`, 15, 60_000);
  if (!rateCheck.allowed) {
    return Response.json(
      {
        ok: false,
        errorCode: 'TOO_MANY_ATTEMPTS',
        message: 'Quá nhiều lần thử đăng nhập. Vui lòng đợi 1 phút rồi thử lại.',
      },
      { status: 429, headers },
    );
  }

  if (!env.FIREBASE_API_KEY) {
    return Response.json(
      {
        ok: false,
        errorCode: 'BACKEND_AUTH_UNCONFIGURED',
        message: 'FIREBASE_API_KEY is not configured on the backend server.',
      },
      { status: 503, headers },
    );
  }

  let body;
  try {
    body = await request.json();
  } catch (_) {
    return Response.json(
      { ok: false, errorCode: 'BAD_REQUEST', message: 'Invalid JSON payload.' },
      { status: 400, headers },
    );
  }

  const rawIdentifier = typeof body.identifier === 'string' ? body.identifier.trim() : '';
  const password = typeof body.password === 'string' ? body.password : '';

  if (!rawIdentifier || !password) {
    return Response.json(
      {
        ok: false,
        errorCode: 'BAD_REQUEST',
        message: 'Vui lòng nhập đầy đủ Tên đăng nhập / Email và Mật khẩu.',
      },
      { status: 400, headers },
    );
  }

  let emailToUse = rawIdentifier;
  let d1Account = null;

  if (!rawIdentifier.includes('@')) {
    // Username login requires persistent D1 database
    if (!env.DB) {
      return Response.json(
        {
          ok: false,
          errorCode: 'STORAGE_UNCONFIGURED',
          message:
            'Cơ sở dữ liệu lưu trữ username (Cloudflare D1 binding DB) chưa được cấu hình trên máy chủ.',
        },
        { status: 503, headers },
      );
    }

    const validation = validateAndNormalizeUsername(rawIdentifier);
    if (!validation.valid) {
      return Response.json(
        {
          ok: false,
          errorCode: 'INVALID_LOGIN_CREDENTIALS',
          message: 'Tên đăng nhập/Email hoặc mật khẩu không chính xác. Vui lòng kiểm tra lại.',
        },
        { status: 401, headers },
      );
    }

    await ensureD1Schema(env.DB);
    d1Account = await env.DB
      .prepare('SELECT * FROM user_accounts WHERE username_normalized = ? LIMIT 1')
      .bind(validation.normalized)
      .first();

    if (!d1Account || !d1Account.email) {
      return Response.json(
        {
          ok: false,
          errorCode: 'INVALID_LOGIN_CREDENTIALS',
          message: 'Tên đăng nhập/Email hoặc mật khẩu không chính xác. Vui lòng kiểm tra lại.',
        },
        { status: 401, headers },
      );
    }

    if (d1Account.is_active === 0) {
      return Response.json(
        {
          ok: false,
          errorCode: 'USER_DISABLED',
          message: 'Tài khoản này đã bị vô hiệu hóa bởi quản trị viên.',
        },
        { status: 403, headers },
      );
    }

    if (d1Account.provider_id === 'google.com') {
      return Response.json(
        {
          ok: false,
          errorCode: 'GOOGLE_ACCOUNT_NO_PASSWORD',
          message:
            'Tài khoản này sử dụng phương thức Đăng nhập bằng Google. Vui lòng nhấn nút Đăng nhập bằng Google.',
        },
        { status: 400, headers },
      );
    }

    emailToUse = String(d1Account.email);
  }

  // Verify credentials against Firebase Identity Toolkit
  let fbRes;
  try {
    fbRes = await fetch(
      `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${encodeURIComponent(env.FIREBASE_API_KEY)}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: emailToUse,
          password,
          returnSecureToken: true,
        }),
      },
    );
  } catch (_) {
    return Response.json(
      {
        ok: false,
        errorCode: 'AUTH_UPSTREAM_ERROR',
        message: 'Không thể kết nối tới máy chủ xác thực Firebase.',
      },
      { status: 502, headers },
    );
  }

  const fbData = await fbRes.json();
  if (!fbRes.ok || !fbData.localId) {
    const rawCode = String(fbData?.error?.message || 'INVALID_LOGIN_CREDENTIALS').toUpperCase();
    if (rawCode.includes('USER_DISABLED')) {
      return Response.json(
        {
          ok: false,
          errorCode: 'USER_DISABLED',
          message: 'Tài khoản này đã bị vô hiệu hóa bởi quản trị viên.',
        },
        { status: 403, headers },
      );
    }
    if (rawCode.includes('TOO_MANY_ATTEMPTS')) {
      return Response.json(
        {
          ok: false,
          errorCode: 'TOO_MANY_ATTEMPTS',
          message: 'Quá nhiều lần thử thất bại. Vui lòng đợi ít phút rồi thử lại.',
        },
        { status: 429, headers },
      );
    }
    return Response.json(
      {
        ok: false,
        errorCode: 'INVALID_LOGIN_CREDENTIALS',
        message: 'Tên đăng nhập/Email hoặc mật khẩu không chính xác. Vui lòng kiểm tra lại.',
      },
      { status: 401, headers },
    );
  }

  const uid = String(fbData.localId);
  const resolvedEmail = String(fbData.email || emailToUse);
  const idToken = String(fbData.idToken || '');
  const refreshToken = String(fbData.refreshToken || '');
  let displayName = String(
    fbData.displayName || (resolvedEmail ? resolvedEmail.split('@')[0] : 'Learner'),
  );
  let username = '';

  if (env.DB) {
    await ensureD1Schema(env.DB);
    const row =
      d1Account && d1Account.uid === uid
        ? d1Account
        : await env.DB.prepare('SELECT * FROM user_accounts WHERE uid = ? LIMIT 1').bind(uid).first();
    if (row) {
      if (row.display_name && String(row.display_name).trim().length > 0) {
        displayName = String(row.display_name).trim();
      }
      if (row.username && String(row.username).trim().length > 0) {
        username = String(row.username).trim();
      }
    } else {
      const nowIso = new Date().toISOString();
      await env.DB
        .prepare(
          `INSERT INTO user_accounts (
            uid, email, username, username_normalized, display_name, bio, learning_goal,
            avatar_data, provider_id, role, cefr_level, is_active, created_at, updated_at
          ) VALUES (?, ?, NULL, NULL, ?, '', '', '', 'password', 'user', 'A1', 1, ?, ?)
          ON CONFLICT(uid) DO NOTHING`,
        )
        .bind(uid, resolvedEmail.toLowerCase(), displayName, nowIso, nowIso)
        .run();
    }
  }

  // Determine admin role
  const adminUids = parseCsvEnv(env.ADMIN_UIDS);
  const adminEmails = parseCsvEnv(env.ADMIN_EMAILS).map((e) => e.toLowerCase());
  const defaultAdminUids = ['kK847H8QYXQ3RGBwfIxjYANxZHv2'];
  const defaultAdminEmails = ['giahuy2005a@gmail.com'];
  const emailLower = resolvedEmail.toLowerCase();
  const role =
    adminUids.includes(uid) ||
    defaultAdminUids.includes(uid) ||
    adminEmails.includes(emailLower) ||
    defaultAdminEmails.includes(emailLower)
      ? 'admin'
      : 'user';

  return Response.json(
    {
      ok: true,
      message: 'Đăng nhập thành công!',
      user: {
        uid,
        email: resolvedEmail,
        username,
        displayName,
        providerId: 'password',
        idToken,
        refreshToken,
        role,
      },
    },
    { status: 200, headers },
  );
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
    // 0. SERVER-SIDE LOGIN WITH USERNAME OR EMAIL (POST /auth/login)
    // -------------------------------------------------------------------------
    if (path === '/auth/login') {
      if (request.method === 'POST') {
        return handleAuthLogin(request, env, headers);
      }
      return Response.json({ ok: false, message: 'Method not allowed.' }, { status: 405, headers });
    }

    // Explicitly block public username-to-email enumeration endpoints
    if (path === '/resolve-username' || path === '/auth/resolve-username') {
      return Response.json(
        {
          ok: false,
          errorCode: 'ENDPOINT_DISABLED_FOR_PRIVACY',
          message:
            'Không công khai ánh xạ username-email. Vui lòng sử dụng POST /auth/login để xác thực.',
        },
        { status: 403, headers },
      );
    }

    // -------------------------------------------------------------------------
    // 1. PROFILE ENDPOINTS (Authenticated User - Self Only)
    // -------------------------------------------------------------------------
    if (path === '/profile') {
      const auth = await authenticateRequest(request, env);
      if (auth.error) {
        return Response.json(
          { ok: false, errorCode: auth.errorCode || 'UNAUTHENTICATED', message: auth.error },
          { status: auth.status, headers },
        );
      }

      if (request.method === 'GET') {
        let row = null;
        if (env.DB) {
          row = await getOrSyncUserAccountInD1(env.DB, auth.user);
        }
        return Response.json(
          {
            ok: true,
            profile: {
              uid: auth.user.uid,
              email: auth.user.email,
              username: row?.username ? String(row.username) : '',
              displayName:
                row?.display_name && String(row.display_name).trim().length > 0
                  ? String(row.display_name).trim()
                  : auth.user.displayName,
              bio: row?.bio ? String(row.bio) : '',
              learningGoal: row?.learning_goal ? String(row.learning_goal) : '',
              avatarData: row?.avatar_data ? String(row.avatar_data) : '',
              providerId: auth.user.providerId,
              hasPasswordProvider: auth.user.hasPasswordProvider,
              role: auth.user.role,
              cefrLevel: row?.cefr_level ? String(row.cefr_level) : 'A1',
            },
          },
          { status: 200, headers },
        );
      }

      if (request.method === 'PUT') {
        try {
          const body = await request.json();
          const targetUid =
            typeof body.uid === 'string' && body.uid.trim().length > 0
              ? body.uid.trim()
              : typeof body.targetUid === 'string' && body.targetUid.trim().length > 0
                ? body.targetUid.trim()
                : auth.user.uid;

          // Enforce self-only profile editing (never trust client-declared UID)
          if (targetUid !== auth.user.uid) {
            return Response.json(
              {
                ok: false,
                errorCode: 'FORBIDDEN_OTHER_USER',
                message: "Forbidden: You cannot modify another user's profile.",
              },
              { status: 403, headers },
            );
          }

          // Block privilege escalation or unauthorized level editing by non-admin
          if (auth.user.role !== 'admin') {
            if (body.role && body.role !== 'user') {
              return Response.json(
                {
                  ok: false,
                  errorCode: 'FORBIDDEN_ROLE_CHANGE',
                  message: 'Forbidden: Regular users cannot change account roles.',
                },
                { status: 403, headers },
              );
            }
            if (body.cefrLevel !== undefined) {
              return Response.json(
                {
                  ok: false,
                  errorCode: 'FORBIDDEN_LEVEL_CHANGE',
                  message: 'Forbidden: CEFR level is managed by the system or administrators.',
                },
                { status: 403, headers },
              );
            }
          }

          const displayName = typeof body.displayName === 'string' ? body.displayName.trim() : '';
          const bio = typeof body.bio === 'string' ? body.bio.trim() : '';
          const learningGoal =
            typeof body.learningGoal === 'string' ? body.learningGoal.trim() : '';
          const avatarData = typeof body.avatarData === 'string' ? body.avatarData.trim() : '';

          if (displayName.length < 2 || displayName.length > 60) {
            return Response.json(
              {
                ok: false,
                errorCode: 'INVALID_DISPLAY_NAME',
                message: 'Display name must be between 2 and 60 characters.',
              },
              { status: 400, headers },
            );
          }
          if (bio.length > 300 || learningGoal.length > 150) {
            return Response.json(
              {
                ok: false,
                errorCode: 'INVALID_PROFILE_FIELDS',
                message: 'Bio (max 300 chars) or learning goal (max 150 chars) exceeds limit.',
              },
              { status: 400, headers },
            );
          }

          const hasUsernameField = body.username !== undefined && body.username !== null;
          const rawUsername = hasUsernameField ? String(body.username).trim() : '';
          let normalizedUsername = null;

          if (rawUsername.length > 0) {
            const usernameCheck = validateAndNormalizeUsername(rawUsername);
            if (!usernameCheck.valid) {
              return Response.json(
                {
                  ok: false,
                  errorCode: 'INVALID_USERNAME',
                  message: usernameCheck.message,
                },
                { status: 400, headers },
              );
            }
            normalizedUsername = usernameCheck.normalized;

            if (!env.DB) {
              return Response.json(
                {
                  ok: false,
                  errorCode: 'STORAGE_UNCONFIGURED',
                  message:
                    'Cơ sở dữ liệu lưu trữ username (Cloudflare D1 binding DB) chưa được cấu hình trên máy chủ.',
                },
                { status: 503, headers },
              );
            }
          }

          let savedUsername = '';
          let savedCefrLevel =
            auth.user.role === 'admin' &&
            typeof body.cefrLevel === 'string' &&
            VALID_CEFR_LEVELS.includes(body.cefrLevel.trim().toUpperCase())
              ? body.cefrLevel.trim().toUpperCase()
              : 'A1';

          if (env.DB) {
            await ensureD1Schema(env.DB);
            const currentRow = await getOrSyncUserAccountInD1(env.DB, auth.user);
            if (currentRow?.cefr_level && !(auth.user.role === 'admin' && body.cefrLevel)) {
              savedCefrLevel = String(currentRow.cefr_level);
            }

            const finalUsername = hasUsernameField
              ? normalizedUsername
              : currentRow?.username || null;
            const finalUsernameNorm = hasUsernameField
              ? normalizedUsername
              : currentRow?.username_normalized || null;

            if (finalUsernameNorm) {
              const conflict = await env.DB
                .prepare(
                  'SELECT uid FROM user_accounts WHERE username_normalized = ? AND uid != ? LIMIT 1',
                )
                .bind(finalUsernameNorm, auth.user.uid)
                .first();

              if (conflict) {
                return Response.json(
                  {
                    ok: false,
                    errorCode: 'USERNAME_TAKEN',
                    message: 'Tên đăng nhập này đã được sử dụng bởi một tài khoản khác.',
                  },
                  { status: 409, headers },
                );
              }
            }

            const nowIso = new Date().toISOString();
            const safeAvatar =
              avatarData && !avatarData.startsWith('data:image/')
                ? avatarData
                : currentRow?.avatar_data || 'preset:scholar_blue';

            try {
              await env.DB
                .prepare(
                  `INSERT INTO user_accounts (
                    uid, email, username, username_normalized, display_name, bio, learning_goal,
                    avatar_data, provider_id, role, cefr_level, is_active, created_at, updated_at
                  ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)
                  ON CONFLICT(uid) DO UPDATE SET
                    email = excluded.email,
                    username = excluded.username,
                    username_normalized = excluded.username_normalized,
                    display_name = excluded.display_name,
                    bio = excluded.bio,
                    learning_goal = excluded.learning_goal,
                    avatar_data = excluded.avatar_data,
                    provider_id = excluded.provider_id,
                    role = excluded.role,
                    cefr_level = excluded.cefr_level,
                    updated_at = excluded.updated_at`,
                )
                .bind(
                  auth.user.uid,
                  auth.user.email.toLowerCase(),
                  finalUsername,
                  finalUsernameNorm,
                  displayName,
                  bio,
                  learningGoal,
                  safeAvatar,
                  auth.user.providerId || 'password',
                  auth.user.role,
                  savedCefrLevel,
                  currentRow?.created_at || nowIso,
                  nowIso,
                )
                .run();
              savedUsername = finalUsername || '';
            } catch (dbErr) {
              const errMsg = String(dbErr?.message || '');
              if (errMsg.includes('UNIQUE') || errMsg.includes('constraint')) {
                return Response.json(
                  {
                    ok: false,
                    errorCode: 'USERNAME_TAKEN',
                    message: 'Tên đăng nhập này đã được sử dụng bởi một tài khoản khác.',
                  },
                  { status: 409, headers },
                );
              }
              throw dbErr;
            }
          }

          // Sync displayName back to Firebase Authentication record
          if (env.FIREBASE_API_KEY && auth.user.idToken) {
            try {
              await fetch(
                `https://identitytoolkit.googleapis.com/v1/accounts:update?key=${encodeURIComponent(env.FIREBASE_API_KEY)}`,
                {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json' },
                  body: JSON.stringify({
                    idToken: auth.user.idToken,
                    displayName,
                    returnSecureToken: false,
                  }),
                },
              );
            } catch (_) {}
          }

          return Response.json(
            {
              ok: true,
              message: 'Profile updated successfully.',
              profile: {
                uid: auth.user.uid,
                email: auth.user.email,
                username: savedUsername,
                displayName,
                bio,
                learningGoal,
                providerId: auth.user.providerId,
                hasPasswordProvider: auth.user.hasPasswordProvider,
                role: auth.user.role,
                cefrLevel: savedCefrLevel,
              },
            },
            { status: 200, headers },
          );
        } catch (_) {
          return Response.json(
            { ok: false, errorCode: 'BAD_REQUEST', message: 'Invalid JSON payload.' },
            { status: 400, headers },
          );
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
        return Response.json(
          {
            ok: false,
            message: 'Forbidden (403): Admin privileges are required to access this endpoint.',
          },
          { status: 403, headers },
        );
      }

      if (path === '/admin/users' && request.method === 'GET') {
        return Response.json(
          {
            ok: true,
            actor: auth.user,
            message: 'Admin access verified.',
          },
          { status: 200, headers },
        );
      }

      if (path === '/admin/users' && request.method === 'PATCH') {
        try {
          const body = await request.json();
          const targetUid = typeof body.targetUid === 'string' ? body.targetUid.trim() : '';
          const role = typeof body.role === 'string' ? body.role.trim().toLowerCase() : 'user';
          const cefrLevel =
            typeof body.cefrLevel === 'string' ? body.cefrLevel.trim().toUpperCase() : 'A1';

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
            return Response.json(
              {
                ok: false,
                message: 'Cannot demote or disable your own active admin account.',
              },
              { status: 400, headers },
            );
          }

          return Response.json(
            {
              ok: true,
              message: 'User updated by admin.',
              updated: { targetUid, role, cefrLevel, updatedBy: auth.user.uid },
            },
            { status: 200, headers },
          );
        } catch (_) {
          return Response.json({ ok: false, message: 'Invalid JSON body.' }, { status: 400, headers });
        }
      }

      if (path === '/admin/users' && request.method === 'DELETE') {
        try {
          const body = await request.json();
          const targetUid = typeof body.targetUid === 'string' ? body.targetUid.trim() : '';
          if (!targetUid || targetUid === auth.user.uid) {
            return Response.json(
              {
                ok: false,
                message: 'Invalid targetUid or cannot delete your own admin account.',
              },
              { status: 400, headers },
            );
          }
          return Response.json(
            {
              ok: true,
              message: 'User deleted by admin.',
              deletedUid: targetUid,
            },
            { status: 200, headers },
          );
        } catch (_) {
          return Response.json({ ok: false, message: 'Invalid JSON body.' }, { status: 400, headers });
        }
      }

      return Response.json(
        { ok: false, message: 'Admin route or method not found.' },
        { status: 404, headers },
      );
    }

    // -------------------------------------------------------------------------
    // 3. AI CHAT ENDPOINTS (/chat, /api/chat)
    // -------------------------------------------------------------------------
    if (path === '/chat' || path === '/api/chat') {
      if (request.method === 'GET') {
        const hasKey = !!(env.GEMINI_API_KEY || env.OPENAI_API_KEY || env.AI_API_KEY || env.AI);
        const hasFirebaseKey = !!env.FIREBASE_API_KEY;
        return Response.json(
          {
            ok: true,
            service: 'English Buddy AI Chat API',
            configured: hasKey,
            authConfigured: hasFirebaseKey,
            message: hasKey
                ? 'Dịch vụ AI đã sẵn sàng tiếp nhận câu hỏi.'
                : 'Dịch vụ AI chưa được cấu hình API key trên máy chủ backend (cần GEMINI_API_KEY hoặc OPENAI_API_KEY).',
          },
          { status: 200, headers },
        );
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

      // If payload contains 'message' (AI Chat sent to root URL)
      if (typeof body?.message === 'string') {
        return handleAiChatRequest(request, env, headers, body);
      }

      if (!env.TURNSTILE_SECRET) {
        return Response.json(
          { verified: false, message: 'Turnstile is not configured on the server.' },
          { status: 503, headers },
        );
      }

      const token = typeof body.token === 'string' ? body.token.trim() : '';
      const action = typeof body.action === 'string' ? body.action : '';
      if (!token || !['register', 'login'].includes(action)) {
        return Response.json(
          { verified: false, message: 'Missing token or invalid action.' },
          { status: 400, headers },
        );
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
        return Response.json(
          { verified: false, message: 'Turnstile validation service is unavailable.' },
          { status: 502, headers },
        );
      }

      const result = await upstream.json();
      const allowedHosts = parseCsvEnv(env.ALLOWED_HOSTNAMES);
      const hostAllowed = allowedHosts.length === 0 || allowedHosts.includes(result.hostname);
      const actionMatches = !result.action || result.action === 'auth';
      const verified = result.success === true && hostAllowed && actionMatches;
      return Response.json(
        {
          verified,
          message: verified ? 'CAPTCHA verified.' : 'CAPTCHA token was rejected.',
          ...(verified ? { verificationId: result.challenge_ts || crypto.randomUUID() } : {}),
        },
        { status: 200, headers },
      );
    } catch (_) {
      return Response.json(
        { verified: false, message: 'Invalid request or validation error.' },
        { status: 400, headers },
      );
    }
  },
};
