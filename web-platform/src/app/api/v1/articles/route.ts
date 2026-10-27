import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/db';
import { articles, articleTranslations } from '@/db/schema';
import { eq, and, desc } from 'drizzle-orm';
import { verifyAdminSession, AuthError } from '@/lib/auth';
import { logAdminAction } from '@/lib/audit';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const locale = searchParams.get('locale') || 'en';
    const category = searchParams.get('category');
    const includeDrafts = searchParams.get('include_drafts') === 'true';

    // If client requests drafts, verify admin credentials
    if (includeDrafts) {
      await verifyAdminSession(request, ['superadmin', 'editor', 'veterinarian', 'viewer']);
    }

    const conditions = [];
    if (!includeDrafts) {
      conditions.push(eq(articles.isPublished, true));
    }
    if (category) {
      conditions.push(eq(articles.category, category));
    }

    const rawArticles = await db
      .select({
        id: articles.id,
        slug: articles.slug,
        category: articles.category,
        featuredImageUrl: articles.featuredImageUrl,
        isPublished: articles.isPublished,
        createdAt: articles.createdAt,
        updatedAt: articles.updatedAt,
      })
      .from(articles)
      .where(conditions.length > 0 ? and(...conditions) : undefined)
      .orderBy(desc(articles.createdAt));

    // Fetch translations for articles
    const articleIds = rawArticles.map((a) => a.id);
    let translationsList: (typeof articleTranslations.$inferSelect)[] = [];

    if (articleIds.length > 0) {
      translationsList = await db.select().from(articleTranslations);
    }

    const items = rawArticles.map((art) => {
      const allTrans = translationsList.filter((t) => t.articleId === art.id);
      const selectedTrans =
        allTrans.find((t) => t.locale === locale) ||
        allTrans.find((t) => t.locale === 'en') ||
        allTrans[0];

      return {
        ...art,
        title: selectedTrans?.title || art.slug,
        summary: selectedTrans?.summary || '',
        content: selectedTrans?.content || '',
        translations: allTrans.map((t) => ({
          locale: t.locale,
          title: t.title,
          summary: t.summary,
        })),
      };
    });

    return NextResponse.json({
      success: true,
      count: items.length,
      data: items,
    });
  } catch (err: unknown) {
    if (err instanceof AuthError) {
      return NextResponse.json({ error: err.message }, { status: err.statusCode });
    }
    console.error('Error fetching articles:', err);
    return NextResponse.json({ error: 'Failed to fetch articles' }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  try {
    const admin = await verifyAdminSession(request, ['superadmin', 'editor', 'veterinarian']);
    const body = await request.json();
    const { slug, category, featuredImageUrl, isPublished, translations } = body;

    if (!slug || !category || !translations || !Array.isArray(translations)) {
      return NextResponse.json(
        { error: 'Missing required fields: slug, category, translations array' },
        { status: 400 }
      );
    }

    // Insert main article
    const [inserted] = await db
      .insert(articles)
      .values({
        slug: slug.toLowerCase().trim(),
        category,
        featuredImageUrl,
        isPublished: !!isPublished,
      })
      .returning();

    // Insert translations
    for (const trans of translations) {
      if (trans.locale && trans.title) {
        await db.insert(articleTranslations).values({
          articleId: inserted.id,
          locale: trans.locale,
          title: trans.title,
          summary: trans.summary || '',
          content: trans.content || '',
        });
      }
    }

    await logAdminAction({
      adminUserId: admin.id,
      action: 'ARTICLE_CREATE',
      entityType: 'article',
      entityId: inserted.id,
      metadata: { slug: inserted.slug, category: inserted.category },
    });

    return NextResponse.json({ success: true, data: inserted }, { status: 201 });
  } catch (err: unknown) {
    if (err instanceof AuthError) {
      return NextResponse.json({ error: err.message }, { status: err.statusCode });
    }
    console.error('Error creating article:', err);
    return NextResponse.json(
      { error: err instanceof Error ? err.message : 'Failed to create article' },
      { status: 500 }
    );
  }
}
