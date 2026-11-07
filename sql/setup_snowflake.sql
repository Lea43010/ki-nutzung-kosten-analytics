-- ============================================================================
-- Snowflake-Einrichtung für ki-nutzung-kosten-analytics
-- ============================================================================
-- Was passiert hier? (in einfachen Worten)
--   Wir bauen in Snowflake einen "Arbeitsplatz" für das Projekt:
--     1. einen Rechner (Warehouse), der die Abfragen ausführt,
--     2. eine Datenbank mit drei Fächern (Schemas) für drei Reifegrade der Daten,
--     3. Tabellen für die Rohdaten und einen Zwischenspeicher zum Hochladen.
--
-- Ausführen: in Snowflake (Snowsight) ein neues SQL-Worksheet öffnen,
-- den gesamten Inhalt einfügen und "Run all" klicken.
-- Das Skript kann beliebig oft ausgeführt werden (IF NOT EXISTS).
-- ============================================================================

-- Mit der Standardrolle des Testkontos arbeiten, die alles anlegen darf.
USE ROLE ACCOUNTADMIN;

-- ----------------------------------------------------------------------------
-- 1. Rechenleistung: ein kleines Warehouse
--    - Größe XSMALL ist die kleinste und reicht für dieses Projekt.
--    - AUTO_SUSPEND = 60: nach 60 Sekunden ohne Nutzung schaltet es sich ab.
--      So verbrauchen wir kein Guthaben, wenn wir nichts abfragen.
-- ----------------------------------------------------------------------------
CREATE WAREHOUSE IF NOT EXISTS KI_NUTZUNG_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
    COMMENT = 'Rechenleistung für das Projekt ki-nutzung-kosten-analytics';

-- ----------------------------------------------------------------------------
-- 2. Datenbank und drei Schemas
--    RAW      = Rohdaten, genau so, wie sie angeliefert wurden. Nichts wird geändert.
--    STAGING  = bereinigte Daten: Duplikate entfernt, Datentypen korrigiert.
--    MARTS    = fertige Auswertungen für die Fachbereiche.
-- ----------------------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS KI_NUTZUNG
    COMMENT = 'Synthetische Daten zur KI-Nutzung und zu KI-Kosten';

CREATE SCHEMA IF NOT EXISTS KI_NUTZUNG.RAW     COMMENT = 'Rohdaten, unverändert';
CREATE SCHEMA IF NOT EXISTS KI_NUTZUNG.STAGING COMMENT = 'Bereinigte Daten';
CREATE SCHEMA IF NOT EXISTS KI_NUTZUNG.MARTS   COMMENT = 'Auswertungen für Fachbereiche';

USE WAREHOUSE KI_NUTZUNG_WH;
USE SCHEMA KI_NUTZUNG.RAW;

-- ----------------------------------------------------------------------------
-- 3. Dateiformat und Zwischenspeicher zum Hochladen der CSV-Dateien
--    Das Python-Skript lädt die CSV-Dateien zuerst in den Zwischenspeicher
--    (Stage) und kopiert sie von dort in die Tabellen.
-- ----------------------------------------------------------------------------
CREATE FILE FORMAT IF NOT EXISTS CSV_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    NULL_IF = ('')
    EMPTY_FIELD_AS_NULL = TRUE;

CREATE STAGE IF NOT EXISTS RAW_STAGE
    FILE_FORMAT = CSV_FORMAT
    COMMENT = 'Zwischenspeicher für den Upload der CSV-Dateien';

-- ----------------------------------------------------------------------------
-- 4. Rohdaten-Tabellen
--    Bewusst sind alle Spalten Text (VARCHAR). Grund: Die Rohschicht soll
--    nie am Laden scheitern, auch wenn ein Wert fehlerhaft ist.
--    Die Umwandlung in Zahlen und Datumswerte passiert erst im Staging (dbt).
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS DEPARTMENTS (
    department_id    VARCHAR,
    department_name  VARCHAR,
    cost_center      VARCHAR
);

CREATE TABLE IF NOT EXISTS AI_MODELS (
    model_id                  VARCHAR,
    model_name                VARCHAR,
    price_per_1k_input_eur    VARCHAR,
    price_per_1k_output_eur   VARCHAR
);

CREATE TABLE IF NOT EXISTS USERS (
    user_id        VARCHAR,
    department_id  VARCHAR,
    hired_date     VARCHAR,
    left_date      VARCHAR
);

CREATE TABLE IF NOT EXISTS USE_CASES (
    use_case_id            VARCHAR,
    use_case_name          VARCHAR,
    department_id          VARCHAR,
    risk_class             VARCHAR,
    status                 VARCHAR,
    approved_date          VARCHAR,
    documentation_complete VARCHAR
);

CREATE TABLE IF NOT EXISTS USAGE_EVENTS (
    event_id       VARCHAR,
    event_ts       VARCHAR,
    user_id        VARCHAR,
    use_case_id    VARCHAR,
    model_id       VARCHAR,
    input_tokens   VARCHAR,
    output_tokens  VARCHAR,
    latency_ms     VARCHAR,
    status         VARCHAR
);

-- ----------------------------------------------------------------------------
-- 5. Kontrolle: Alle fünf Tabellen sollten jetzt aufgelistet werden.
-- ----------------------------------------------------------------------------
SHOW TABLES IN SCHEMA KI_NUTZUNG.RAW;
