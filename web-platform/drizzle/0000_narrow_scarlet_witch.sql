CREATE TABLE "account_deletion_requests" (
	"id" text PRIMARY KEY NOT NULL,
	"email" text NOT NULL,
	"verification_token" text NOT NULL,
	"token_expires_at" timestamp with time zone NOT NULL,
	"status" text DEFAULT 'pending_verification' NOT NULL,
	"verified_at" timestamp with time zone,
	"completed_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "account_deletion_requests_verification_token_unique" UNIQUE("verification_token")
);
--> statement-breakpoint
CREATE TABLE "admin_audit_logs" (
	"id" text PRIMARY KEY NOT NULL,
	"admin_user_id" text,
	"action" text NOT NULL,
	"entity_type" text NOT NULL,
	"entity_id" text,
	"metadata" jsonb,
	"ip_address" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "admin_users" (
	"id" text PRIMARY KEY NOT NULL,
	"email" text NOT NULL,
	"firebase_uid" text NOT NULL,
	"role" text DEFAULT 'viewer' NOT NULL,
	"display_name" text,
	"is_active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "admin_users_email_unique" UNIQUE("email"),
	CONSTRAINT "admin_users_firebase_uid_unique" UNIQUE("firebase_uid")
);
--> statement-breakpoint
CREATE TABLE "article_translations" (
	"id" text PRIMARY KEY NOT NULL,
	"article_id" text NOT NULL,
	"locale" text NOT NULL,
	"title" text NOT NULL,
	"summary" text NOT NULL,
	"content" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "articles" (
	"id" text PRIMARY KEY NOT NULL,
	"slug" text NOT NULL,
	"category" text NOT NULL,
	"is_published" boolean DEFAULT false NOT NULL,
	"featured_image_url" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "articles_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "monetization_settings" (
	"id" text PRIMARY KEY DEFAULT 'global' NOT NULL,
	"adsense_enabled" boolean DEFAULT false NOT NULL,
	"adsense_publisher_id" text,
	"admob_enabled" boolean DEFAULT false NOT NULL,
	"admob_banner_id" text,
	"admob_interstitial_id" text,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "notification_campaigns" (
	"id" text PRIMARY KEY NOT NULL,
	"title" text NOT NULL,
	"body" text NOT NULL,
	"target_topic" text,
	"data_payload" jsonb,
	"status" text DEFAULT 'draft' NOT NULL,
	"scheduled_at" timestamp with time zone,
	"sent_count" integer DEFAULT 0 NOT NULL,
	"failed_count" integer DEFAULT 0 NOT NULL,
	"created_by" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "notification_deliveries" (
	"id" text PRIMARY KEY NOT NULL,
	"campaign_id" text NOT NULL,
	"device_id" text NOT NULL,
	"fcm_message_id" text,
	"status" text NOT NULL,
	"error_code" text,
	"sent_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "product_translations" (
	"id" text PRIMARY KEY NOT NULL,
	"product_id" text NOT NULL,
	"locale" text NOT NULL,
	"name" text NOT NULL,
	"description" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "products" (
	"id" text PRIMARY KEY NOT NULL,
	"slug" text NOT NULL,
	"category" text NOT NULL,
	"affiliate_platform" text NOT NULL,
	"affiliate_url" text NOT NULL,
	"price_display" text,
	"image_url" text,
	"rating" numeric(3, 2) DEFAULT '4.80',
	"is_published" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "products_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "push_devices" (
	"id" text PRIMARY KEY NOT NULL,
	"fcm_token" text NOT NULL,
	"device_id" text,
	"platform" text DEFAULT 'android' NOT NULL,
	"locale" text DEFAULT 'en' NOT NULL,
	"topics" jsonb DEFAULT '[]' NOT NULL,
	"is_active" boolean DEFAULT true NOT NULL,
	"last_seen_at" timestamp with time zone DEFAULT now() NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "push_devices_fcm_token_unique" UNIQUE("fcm_token")
);
--> statement-breakpoint
CREATE TABLE "rate_limit_buckets" (
	"key" text PRIMARY KEY NOT NULL,
	"count" integer DEFAULT 1 NOT NULL,
	"expires_at" timestamp with time zone NOT NULL
);
--> statement-breakpoint
CREATE TABLE "scheduled_tasks" (
	"id" text PRIMARY KEY NOT NULL,
	"task_type" text NOT NULL,
	"payload" jsonb,
	"status" text DEFAULT 'pending' NOT NULL,
	"scheduled_for" timestamp with time zone NOT NULL,
	"locked_at" timestamp with time zone,
	"completed_at" timestamp with time zone,
	"error_message" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "admin_audit_logs" ADD CONSTRAINT "admin_audit_logs_admin_user_id_admin_users_id_fk" FOREIGN KEY ("admin_user_id") REFERENCES "public"."admin_users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "article_translations" ADD CONSTRAINT "article_translations_article_id_articles_id_fk" FOREIGN KEY ("article_id") REFERENCES "public"."articles"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "notification_campaigns" ADD CONSTRAINT "notification_campaigns_created_by_admin_users_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."admin_users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "notification_deliveries" ADD CONSTRAINT "notification_deliveries_campaign_id_notification_campaigns_id_fk" FOREIGN KEY ("campaign_id") REFERENCES "public"."notification_campaigns"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "notification_deliveries" ADD CONSTRAINT "notification_deliveries_device_id_push_devices_id_fk" FOREIGN KEY ("device_id") REFERENCES "public"."push_devices"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "product_translations" ADD CONSTRAINT "product_translations_product_id_products_id_fk" FOREIGN KEY ("product_id") REFERENCES "public"."products"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "article_locale_unique_idx" ON "article_translations" USING btree ("article_id","locale");--> statement-breakpoint
CREATE UNIQUE INDEX "campaign_device_delivery_unique_idx" ON "notification_deliveries" USING btree ("campaign_id","device_id");--> statement-breakpoint
CREATE UNIQUE INDEX "product_locale_unique_idx" ON "product_translations" USING btree ("product_id","locale");