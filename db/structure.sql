CREATE TABLE IF NOT EXISTS "schema_migrations" ("version" varchar NOT NULL PRIMARY KEY);
CREATE TABLE IF NOT EXISTS "ar_internal_metadata" ("key" varchar NOT NULL PRIMARY KEY, "value" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "users" ("id" uuid NOT NULL PRIMARY KEY, "slug" varchar, "email_address" varchar NOT NULL, "password_digest" varchar NOT NULL, "username" varchar, "name" varchar, "last_login_at" datetime(6), "last_login_ip" varchar, "is_active" boolean DEFAULT 1 NOT NULL, "session_stamp" integer DEFAULT 0 NOT NULL, "created_by" varchar, "updated_by" varchar, "role" varchar DEFAULT 'member' NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE UNIQUE INDEX "index_users_on_slug" ON "users" ("slug") /*application='CoreDrift'*/;
CREATE UNIQUE INDEX "index_users_on_email_address" ON "users" ("email_address") /*application='CoreDrift'*/;
CREATE UNIQUE INDEX "index_users_on_username" ON "users" ("username") /*application='CoreDrift'*/;
CREATE TABLE IF NOT EXISTS "sessions" ("id" integer PRIMARY KEY AUTOINCREMENT NOT NULL, "user_id" uuid NOT NULL, "ip_address" varchar, "user_agent" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_758836b4f0"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_sessions_on_user_id" ON "sessions" ("user_id") /*application='CoreDrift'*/;
CREATE TABLE IF NOT EXISTS "roles" ("id" uuid NOT NULL PRIMARY KEY, "slug" varchar, "name" varchar, "description" text, "contextual" boolean DEFAULT 0 NOT NULL, "status" varchar, "created_by" varchar, "updated_by" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "permissions" ("id" uuid NOT NULL PRIMARY KEY, "slug" varchar, "name" varchar, "description" text, "created_by" varchar, "updated_by" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "resources" ("id" uuid NOT NULL PRIMARY KEY, "slug" varchar, "name" varchar, "description" text, "label" varchar, "kind" varchar, "value" varchar, "created_by" varchar, "updated_by" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE TABLE IF NOT EXISTS "user_roles" ("id" uuid NOT NULL PRIMARY KEY, "user_id" uuid NOT NULL, "role_id" uuid NOT NULL, "context_type" varchar, "context_id" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_318345354e"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_3369e0d5fc"
FOREIGN KEY ("role_id")
  REFERENCES "roles" ("id")
);
CREATE INDEX "index_user_roles_on_user_id" ON "user_roles" ("user_id") /*application='CoreDrift'*/;
CREATE INDEX "index_user_roles_on_role_id" ON "user_roles" ("role_id") /*application='CoreDrift'*/;
CREATE INDEX "index_user_roles_on_context_id" ON "user_roles" ("context_id") /*application='CoreDrift'*/;
CREATE TABLE IF NOT EXISTS "user_permissions" ("id" uuid NOT NULL PRIMARY KEY, "user_id" uuid NOT NULL, "permission_id" uuid NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_b29e483ce4"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
, CONSTRAINT "fk_rails_e2cb0687d2"
FOREIGN KEY ("permission_id")
  REFERENCES "permissions" ("id")
);
CREATE INDEX "index_user_permissions_on_user_id" ON "user_permissions" ("user_id") /*application='CoreDrift'*/;
CREATE INDEX "index_user_permissions_on_permission_id" ON "user_permissions" ("permission_id") /*application='CoreDrift'*/;
CREATE TABLE IF NOT EXISTS "role_permissions" ("id" uuid NOT NULL PRIMARY KEY, "role_id" uuid NOT NULL, "permission_id" uuid NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_60126080bd"
FOREIGN KEY ("role_id")
  REFERENCES "roles" ("id")
, CONSTRAINT "fk_rails_439e640a3f"
FOREIGN KEY ("permission_id")
  REFERENCES "permissions" ("id")
);
CREATE INDEX "index_role_permissions_on_role_id" ON "role_permissions" ("role_id") /*application='CoreDrift'*/;
CREATE INDEX "index_role_permissions_on_permission_id" ON "role_permissions" ("permission_id") /*application='CoreDrift'*/;
CREATE TABLE IF NOT EXISTS "resource_permissions" ("id" uuid NOT NULL PRIMARY KEY, "resource_id" uuid NOT NULL, "permission_id" uuid NOT NULL, "created_by" varchar, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_40f1b0915d"
FOREIGN KEY ("resource_id")
  REFERENCES "resources" ("id")
, CONSTRAINT "fk_rails_c75cdca582"
FOREIGN KEY ("permission_id")
  REFERENCES "permissions" ("id")
);
CREATE INDEX "index_resource_permissions_on_resource_id" ON "resource_permissions" ("resource_id") /*application='CoreDrift'*/;
CREATE INDEX "index_resource_permissions_on_permission_id" ON "resource_permissions" ("permission_id") /*application='CoreDrift'*/;
CREATE TABLE IF NOT EXISTS "organizations" ("id" uuid NOT NULL PRIMARY KEY, "slug" varchar NOT NULL, "name" varchar NOT NULL, "short_description" varchar, "description" text, "owner_id" uuid NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_ab574863f6"
FOREIGN KEY ("owner_id")
  REFERENCES "users" ("id")
);
CREATE UNIQUE INDEX "index_organizations_on_slug" ON "organizations" ("slug") /*application='CoreDrift'*/;
CREATE INDEX "index_organizations_on_owner_id" ON "organizations" ("owner_id") /*application='CoreDrift'*/;
CREATE TABLE IF NOT EXISTS "organization_owners" ("id" uuid NOT NULL PRIMARY KEY, "organization_id" uuid NOT NULL, "user_id" uuid NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_66d632ca5d"
FOREIGN KEY ("organization_id")
  REFERENCES "organizations" ("id")
, CONSTRAINT "fk_rails_4bcdea61fb"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_organization_owners_on_organization_id" ON "organization_owners" ("organization_id") /*application='CoreDrift'*/;
CREATE INDEX "index_organization_owners_on_user_id" ON "organization_owners" ("user_id") /*application='CoreDrift'*/;
CREATE TABLE IF NOT EXISTS "teams" ("id" uuid NOT NULL PRIMARY KEY, "organization_id" uuid NOT NULL, "slug" varchar NOT NULL, "name" varchar NOT NULL, "description" text, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_f07f0bd66d"
FOREIGN KEY ("organization_id")
  REFERENCES "organizations" ("id")
);
CREATE INDEX "index_teams_on_organization_id" ON "teams" ("organization_id") /*application='CoreDrift'*/;
CREATE UNIQUE INDEX "index_teams_on_slug" ON "teams" ("slug") /*application='CoreDrift'*/;
CREATE TABLE IF NOT EXISTS "team_memberships" ("id" uuid NOT NULL PRIMARY KEY, "team_id" uuid NOT NULL, "user_id" uuid NOT NULL, "relation_type" varchar DEFAULT 'direct' NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_61c29b529e"
FOREIGN KEY ("team_id")
  REFERENCES "teams" ("id")
, CONSTRAINT "fk_rails_5aba9331a7"
FOREIGN KEY ("user_id")
  REFERENCES "users" ("id")
);
CREATE INDEX "index_team_memberships_on_team_id" ON "team_memberships" ("team_id") /*application='CoreDrift'*/;
CREATE INDEX "index_team_memberships_on_user_id" ON "team_memberships" ("user_id") /*application='CoreDrift'*/;
CREATE UNIQUE INDEX "index_team_memberships_on_team_id_and_user_id" ON "team_memberships" ("team_id", "user_id") /*application='CoreDrift'*/;
CREATE TABLE IF NOT EXISTS "daily_setups" ("id" uuid NOT NULL PRIMARY KEY, "team_id" uuid NOT NULL, "slug" varchar NOT NULL, "name" varchar NOT NULL, "description" text, "visible_at" varchar DEFAULT '09:30' NOT NULL, "reminder_at" varchar DEFAULT '09:00' NOT NULL, "daily_report_time" varchar DEFAULT '10:00' NOT NULL, "weekly_report_day" varchar DEFAULT 'fri' NOT NULL, "weekly_report_time" varchar DEFAULT '17:00' NOT NULL, "sunday" boolean DEFAULT 0 NOT NULL, "monday" boolean DEFAULT 1 NOT NULL, "tuesday" boolean DEFAULT 1 NOT NULL, "wednesday" boolean DEFAULT 1 NOT NULL, "thursday" boolean DEFAULT 1 NOT NULL, "friday" boolean DEFAULT 1 NOT NULL, "saturday" boolean DEFAULT 0 NOT NULL, "template" varchar DEFAULT 'freeform' NOT NULL, "allow_comments" boolean DEFAULT 0 NOT NULL, "active" boolean DEFAULT 1 NOT NULL, "last_reminder_enqueued_at" date, "last_report_enqueued_at" date, "last_weekly_report_enqueued_at" date, "settings" json DEFAULT '{}' NOT NULL, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_095076c604"
FOREIGN KEY ("team_id")
  REFERENCES "teams" ("id")
);
CREATE UNIQUE INDEX "index_daily_setups_on_team_id" ON "daily_setups" ("team_id") /*application='CoreDrift'*/;
CREATE UNIQUE INDEX "index_daily_setups_on_slug" ON "daily_setups" ("slug") /*application='CoreDrift'*/;
CREATE TABLE IF NOT EXISTS "jobs" ("id" uuid NOT NULL PRIMARY KEY, "job_type" varchar NOT NULL, "target_id" uuid NOT NULL, "scheduled_for" datetime(6) NOT NULL, "state" varchar DEFAULT 'pending' NOT NULL, "executed_at" datetime(6), "error_message" text, "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL);
CREATE INDEX "index_jobs_on_target_id" ON "jobs" ("target_id") /*application='CoreDrift'*/;
CREATE UNIQUE INDEX "index_jobs_on_job_type_and_target_id_and_scheduled_for" ON "jobs" ("job_type", "target_id", "scheduled_for") /*application='CoreDrift'*/;
CREATE TABLE IF NOT EXISTS "daily_reports" ("id" uuid NOT NULL PRIMARY KEY, "daily_setup_id" uuid NOT NULL, "team_id" uuid NOT NULL, "date" date NOT NULL, "status" varchar DEFAULT 'active' NOT NULL, "published_at" datetime(6), "created_at" datetime(6) NOT NULL, "updated_at" datetime(6) NOT NULL, CONSTRAINT "fk_rails_71f1442fdb"
FOREIGN KEY ("daily_setup_id")
  REFERENCES "daily_setups" ("id")
, CONSTRAINT "fk_rails_036bd75579"
FOREIGN KEY ("team_id")
  REFERENCES "teams" ("id")
);
CREATE INDEX "index_daily_reports_on_daily_setup_id" ON "daily_reports" ("daily_setup_id") /*application='CoreDrift'*/;
CREATE INDEX "index_daily_reports_on_team_id" ON "daily_reports" ("team_id") /*application='CoreDrift'*/;
CREATE UNIQUE INDEX "index_daily_reports_on_daily_setup_id_and_date" ON "daily_reports" ("daily_setup_id", "date") /*application='CoreDrift'*/;
CREATE TABLE IF NOT EXISTS "dailies" (
  "id"  NOT NULL PRIMARY KEY,
  "user_id" uuid NOT NULL,
  "team_id"  NOT NULL,
  "daily_setup_id"  NOT NULL,
  "date" date NOT NULL,
  "visible_at" datetime(6) NOT NULL,
  "reminder_at" time NOT NULL,
  "daily_report_time" time NOT NULL,
  "freeform" text,
  "yesterday" text,
  "today" text,
  "blockers" text,
  "created_at" datetime(6) NOT NULL,
  "updated_at" datetime(6) NOT NULL,
  "daily_report_id" ,
  CONSTRAINT "fk_rails_1531978b37" FOREIGN KEY ("daily_setup_id") REFERENCES "daily_setups" ("id"),
  CONSTRAINT "fk_rails_0e73d48216" FOREIGN KEY ("team_id") REFERENCES "teams" ("id"),
  CONSTRAINT "fk_rails_3cf38b4ca8" FOREIGN KEY ("daily_report_id") REFERENCES "daily_reports" ("id"),
  CONSTRAINT "fk_rails_758836b4f0" FOREIGN KEY ("user_id") REFERENCES "users" ("id")
);
CREATE INDEX "index_dailies_on_team_id" ON "dailies" ("team_id") /*application='CoreDrift'*/;
CREATE INDEX "index_dailies_on_daily_setup_id" ON "dailies" ("daily_setup_id") /*application='CoreDrift'*/;
CREATE UNIQUE INDEX "index_dailies_on_user_date_setup" ON "dailies" ("user_id", "date", "daily_setup_id") /*application='CoreDrift'*/;
CREATE INDEX "index_dailies_on_daily_report_id" ON "dailies" ("daily_report_id") /*application='CoreDrift'*/;
CREATE INDEX "index_dailies_on_user_id" ON "dailies" ("user_id") /*application='CoreDrift'*/;
INSERT INTO "schema_migrations" (version) VALUES
('20250603132445'),
('20250525204549'),
('20250514205611'),
('20250514142620'),
('20250513180001'),
('20250513180000'),
('20250513130448'),
('20250513124245'),
('20250511083048'),
('20250511081517'),
('20250511081430'),
('20250511081330'),
('20250511080256'),
('20250511075928'),
('20250511075822'),
('20250510130342'),
('20250510130341');

