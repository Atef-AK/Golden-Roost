import * as dotenv from 'dotenv';
dotenv.config({ path: '.env.local' });
dotenv.config();

import { neonConfig, Pool } from '@neondatabase/serverless';
import { drizzle } from 'drizzle-orm/neon-serverless';
import * as schema from '../src/db/schema';
import { eq } from 'drizzle-orm';

neonConfig.fetchConnectionCache = true;

const email = process.argv[2] || process.env.BOOTSTRAP_ADMIN_EMAIL;
const firebaseUid = process.argv[3] || process.env.BOOTSTRAP_ADMIN_UID;
const displayName = process.argv[4] || 'Golden Roost Superadmin';

if (!email) {
  console.error('Usage: npx tsx scripts/bootstrap-admin.ts <admin_email> [firebase_uid] [display_name]');
  process.exit(1);
}

const targetEmail: string = email;

const connectionString = process.env.DATABASE_URL;
if (!connectionString) {
  console.error('DATABASE_URL environment variable is missing.');
  process.exit(1);
}

const pool = new Pool({ connectionString });
const db = drizzle(pool, { schema });

async function bootstrap() {
  console.log(`Bootstrapping Superadmin: ${targetEmail}...`);

  const uid = firebaseUid || `firebase_${crypto.randomUUID()}`;

  const existing = await db
    .select()
    .from(schema.adminUsers)
    .where(eq(schema.adminUsers.email, targetEmail))
    .limit(1);

  if (existing.length > 0) {
    await db
      .update(schema.adminUsers)
      .set({
        role: 'superadmin',
        isActive: true,
        displayName: displayName,
        updatedAt: new Date(),
      })
      .where(eq(schema.adminUsers.email, targetEmail));
    console.log(`Superadmin user "${targetEmail}" updated successfully with role "superadmin".`);
  } else {
    await db.insert(schema.adminUsers).values({
      email: targetEmail,
      firebaseUid: uid,
      role: 'superadmin',
      displayName: displayName,
      isActive: true,
    });
    console.log(`Superadmin user "${targetEmail}" created with Firebase UID "${uid}".`);
  }

  console.log('\nNext steps:');
  console.log(`1. In the Firebase Console, create an Authentication user with email: ${email}`);
  console.log(`2. If using custom UID, set UID to: ${uid}`);
  console.log(`3. Access the Golden Roost Web Admin at: https://<domain>/admin/login`);

  process.exit(0);
}

bootstrap().catch((err) => {
  console.error('Bootstrap error:', err);
  process.exit(1);
});
