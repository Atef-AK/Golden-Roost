import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/db';
import { products, productTranslations } from '@/db/schema';
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

    const [prod] = await db
      .select()
      .from(products)
      .where(eq(products.slug, slug))
      .limit(1);

    if (!prod) {
      return NextResponse.json({ error: 'Product not found' }, { status: 404 });
    }

    const translations = await db
      .select()
      .from(productTranslations)
      .where(eq(productTranslations.productId, prod.id));

    const selectedTrans =
      translations.find((t) => t.locale === locale) ||
      translations.find((t) => t.locale === 'en') ||
      translations[0];

    return NextResponse.json({
      success: true,
      data: {
        ...prod,
        name: selectedTrans?.name || prod.slug,
        description: selectedTrans?.description || '',
        translations: translations.map((t) => ({
          locale: t.locale,
          name: t.name,
          description: t.description,
        })),
      },
    });
  } catch (err) {
    console.error('Error fetching product by slug:', err);
    return NextResponse.json({ error: 'Failed to fetch product' }, { status: 500 });
  }
}

export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ slug: string }> }
) {
  try {
    const admin = await verifyAdminSession(request, ['superadmin', 'editor']);
    const { slug } = await params;
    const body = await request.json();
    const {
      category,
      affiliatePlatform,
      affiliateUrl,
      priceDisplay,
      imageUrl,
      rating,
      isPublished,
      translations,
    } = body;

    const [prod] = await db
      .select()
      .from(products)
      .where(eq(products.slug, slug))
      .limit(1);

    if (!prod) {
      return NextResponse.json({ error: 'Product not found' }, { status: 404 });
    }

    await db
      .update(products)
      .set({
        category: category ?? prod.category,
        affiliatePlatform: affiliatePlatform ?? prod.affiliatePlatform,
        affiliateUrl: affiliateUrl ?? prod.affiliateUrl,
        priceDisplay: priceDisplay ?? prod.priceDisplay,
        imageUrl: imageUrl ?? prod.imageUrl,
        rating: rating ?? prod.rating,
        isPublished: isPublished !== undefined ? !!isPublished : prod.isPublished,
        updatedAt: new Date(),
      })
      .where(eq(products.id, prod.id));

    if (translations && Array.isArray(translations)) {
      for (const trans of translations) {
        if (trans.locale && trans.name) {
          await db
            .insert(productTranslations)
            .values({
              productId: prod.id,
              locale: trans.locale,
              name: trans.name,
              description: trans.description || '',
            })
            .onConflictDoUpdate({
              target: [productTranslations.productId, productTranslations.locale],
              set: {
                name: trans.name,
                description: trans.description || '',
                updatedAt: new Date(),
              },
            });
        }
      }
    }

    await logAdminAction({
      adminUserId: admin.id,
      action: 'PRODUCT_UPDATE',
      entityType: 'product',
      entityId: prod.id,
      metadata: { slug },
    });

    return NextResponse.json({ success: true, message: 'Product updated successfully' });
  } catch (err: unknown) {
    if (err instanceof AuthError) {
      return NextResponse.json({ error: err.message }, { status: err.statusCode });
    }
    return NextResponse.json({ error: 'Failed to update product' }, { status: 500 });
  }
}

export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ slug: string }> }
) {
  try {
    const admin = await verifyAdminSession(request, ['superadmin']);
    const { slug } = await params;

    const [prod] = await db
      .select()
      .from(products)
      .where(eq(products.slug, slug))
      .limit(1);

    if (!prod) {
      return NextResponse.json({ error: 'Product not found' }, { status: 404 });
    }

    await db.delete(products).where(eq(products.id, prod.id));

    await logAdminAction({
      adminUserId: admin.id,
      action: 'PRODUCT_DELETE',
      entityType: 'product',
      entityId: prod.id,
      metadata: { slug },
    });

    return NextResponse.json({ success: true, message: 'Product deleted successfully' });
  } catch (err: unknown) {
    if (err instanceof AuthError) {
      return NextResponse.json({ error: err.message }, { status: err.statusCode });
    }
    return NextResponse.json({ error: 'Failed to delete product' }, { status: 500 });
  }
}
