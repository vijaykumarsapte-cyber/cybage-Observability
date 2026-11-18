-- Demo data for GET /users (POC doc 4.2): [{"id":1,"name":"John"},{"id":2,"name":"Jerry"}]
-- Idempotent: safe to run on every deploy. The "User" table is created by
-- `prisma db push` when demo-api starts.
INSERT INTO "User" (id, name) VALUES (1, 'John'), (2, 'Jerry')
ON CONFLICT (id) DO NOTHING;
SELECT setval(pg_get_serial_sequence('"User"', 'id'), GREATEST((SELECT MAX(id) FROM "User"), 1));
