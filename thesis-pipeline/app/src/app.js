// Thesis sample app: Express application (NO listen() here).
// See days/2026-11-08/TASK.md for the full API specification.

// TODO: import express and your item store (./store)

// TODO: create the app and enable JSON body parsing

// TODO: GET /healthz  -> 200 {"status":"ok"}

// TODO: GET /version  -> 200 {"version": process.env.APP_VERSION || "dev"}

// TODO: GET    /api/items      -> 200 array of items
// TODO: POST   /api/items      -> 201 created item, 400 on invalid "name"
// TODO: GET    /api/items/:id  -> 200 item, 404 {"error":"not found"}
// TODO: DELETE /api/items/:id  -> 204, 404 {"error":"not found"}

// TODO: JSON 404 handler for unknown routes (registered after all routes)

// TODO: export the app (and nothing that starts a server)
