import { neon } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-http';
import * as schema from './schema';

function getConnectionString(): string {
  return (
    process.env.DATABASE_URL ||
    process.env.DATABASE_URL_UNPOOLED ||
    process.env.POSTGRES_URL ||
    process.env.POSTGRES_URL_NON_POOLING ||
    ''
  );
}

let _db: ReturnType<typeof drizzle<typeof schema>> | null = null;

export function getDb() {
  if (!_db) {
    const conn = getConnectionString();
    if (!conn) {
      throw new Error(
        'Database connection string missing: neither DATABASE_URL nor DATABASE_URL_UNPOOLED is set.'
      );
    }
    const client = neon(conn);
    _db = drizzle(client, { schema });
  }
  return _db;
}

export const db = new Proxy({} as ReturnType<typeof drizzle<typeof schema>>, {
  get(_target, prop, receiver) {
    const database = getDb();
    const value = Reflect.get(database, prop, receiver);
    if (typeof value === 'function') {
      return value.bind(database);
    }
    return value;
  },
});

export default db;
