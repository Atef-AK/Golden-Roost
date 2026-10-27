import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/db';
import { articles, articleTranslations } from '@/db/schema';
import { eq } from 'drizzle-orm';
import { verifyAdminSession, AuthError } from '@/lib/auth';
import { logAdminAction } from '@/lib/audit';

export async function GET(
  request: NextRequest,
  { params }: { params: Promise<{ slug: string }> }
) {
  try {
    const { slug } = await params;
    const { searchParams } = new URL(request.url);
    const locale = searchParams.get('locale') || 'en';

    const [art] = await db
      .select()
      .from(articles)
      .where(eq(articles.slug, slug))
      .limit(1);

    if (!art) {
      return NextResponse.json({ error: 'Article not found' }, { status: 404 });
    }

    const translations = await db
      .select()
      .from(articleTranslations)
      .where(eq(articleTranslations.articleId, art.id));

    const selectedTrans =
      translations.find((t) => t.locale === locale) ||
      translations.find((t) => t.locale === 'en') ||
      translations[0];

    return NextResponse.json({
      success: true,
      data: {
        ...art,
        title: selectedTrans?.title || art.slug,
        summary: selectedTrans?.summary || '',
        content: selectedTrans?.content || '',
        translations: translations.map((t) => ({
          locale: t.locale,
          title: t.title,
          summary: t.summary,
          content: t.content,
        })),
      },
    });
  } catch (err) {
    console.error('Error fetching article by slug:', err);
    return NextResponse.json({ error: 'Failed to fetch article' }, { status: 500 });
  }
}

export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ slug: string }> }
) {
  try {
    const admin = await verifyAdminSession(request, ['superadmin', 'editor', 'veterinarian']);
    const { slug } = await params;
    const body = await request.json();
    const { category, featuredImageUrl, isPublished, translations } = body;

    const [art] = await db
      .select()
      .from(articles)
      .where(eq(articles.slug, slug))
      .limit(1);

    if (!art) {
      return NextResponse.json({ error: 'Article not found' }, { status: 404 });
    }

    await db
      .update(articles)
      .set({
        category: category ?? art.category,
        featuredImageUrl: featuredImageUrl ?? art.featuredImageUrl,
        isPublished: isPublished !== undefined ? !!isPublished : art.isPublished,
        updatedAt: new Date(),
      })
      .where(eq(articles.id, art.id));

    if (translations && Array.isArray(translations)) {
      for (const trans of translations) {
        if (trans.locale && trans.title) {
          await db
            .insert(articleTranslations)
            .values({
              articleId: art.id,
              locale: trans.locale,
              title: trans.title,
              summary: trans.summary || '',
              content: trans.content || '',
            })
            .onConflictDoUpdate({
              target: [articleTranslations.articleId, articleTranslations.locale],
              set: {
                title: trans.title,
                summary: trans.summary || '',
                content: trans.content || '',
                updatedAt: new Date(),
              },
            });
        }
      }
    }

    await logAdminAction({
      adminUserId: admin.id,
      action: 'ARTICLE_UPDATE',
      entityType: 'article',
      entityId: art.id,
      metadata: { slug },
    });

    return NextResponse.json({ success: true, message: 'Article updated successfully' });
  } catch (err: unknown) {
    if (err instanceof AuthError) {
      return NextResponse.json({ error: err.message }, { status: err.statusCode });
    }
    return NextResponse.json({ error: 'Failed to update article' }, { status: 500 });
  }
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ slug: string }> }
) {
  try {
    const admin = await verifyAdminSession(request, ['superadmin']);
    const { slug } = await params;

    const [art] = await db
      .select()
      .from(articles)
      .where(eq(articles.slug, slug))
      .limit(1);

    if (!art) {
      return NextResponse.json({ error: 'Article not found' }, { status: 404 });
    }

    await db.delete(articles).where(eq(articles.id, art.id));

    await logAdminAction({
      adminUserId: admin.id,
      action: 'ARTICLE_DELETE',
      entityType: 'article',
      entityId: art.id,
      metadata: { slug },
    });

    return NextResponse.json({ success: true, message: 'Article deleted successfully' });
  } catch (err: unknown) {
    if (err instanceof AuthError) {
      return NextResponse.json({ error: err.message }, { status: err.statusCode });
    }
    return NextResponse.json({ error: 'Failed to delete article' }, { status: 500 });
  }
}
