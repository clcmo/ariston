import {test} from 'node:test';
import assert from 'node:assert/strict';

import {createWorker} from './index.js';

const messages = [{role: 'user', content: 'Oi, Ariston!'}];

function request({
  method = 'POST',
  path = '/chat',
  origin = 'https://dev.camilaloliveira.me',
  authorization = 'Bearer valid-token',
  body = {messages},
  contentType = 'application/json',
} = {}) {
  return new Request(`https://ariston-chat-api.workers.dev${path}`, {
    method,
    headers: {
      ...(origin ? {Origin: origin} : {}),
      ...(authorization ? {Authorization: authorization} : {}),
      'Content-Type': contentType,
    },
    ...(method === 'GET' || method === 'OPTIONS'
      ? {}
      : {body: JSON.stringify(body)}),
  });
}

function worker({verifyToken = async () => ({uid: 'user-1'}), generateReply} = {}) {
  return createWorker({
    verifyToken,
    generateReply: generateReply || (async () => 'Olá! Como posso ajudar?'),
  });
}

test('validates the Firebase token and returns the AI response', async () => {
  let verified;
  let receivedMessages;
  const app = worker({
    verifyToken: async (token, projectId) => {
      verified = {token, projectId};
      return {uid: 'user-1'};
    },
    generateReply: async (history) => {
      receivedMessages = history;
      return 'Olá! Como posso ajudar?';
    },
  });

  const response = await app.fetch(request(), {
    FIREBASE_PROJECT_ID: 'ariston-chat',
    GEMINI_API_KEY: 'test-secret',
  });

  assert.equal(response.status, 200);
  assert.deepEqual(verified, {token: 'valid-token', projectId: 'ariston-chat'});
  assert.deepEqual(receivedMessages, messages);
  assert.deepEqual(await response.json(), {reply: 'Olá! Como posso ajudar?'});
  assert.equal(
    response.headers.get('Access-Control-Allow-Origin'),
    'https://dev.camilaloliveira.me',
  );
});

test('rejects missing and invalid Firebase tokens before calling Gemini', async () => {
  let providerCalled = false;
  const app = worker({
    verifyToken: async () => {
      throw new Error('invalid token');
    },
    generateReply: async () => {
      providerCalled = true;
      return 'unexpected';
    },
  });

  const missing = await app.fetch(request({authorization: null}), {
    FIREBASE_PROJECT_ID: 'ariston-chat',
  });
  const invalid = await app.fetch(request(), {
    FIREBASE_PROJECT_ID: 'ariston-chat',
  });

  assert.equal(missing.status, 401);
  assert.equal(invalid.status, 401);
  assert.equal(providerCalled, false);
});

test('rejects malformed history and disallowed browser origins', async () => {
  const app = worker();
  const malformed = await app.fetch(
    request({body: {messages: [{role: 'system', content: 'No.'}]}}),
    {FIREBASE_PROJECT_ID: 'ariston-chat'},
  );
  const disallowed = await app.fetch(request({origin: 'https://example.com'}), {
    FIREBASE_PROJECT_ID: 'ariston-chat',
  });

  assert.equal(malformed.status, 400);
  assert.equal(disallowed.status, 403);
});

test('answers CORS preflight and rejects unknown paths', async () => {
  const app = worker();
  const preflight = await app.fetch(request({method: 'OPTIONS'}), {});
  const missingPath = await app.fetch(request({path: '/'}), {});

  assert.equal(preflight.status, 204);
  assert.equal(
    preflight.headers.get('Access-Control-Allow-Methods'),
    'POST, OPTIONS',
  );
  assert.equal(missingPath.status, 404);
});
