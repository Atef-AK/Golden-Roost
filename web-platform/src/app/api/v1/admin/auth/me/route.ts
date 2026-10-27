import { NextRequest, NextResponse } from 'next/server';
import { verifyAdminSession, AuthError } from '@/lib/auth';

export async function GET(request: NextRequest) {
  try {
    const admin = await verifyAdminSession(request);
    return NextResponse.json({
      success: true,
      user: admin,
    });
  } catch (err: unknown) {
    if (err instanceof AuthError) {
      return NextResponse.json({ error: err.message }, { status: err.statusCode });
    }
    return NextResponse.json({ error: 'Failed to verify session' }, { status: 500 });
  }
}
