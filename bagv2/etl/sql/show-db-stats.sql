-- Show DB table and schema stats
-- psql -f sql/show-db-stats.sql bagv2
--
-- Author: Just van den Broecke
--

-- Schema sizes
SELECT schema, pg_size_pretty(total_size) AS "total_size"
FROM (
  SELECT nspname AS "schema", SUM(pg_total_relation_size(C.oid))::bigint AS "total_size"
  FROM pg_class C
  LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
  WHERE C.relkind <> 'i'
    AND nspname !~ '^pg_toast'  AND nspname !~ '^pg_catalog'  AND nspname !~ '^information_schema'
  GROUP BY nspname)
AS schemasizes
ORDER BY schema;


-- Row counts per schema en per tabel
SELECT
  nspname AS schemaname,relname,reltuples
FROM pg_class C
LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
WHERE
  nspname NOT IN ('pg_toast', 'pg_catalog', 'information_schema') AND
  relkind='r'
ORDER BY schemaname,reltuples DESC;


-- Schema overzicht
-- SELECT nspname AS "schema"
--   FROM pg_class C
--   LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
--   WHERE C.relkind <> 'i'
--     AND nspname !~ '^pg_toast'  AND nspname !~ '^pg_catalog'  AND nspname !~ '^information_schema'
--   GROUP BY nspname;


-- Functie voor schema size:
-- bijv select pg_size_pretty(pg_schema_size('public'));
-- CREATE OR REPLACE FUNCTION pg_schema_size(text) returns bigint AS $$
-- SELECT sum(pg_relation_size(quote_ident(schemaname) || '.' || quote_ident(tablename)))::bigint FROM pg_tables WHERE schemaname = $1
-- $$ LANGUAGE sql;
--
-- -- Functie voor top50 verschillende sizes in schema
-- -- Adapted from https://wiki.postgresql.org/wiki/Disk_Usage
-- -- select pg_schema_size_details('bagactueel');
-- CREATE OR REPLACE FUNCTION pg_schema_size_details(text) returns TABLE (relation text, size text)
-- AS $$SELECT nspname || '.' || relname AS "relation",
--     pg_size_pretty(pg_relation_size(C.oid)) AS "size"
--   FROM pg_class C
--   LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
--   WHERE nspname = $1
--   ORDER BY pg_relation_size(C.oid) DESC
--   LIMIT 50;
-- $$ LANGUAGE sql;
