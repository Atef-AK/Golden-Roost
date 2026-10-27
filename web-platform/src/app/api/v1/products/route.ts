import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/db';
import { products, productTranslations } from '@/db/schema';
import { eq, and, desc } from 'drizzle-orm';
import { verifyAdminSession, AuthError } from '@/lib/auth';
import { logAdminAction } from '@/lib/audit';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const locale = searchParams.get('locale') || 'en';
    const category = searchParams.get('category');
    const includeUnpublished = searchParams.get('include_unpublished') === 'true';

    if (includeUnpublished) {
      await verifyAdminSession(request, ['superadmin', 'editor', 'viewer']);
    }

    const conditions = [];
    if (!includeUnpublished) {
      conditions.push(eq(products.isPublished, true));
    }
    if (category) {
      conditions.push(eq(products.category, category));
    }

    const rawProducts = await db
      .select()
      .from(products)
      .where(conditions.length > 0 ? and(...conditions) : undefined)
      .orderBy(desc(products.createdAt));

    const productIds = rawProducts.map((p) => p.id);
    let translationsList: (typeof productTranslations.$inferSelect)[] = [];

    if (productIds.length > 0) {
      translationsList = await db.select().from(productTranslations);
    }

    const items = rawProducts.map((prod) => {
      const allTrans = translationsList.filter((t) => t.productId === prod.id);
      const selectedTrans =
        allTrans.find((t) => t.locale === locale) ||
        allTrans.find((t) => t.locale === 'en') ||
        allTrans[0];

      return {
        ...prod,
        name: selectedTrans?.name || prod.slug,
        description: selectedTrans?.description || '',
        translations: allTrans.map((t) => ({
          locale: t.locale,
          name: t.name,
          description: t.description,
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
    console.error('Error fetching products:', err);
    return NextResponse.json({ error: 'Failed to fetch products' }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  try {
    const admin = await verifyAdminSession(request, ['superadmin', 'editor']);
    const body = await request.json();
    const {
      slug,
      category,
      affiliatePlatform,
      affiliateUrl,
      priceDisplay,
      imageUrl,
      rating,
      isPublished,
      translations,
    } = body;

    if (!slug || !category || !affiliatePlatform || !affiliateUrl || !translations) {
      return NextResponse.json(
        { error: 'Missing required product fields: slug, category, affiliatePlatform, affiliateUrl, translations' },
        { status: 400 }
      );
    }

    // Insert main product
    const [inserted] = await db
      .insert(products)
      .values({
        slug: slug.toLowerCase().trim(),
        category,
        affiliatePlatform,
        affiliateUrl,
        priceDisplay,
        imageUrl,
        rating: rating || '4.80',
        isPublished: isPublished !== undefined ? !!isPublished : true,
      })
      .returning();

    // Insert translations
    for (const trans of translations) {
      if (trans.locale && trans.name) {
        await db.insert(productTranslations).values({
          productId: inserted.id,
          locale: trans.locale,
          name: trans.name,
          description: trans.description || '',
        });
      }
    }

    await logAdminAction({
      adminUserId: admin.id,
      action: 'PRODUCT_CREATE',
      entityType: 'product',
      entityId: inserted.id,
      metadata: { slug: inserted.slug, category: inserted.category },
    });

    return NextResponse.json({ success: true, data: inserted }, { status: 201 });
  } catch (err: unknown) {
    if (err instanceof AuthError) {
      return NextResponse.json({ error: err.message }, { status: err.statusCode });
    }
    console.error('Error creating product:', err);
    return NextResponse.json(
      { error: err instanceof Error ? err.message : 'Failed to create product' },
      { status: 500 }
    );
  }
}
