import { defineConfig } from 'drizzle-kit';
import * as dotenv from 'dotenv';

const envPath = process.env.DOTENV_CONFIG_PATH || (process.env.NODE_ENV === 'production' ? '.env.production.local' : '.env.local');
dotenv.config({ path: envPath });
dotenv.config();

export default defineConfig({
  schema: './src/db/schema.ts',
  out: './drizzle',
  dialect: 'postgresql',
  dbCredentials: {
    url: process.env.DATABASE_URL || '',
  },
});
