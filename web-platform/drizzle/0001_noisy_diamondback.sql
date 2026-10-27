ALTER TABLE "notification_campaigns" ADD COLUMN "campaign_type" text DEFAULT 'announcement' NOT NULL;--> statement-breakpoint
ALTER TABLE "notification_campaigns" ADD COLUMN "target_locale" text DEFAULT 'all';--> statement-breakpoint
ALTER TABLE "notification_campaigns" ADD COLUMN "locked_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "notification_campaigns" ADD COLUMN "completed_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "push_devices" ADD COLUMN "marketing_opt_in" boolean DEFAULT false NOT NULL;--> statement-breakpoint
ALTER TABLE "push_devices" ADD COLUMN "article_alerts_opt_in" boolean DEFAULT true NOT NULL;--> statement-breakpoint
ALTER TABLE "push_devices" ADD COLUMN "disease_alerts_opt_in" boolean DEFAULT true NOT NULL;