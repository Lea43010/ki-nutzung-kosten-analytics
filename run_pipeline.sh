#!/usr/bin/env bash
# ============================================================================
# Führt die komplette Pipeline aus, vom Erzeugen der Daten bis zu den Tests.
#
# Voraussetzungen (einmalig):
#   1. sql/setup_snowflake.sql wurde in Snowflake ausgeführt.
#   2. Die Datei .env enthält die Snowflake-Zugangsdaten (Vorlage: .env.example).
#   3. Die Python-Pakete sind installiert: pip install -r requirements.txt
#
# Aufruf im Hauptordner des Projekts:
#   bash run_pipeline.sh
# ============================================================================
set -euo pipefail

cd "$(dirname "$0")"

echo "==> Schritt 1/4: Beispieldaten erzeugen"
python scripts/generate_data.py

echo "==> Schritt 2/4: Rohdaten nach Snowflake laden"
python scripts/load_raw.py

# Zugangsdaten für dbt bereitstellen (dbt liest die .env-Datei nicht selbst).
set -a
# shellcheck disable=SC1091
source .env
set +a

# profiles.yml aus der Vorlage anlegen, falls sie fehlt (enthält keine Passwörter).
if [ ! -f dbt/profiles.yml ]; then
    cp dbt/profiles.yml.example dbt/profiles.yml
fi

cd dbt

echo "==> Schritt 3/4: Daten aufbereiten und auswerten (dbt run)"
dbt run --profiles-dir .

echo "==> Schritt 4/4: Datenqualität prüfen (dbt test)"
# Warnungen sind gewollt (eingebaute Datenfehler), nur echte Fehler brechen ab.
dbt test --profiles-dir .

echo "==> Fertig. Ergebnisse in Snowflake: Datenbank KI_NUTZUNG, Schema MARTS."
