import {
  pgTable,
  text,
  timestamp,
  boolean,
  integer,
  numeric,
  jsonb,
  uniqueIndex,
} from 'drizzle-orm/pg-core';
import { relations } from 'drizzle-orm';

// --- Admin Users & RBAC ---
export const adminUsers = pgTable('admin_users', {
  id: text('id')
    .primaryKey()
    .$defaultFn(() => crypto.randomUUID()),
  email: text('email').notNull().unique(),
  firebaseUid: text('firebase_uid').notNull().unique(),
  role: text('role').notNull().default('viewer'), // 'superadmin' | 'editor' | 'veterinarian' | 'viewer'
  displayName: text('display_name'),
  isActive: boolean('is_active').notNull().default(true),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
});

export const adminAuditLogs = pgTable('admin_audit_logs', {
  id: text('id')
    .primaryKey()
    .$defaultFn(() => crypto.randomUUID()),
  adminUserId: text('admin_user_id').references(() => adminUsers.id),
  action: text('action').notNull(),
  entityType: text('entity_type').notNull(),
  entityId: text('entity_id'),
  metadata: jsonb('metadata'),
  ipAddress: text('ip_address'),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
});

// --- CMS Articles & Knowledge Base ---
export const articles = pgTable('articles', {
  id: text('id')
    .primaryKey()
    .$defaultFn(() => crypto.randomUUID()),
  slug: text('slug').notNull().unique(),
  category: text('category').notNull(), // 'disease_guide' | 'housing' | 'incubation' | 'nutrition' | 'general'
  isPublished: boolean('is_published').notNull().default(false),
  featuredImageUrl: text('featured_image_url'),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
});

export const articleTranslations = pgTable(
  'article_translations',
  {
    id: text('id')
      .primaryKey()
      .$defaultFn(() => crypto.randomUUID()),
    articleId: text('article_id')
      .notNull()
      .references(() => articles.id, { onDelete: 'cascade' }),
    locale: text('locale').notNull(), // 'en' | 'fr' | 'ar'
    title: text('title').notNull(),
    summary: text('summary').notNull(),
    content: text('content').notNull(),
    createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex('article_locale_unique_idx').on(table.articleId, table.locale),
  ]
);

// --- Product Catalogue & Affiliates ---
export const products = pgTable('products', {
  id: text('id')
    .primaryKey()
    .$defaultFn(() => crypto.randomUUID()),
  slug: text('slug').notNull().unique(),
  category: text('category').notNull(), // 'feed' | 'equipment' | 'medication' | 'hygiene' | 'incubation'
  affiliatePlatform: text('affiliate_platform').notNull(), // 'amazon' | 'jumia' | 'direct'
  affiliateUrl: text('affiliate_url').notNull(),
  priceDisplay: text('price_display'),
  imageUrl: text('image_url'),
  rating: numeric('rating', { precision: 3, scale: 2 }).default('4.80'),
  isPublished: boolean('is_published').notNull().default(true),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
});

export const productTranslations = pgTable(
  'product_translations',
  {
    id: text('id')
      .primaryKey()
      .$defaultFn(() => crypto.randomUUID()),
    productId: text('product_id')
      .notNull()
      .references(() => products.id, { onDelete: 'cascade' }),
    locale: text('locale').notNull(), // 'en' | 'fr' | 'ar'
    name: text('name').notNull(),
    description: text('description').notNull(),
    createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
    updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex('product_locale_unique_idx').on(table.productId, table.locale),
  ]
);

// --- Push Devices & FCM Notifications ---
export const pushDevices = pgTable('push_devices', {
  id: text('id')
    .primaryKey()
    .$defaultFn(() => crypto.randomUUID()),
  fcmToken: text('fcm_token').notNull().unique(),
  deviceId: text('device_id'),
  platform: text('platform').notNull().default('android'), // 'android' | 'ios' | 'web'
  locale: text('locale').notNull().default('en'),
  topics: jsonb('topics').notNull().default('[]'),
  marketingOptIn: boolean('marketing_opt_in').notNull().default(false),
  articleAlertsOptIn: boolean('article_alerts_opt_in').notNull().default(true),
  diseaseAlertsOptIn: boolean('disease_alerts_opt_in').notNull().default(true),
  isActive: boolean('is_active').notNull().default(true),
  lastSeenAt: timestamp('last_seen_at', { withTimezone: true }).notNull().defaultNow(),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
});

export const notificationCampaigns = pgTable('notification_campaigns', {
  id: text('id')
    .primaryKey()
    .$defaultFn(() => crypto.randomUUID()),
  title: text('title').notNull(),
  body: text('body').notNull(),
  campaignType: text('campaign_type').notNull().default('announcement'), // 'announcement' | 'article_alert' | 'disease_alert' | 'marketing'
  targetLocale: text('target_locale').default('all'), // 'all' | 'en' | 'fr' | 'ar'
  targetTopic: text('target_topic'),
  dataPayload: jsonb('data_payload'),
  status: text('status').notNull().default('draft'), // 'draft' | 'scheduled' | 'processing' | 'completed' | 'failed'
  scheduledAt: timestamp('scheduled_at', { withTimezone: true }),
  lockedAt: timestamp('locked_at', { withTimezone: true }),
  completedAt: timestamp('completed_at', { withTimezone: true }),
  sentCount: integer('sent_count').notNull().default(0),
  failedCount: integer('failed_count').notNull().default(0),
  createdBy: text('created_by').references(() => adminUsers.id),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
});

export const notificationDeliveries = pgTable(
  'notification_deliveries',
  {
    id: text('id')
      .primaryKey()
      .$defaultFn(() => crypto.randomUUID()),
    campaignId: text('campaign_id')
      .notNull()
      .references(() => notificationCampaigns.id, { onDelete: 'cascade' }),
    deviceId: text('device_id')
      .notNull()
      .references(() => pushDevices.id, { onDelete: 'cascade' }),
    fcmMessageId: text('fcm_message_id'),
    status: text('status').notNull(), // 'sent' | 'failed'
    errorCode: text('error_code'),
    sentAt: timestamp('sent_at', { withTimezone: true }).notNull().defaultNow(),
  },
  (table) => [
    uniqueIndex('campaign_device_delivery_unique_idx').on(
      table.campaignId,
      table.deviceId
    ),
  ]
);

// --- Task Scheduler ---
export const scheduledTasks = pgTable('scheduled_tasks', {
  id: text('id')
    .primaryKey()
    .$defaultFn(() => crypto.randomUUID()),
  taskType: text('task_type').notNull(),
  payload: jsonb('payload'),
  status: text('status').notNull().default('pending'), // 'pending' | 'processing' | 'completed' | 'failed'
  scheduledFor: timestamp('scheduled_for', { withTimezone: true }).notNull(),
  lockedAt: timestamp('locked_at', { withTimezone: true }),
  completedAt: timestamp('completed_at', { withTimezone: true }),
  errorMessage: text('error_message'),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
});

// --- Verified Account Deletion (Google Play Compliance) ---
export const accountDeletionRequests = pgTable('account_deletion_requests', {
  id: text('id')
    .primaryKey()
    .$defaultFn(() => crypto.randomUUID()),
  email: text('email').notNull(),
  verificationToken: text('verification_token').notNull().unique(),
  tokenExpiresAt: timestamp('token_expires_at', { withTimezone: true }).notNull(),
  status: text('status').notNull().default('pending_verification'), // 'pending_verification' | 'verified' | 'processing' | 'completed' | 'cancelled'
  verifiedAt: timestamp('verified_at', { withTimezone: true }),
  completedAt: timestamp('completed_at', { withTimezone: true }),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
});

// --- Database-Backed Rate Limiting (Serverless Safe) ---
export const rateLimitBuckets = pgTable('rate_limit_buckets', {
  key: text('key').primaryKey(),
  count: integer('count').notNull().default(1),
  expiresAt: timestamp('expires_at', { withTimezone: true }).notNull(),
});

// --- Monetization Settings ---
export const monetizationSettings = pgTable('monetization_settings', {
  id: text('id').primaryKey().default('global'),
  adsenseEnabled: boolean('adsense_enabled').notNull().default(false),
  adsensePublisherId: text('adsense_publisher_id'),
  admobEnabled: boolean('admob_enabled').notNull().default(false),
  admobBannerId: text('admob_banner_id'),
  admobInterstitialId: text('admob_interstitial_id'),
  updatedAt: timestamp('updated_at', { withTimezone: true }).notNull().defaultNow(),
});

// --- Drizzle Relations ---
export const adminUsersRelations = relations(adminUsers, ({ many }) => ({
  auditLogs: many(adminAuditLogs),
  campaigns: many(notificationCampaigns),
}));

export const articlesRelations = relations(articles, ({ many }) => ({
  translations: many(articleTranslations),
}));

export const articleTranslationsRelations = relations(articleTranslations, ({ one }) => ({
  article: one(articles, {
    fields: [articleTranslations.articleId],
    references: [articles.id],
  }),
}));

export const productsRelations = relations(products, ({ many }) => ({
  translations: many(productTranslations),
}));

export const productTranslationsRelations = relations(productTranslations, ({ one }) => ({
  product: one(products, {
    fields: [productTranslations.productId],
    references: [products.id],
  }),
}));

export const notificationCampaignsRelations = relations(
  notificationCampaigns,
  ({ one, many }) => ({
    creator: one(adminUsers, {
      fields: [notificationCampaigns.createdBy],
      references: [adminUsers.id],
    }),
    deliveries: many(notificationDeliveries),
  })
);

export const notificationDeliveriesRelations = relations(
  notificationDeliveries,
  ({ one }) => ({
    campaign: one(notificationCampaigns, {
      fields: [notificationDeliveries.campaignId],
      references: [notificationCampaigns.id],
    }),
    device: one(pushDevices, {
      fields: [notificationDeliveries.deviceId],
      references: [pushDevices.id],
    }),
  })
);
