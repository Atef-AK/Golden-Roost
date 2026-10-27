import { MetadataRoute } from 'next';
import { db } from '@/db';
import { articles, products } from '@/db/schema';
import { eq } from 'drizzle-orm';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const baseUrl = 'https://goldenroost.com';

  const staticRoutes: MetadataRoute.Sitemap = [
    { url: baseUrl, lastModified: new Date(), changeFrequency: 'daily', priority: 1.0 },
    { url: `${baseUrl}/articles`, lastModified: new Date(), changeFrequency: 'daily', priority: 0.9 },
    { url: `${baseUrl}/products`, lastModified: new Date(), changeFrequency: 'weekly', priority: 0.8 },
    { url: `${baseUrl}/about`, lastModified: new Date(), changeFrequency: 'monthly', priority: 0.6 },
    { url: `${baseUrl}/contact`, lastModified: new Date(), changeFrequency: 'monthly', priority: 0.5 },
    { url: `${baseUrl}/privacy`, lastModified: new Date(), changeFrequency: 'monthly', priority: 0.4 },
    { url: `${baseUrl}/delete-account`, lastModified: new Date(), changeFrequency: 'monthly', priority: 0.3 },
  ];

  try {
    const publishedArticles = await db
      .select({ slug: articles.slug, updatedAt: articles.updatedAt })
      .from(articles)
      .where(eq(articles.isPublished, true));

    const articleUrls: MetadataRoute.Sitemap = publishedArticles.map((art) => ({
      url: `${baseUrl}/articles/${art.slug}`,
      lastModified: art.updatedAt,
      changeFrequency: 'weekly',
      priority: 0.8,
    }));

    const publishedProducts = await db
      .select({ slug: products.slug, updatedAt: products.updatedAt })
      .from(products)
      .where(eq(products.isPublished, true));

    const productUrls: MetadataRoute.Sitemap = publishedProducts.map((prod) => ({
      url: `${baseUrl}/products/${prod.slug}`,
      lastModified: prod.updatedAt,
      changeFrequency: 'weekly',
      priority: 0.7,
    }));

    return [...staticRoutes, ...articleUrls, ...productUrls];
  } catch {
    return staticRoutes;
  }
}
