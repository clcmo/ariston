import {createRemoteJWKSet, jwtVerify} from 'jose';

const allowedOrigins = new Set([
  'https://clcmo.github.io',
  'https://dev.camilaloliveira.me',
]);

function isAllowedOrigin(origin) {
  return (
    allowedOrigins.has(origin) ||
    /^http:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin)
  );
}

function validateMessages(messages) {
  if (!Array.isArray(messages) || messages.length === 0 || messages.length > 40) {
    return false;
  }

  let totalCharacters = 0;
  for (const message of messages) {
    if (
      message === null ||
      typeof message !== 'object' ||
      !['user', 'assistant'].includes(message.role) ||
      typeof message.content !== 'string' ||
      message.content.trim().length === 0 ||
      message.content.length > 4000
    ) {
      return false;
    }
    totalCharacters += message.content.length;
  }

  return (
    totalCharacters <= 16000 &&
    messages[messages.length - 1].role === 'user'
  );
}

function jsonResponse(body, status, headers) {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...headers,
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-store',
    },
  });
}

export function createWorker({verifyToken, generateReply}) {
  return {
    async fetch(request, env) {
      const origin = request.headers.get('Origin');
      if (origin && !isAllowedOrigin(origin)) {
        return jsonResponse({error: 'Origem não permitida.'}, 403);
      }

      const corsHeaders = origin
        ? {
            'Access-Control-Allow-Origin': origin,
            'Access-Control-Allow-Headers': 'Authorization, Content-Type',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            Vary: 'Origin',
          }
        : {};

      if (request.method === 'OPTIONS') {
        return new Response(null, {status: 204, headers: corsHeaders});
      }
      if (new URL(request.url).pathname !== '/chat') {
        return jsonResponse({error: 'Endpoint não encontrado.'}, 404, corsHeaders);
      }
      if (request.method !== 'POST') {
        return jsonResponse({error: 'Método não permitido.'}, 405, corsHeaders);
      }
      if (!request.headers.get('Content-Type')?.includes('application/json')) {
        return jsonResponse({error: 'Envie uma requisição JSON.'}, 415, corsHeaders);
      }

      const authorization = request.headers.get('Authorization') || '';
      const tokenMatch = /^Bearer\s+(.+)$/i.exec(authorization);
      if (!tokenMatch) {
        return jsonResponse({error: 'Autenticação necessária.'}, 401, corsHeaders);
      }

      let user;
      try {
        user = await verifyToken(tokenMatch[1], env.FIREBASE_PROJECT_ID);
      } catch (_) {
        return jsonResponse(
          {error: 'Sessão inválida. Entre novamente.'},
          401,
          corsHeaders,
        );
      }

      let body;
      try {
        const rawBody = await request.text();
        if (new TextEncoder().encode(rawBody).length > 64 * 1024) {
          return jsonResponse({error: 'Requisição muito grande.'}, 413, corsHeaders);
        }
        body = JSON.parse(rawBody);
      } catch (_) {
        return jsonResponse({error: 'Formato JSON inválido.'}, 400, corsHeaders);
      }
      if (!validateMessages(body?.messages)) {
        return jsonResponse(
          {error: 'Formato de mensagens inválido.'},
          400,
          corsHeaders,
        );
      }

      try {
        const reply = await generateReply(body.messages, env);
        if (typeof reply !== 'string' || reply.trim().length === 0) {
          return jsonResponse(
            {error: 'A IA não retornou uma resposta.'},
            502,
            corsHeaders,
          );
        }
        return jsonResponse({reply}, 200, corsHeaders);
      } catch (err) {
        console.error(`Falha ao consultar IA para o usuário ${user.uid}.`, err.message);
        return jsonResponse(
          {error: 'Não foi possível obter uma resposta da IA.'},
          502,
          corsHeaders,
        );
      }
    },
  };
}

async function generateWorkersAiReply(messages, env) {
  const aiMessages = [
    {
      role: 'system',
      content: 'Você é Ariston, uma assistente útil e acolhedora. Responda em português brasileiro, a menos que a pessoa prefira outro idioma.',
    },
    ...messages.map(({role, content}) => ({
      role: role === 'assistant' ? 'assistant' : 'user',
      content,
    })),
  ];

  const response = await env.AI.run('@cf/meta/llama-3.3-70b-instruct-fp8-fast', {
    messages: aiMessages,
    max_tokens: 512,
    temperature: 0.7,
  });

  return response.response;
}

async function verifyFirebaseToken(token, projectId) {
  if (!projectId) {
    throw new Error('FIREBASE_PROJECT_ID não está configurado.');
  }

  const jwks = createRemoteJWKSet(
    new URL(
      'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com',
    ),
  );
  const {payload} = await jwtVerify(token, jwks, {
    issuer: `https://securetoken.google.com/${projectId}`,
    audience: projectId,
    algorithms: ['RS256'],
  });

  if (typeof payload.sub !== 'string' || payload.sub.length === 0) {
    throw new Error('Token Firebase sem identificador de usuário.');
  }
  return {uid: payload.sub};
}

export default createWorker({
  verifyToken: verifyFirebaseToken,
  generateReply: generateWorkersAiReply,
});
