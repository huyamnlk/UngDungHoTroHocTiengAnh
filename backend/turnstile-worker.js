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

export default {
  async fetch(request, env) {
    const origin = request.headers.get('Origin') || '';
    const allowedOrigins = parseCsvEnv(env.ALLOWED_ORIGINS);
    if (!origin || !allowedOrigins.includes(origin)) {
      return Response.json({ verified: false, error: 'Origin is not allowed.' }, { status: 403 });
    }

    const headers = corsHeaders(origin);
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
    // 3. TURNSTILE ANTI-BOT VERIFICATION (POST / or POST /auth/verify-captcha)
    // -------------------------------------------------------------------------
    if (request.method !== 'POST') {
      return Response.json({ verified: false, message: 'Method not allowed.' }, { status: 405, headers });
    }
    if (!env.TURNSTILE_SECRET) {
      return Response.json({ verified: false, message: 'Turnstile is not configured on the server.' }, { status: 503, headers });
    }

    try {
      const body = await request.json();
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
