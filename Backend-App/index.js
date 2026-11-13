import { createServer } from 'node:http';
import { randomUUID } from 'node:crypto';

const tasks = new Map();

class HttpError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

async function readFields(req, creating) {
  if (req.headers['content-type']?.split(';')[0].trim().toLowerCase() !== 'application/json') {
    throw new HttpError(415, 'Use Content-Type application/json.');
  }
  const chunks = [];
  let length = 0;
  for await (const chunk of req.iterator({ destroyOnReturn: false })) {
    length += chunk.length;
    if (length > 16384) throw new HttpError(413, 'Body exceeds 16 KiB.');
    chunks.push(chunk);
  }
  let body;
  try {
    body = JSON.parse(Buffer.concat(chunks).toString('utf8'));
  } catch {
    throw new HttpError(400, 'Body must contain valid JSON.');
  }
  if (!body || typeof body !== 'object' || Array.isArray(body) || !Object.keys(body).length ||
      Object.keys(body).some(key => !['title', 'completed'].includes(key))) {
    throw new HttpError(400, 'Supply title, completed, or both.');
  }
  if (creating || 'title' in body) {
    if (typeof body.title !== 'string' || !body.title.trim() || body.title.trim().length > 200) {
      throw new HttpError(400, 'Supply a nonblank title of up to 200 characters.');
    }
    body.title = body.title.trim();
  }
  if ('completed' in body && typeof body.completed !== 'boolean') {
    throw new HttpError(400, 'Completed must be a boolean.');
  }
  return body;
}

const server = createServer(async (req, res) => {
  function send(status, body, headers = {}) {
    res.writeHead(status, { 'Content-Type': 'application/json', ...headers });
    res.end(JSON.stringify(body));
  }
  try {
    const path = req.url.split('?')[0];
    const item = /^\/tasks\/([^/]+)$/.exec(path);
    const id = item?.[1];
    let allowed;
    if (path === '/health') allowed = ['GET'];
    else if (path === '/tasks') allowed = ['GET', 'POST'];
    else if (item) allowed = ['GET', 'PATCH', 'DELETE'];
    else throw new HttpError(404, 'Route not found.');

    if (!allowed.includes(req.method)) {
      return send(405, { error: 'Method not allowed.' }, { Allow: allowed.join(', ') });
    }
    if (path === '/health') return send(200, { status: 'ok' });
    if (req.method === 'POST') {
      const fields = await readFields(req, true);
      const task = { id: randomUUID(), title: fields.title, completed: fields.completed ?? false };
      tasks.set(task.id, task);
      return send(201, task, { Location: '/tasks/' + task.id });
    }
    if (!id) return send(200, Array.from(tasks.values()));

    const fields = req.method === 'PATCH' ? await readFields(req, false) : null;
    const task = tasks.get(id);
    if (!task) throw new HttpError(404, 'Task not found.');
    if (req.method === 'DELETE') {
      tasks.delete(id);
      return send(204);
    }
    if (fields) Object.assign(task, fields);
    return send(200, task);
  } catch (error) {
    if (!(error instanceof HttpError)) console.error(error);
    send(error.status || 500, { error: error instanceof HttpError ? error.message : 'Internal server error.' });
  }
});

server.listen(Number(process.env.PORT ?? 3100), process.env.HOST || '127.0.0.1', () => {
  const { address, port } = server.address();
  console.log('Task API listening on', address, 'port', port);
});
for (const signal of ['SIGINT', 'SIGTERM']) {
  process.once(signal, () => server.close());
}
