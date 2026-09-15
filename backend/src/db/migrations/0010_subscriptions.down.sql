-- 0010_subscriptions.down.sql
DROP TABLE IF EXISTS subscriptions CASCADE;
DROP TYPE IF EXISTS sub_status;
DROP TYPE IF EXISTS sub_provider;
DROP TYPE IF EXISTS sub_plan;
