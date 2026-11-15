// Thesis sample app: API tests (Jest + Supertest against the exported app, no port needed).
// Replace every test.todo with a real test. Acceptance: >= 10 passing tests, no todo/skip left.

// TODO: import supertest, the app and the store; reset the store in beforeEach

describe('health and version', () => {
  test.todo('GET /healthz returns 200 {"status":"ok"}');
  test.todo('GET /version returns "dev" when APP_VERSION is unset');
  test.todo('GET /version returns APP_VERSION when it is set');
});

describe('items', () => {
  test.todo('GET /api/items returns an empty array initially');
  test.todo('POST /api/items creates an item (201, id, name, createdAt)');
  test.todo('POST /api/items returns 400 when name is missing');
  test.todo('POST /api/items returns 400 when name is empty or not a string');
  test.todo('POST /api/items returns 400 when name is longer than 100 chars');
  test.todo('GET /api/items/:id returns the created item');
  test.todo('GET /api/items/:id returns 404 for an unknown id');
  test.todo('DELETE /api/items/:id returns 204 and the item is gone');
  test.todo('DELETE /api/items/:id returns 404 for an unknown id');
});

describe('fallback', () => {
  test.todo('unknown route returns a JSON 404');
});
