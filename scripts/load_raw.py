"""Lädt die CSV-Dateien aus data/raw/ unverändert in die Rohschicht von Snowflake.

Was passiert hier? (in einfachen Worten)
  1. Das Skript meldet sich mit den Zugangsdaten aus der Datei .env bei Snowflake an.
  2. Jede CSV-Datei wird in den Zwischenspeicher (Stage) hochgeladen.
  3. Von dort wird sie in die passende Rohdaten-Tabelle kopiert.
  4. Zur Kontrolle vergleicht das Skript die Zeilenzahl der Datei mit der Tabelle.

Das Skript kann beliebig oft laufen: Vor dem Laden wird die Tabelle geleert,
sodass keine doppelten Daten entstehen.

Aufruf:
    python scripts/load_raw.py
"""

import os
import sys
from pathlib import Path

import snowflake.connector
from dotenv import load_dotenv

RAW_DIR = Path("data/raw")

# Dateiname -> Zieltabelle in KI_NUTZUNG.RAW
TABLES = {
    "departments.csv": "DEPARTMENTS",
    "ai_models.csv": "AI_MODELS",
    "users.csv": "USERS",
    "use_cases.csv": "USE_CASES",
    "usage_events.csv": "USAGE_EVENTS",
}


def require(name: str) -> str:
    value = os.getenv(name)
    if not value:
        sys.exit(f"Fehlende Einstellung {name}. Bitte in der Datei .env eintragen.")
    return value


def count_csv_rows(path: Path) -> int:
    """Zeilen ohne Kopfzeile. Voraussetzung: keine Zeilenumbrüche in Feldern (gilt für unsere Daten)."""
    with open(path, encoding="utf-8") as f:
        return sum(1 for _ in f) - 1


def main() -> None:
    load_dotenv(override=True)

    conn = snowflake.connector.connect(
        account=require("SNOWFLAKE_ACCOUNT"),
        user=require("SNOWFLAKE_USER"),
        password=require("SNOWFLAKE_PASSWORD"),
        role=os.getenv("SNOWFLAKE_ROLE", "ACCOUNTADMIN"),
        warehouse=os.getenv("SNOWFLAKE_WAREHOUSE", "KI_NUTZUNG_WH"),
        database=os.getenv("SNOWFLAKE_DATABASE", "KI_NUTZUNG"),
        schema=os.getenv("SNOWFLAKE_SCHEMA", "RAW"),
    )
    cur = conn.cursor()

    try:
        for filename, table in TABLES.items():
            path = RAW_DIR / filename
            if not path.exists():
                sys.exit(f"{path} fehlt. Bitte zuerst 'python scripts/generate_data.py' ausführen.")

            expected = count_csv_rows(path)
            file_uri = "file://" + path.resolve().as_posix()

            cur.execute(f"TRUNCATE TABLE {table}")
            cur.execute(f"PUT '{file_uri}' @RAW_STAGE OVERWRITE = TRUE AUTO_COMPRESS = TRUE")
            cur.execute(
                f"COPY INTO {table} FROM @RAW_STAGE/{filename}.gz "
                f"FILE_FORMAT = (FORMAT_NAME = CSV_FORMAT) "
                f"ON_ERROR = ABORT_STATEMENT FORCE = TRUE"
            )
            cur.execute(f"SELECT COUNT(*) FROM {table}")
            loaded = cur.fetchone()[0]

            status = "OK" if loaded == expected else "ABWEICHUNG"
            print(f"{table:<14} Datei: {expected:>7}  Tabelle: {loaded:>7}  {status}")
            if loaded != expected:
                sys.exit(f"Zeilenzahl von {table} stimmt nicht mit der Datei überein.")
    finally:
        cur.close()
        conn.close()

    print("Rohdaten vollständig geladen.")


if __name__ == "__main__":
    main()
