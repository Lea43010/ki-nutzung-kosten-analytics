# Eigene Auswertung ergänzen (ca. 30 Minuten)

Diese Anleitung ist für Fachbereiche. Du brauchst **keine Programmierkenntnisse**, nur Neugier und die Bereitschaft, eine einfache Abfrage zu lesen. Am Ende hast du eine sechste Fachfrage beantwortet, mit demselben Verfahren, das auch die fünf vorhandenen Auswertungen nutzen.

**Voraussetzung:** Die Pipeline ist einmal durchgelaufen (`bash run_pipeline.sh`, siehe README). Dann liegen alle Daten fertig in Snowflake.

## Das Beispiel: Welches KI-Modell verursacht welchen Kostenanteil?

Unsere fünf Auswertungen beantworten Fragen zu Abteilungen, Nutzern und Anwendungsfällen. Eine Frage fehlt noch: **Welches KI-Modell ist für wie viel Prozent der Kosten verantwortlich?** Das hilft zum Beispiel bei der Entscheidung, ob sich ein günstigeres Modell lohnt.

## Das Prinzip in drei Sätzen

1. Die Tabelle `FCT_USAGE_EVENTS` enthält schon alles Wichtige: jede Anfrage mit Kosten, Abteilung, Modell und Datum.
2. Eine Auswertung ist eine kleine Textdatei mit einer Abfrage, die diese Tabelle zusammenfasst.
3. Das Werkzeug dbt baut aus dieser Textdatei eine neue Tabelle in Snowflake.

## Schritt 1: Frage und Zahlen überlegen

Schreibe auf, was du sehen möchtest. Hier:

| Spalte | Bedeutung |
|---|---|
| Modellname | Welches Modell |
| Erfolgreiche Anfragen | Wie oft es erfolgreich genutzt wurde |
| Kosten in Euro | Was es insgesamt gekostet hat |
| Kostenanteil in Prozent | Wie viel vom Gesamtbetrag das ist |

## Schritt 2: Die Datei anlegen

Lege im Ordner `dbt/models/marts/` eine neue Datei an mit dem Namen `mart_kosten_je_modell.sql` und diesem Inhalt:

```sql
-- Frage 6: Welches KI-Modell verursacht welchen Kostenanteil?
select
    m.model_name                                   as modellname,
    count_if(f.ist_erfolg)                         as erfolgreiche_anfragen,
    round(sum(f.kosten_eur), 2)                    as kosten_eur,
    round(sum(f.kosten_eur) / sum(sum(f.kosten_eur)) over () * 100, 1) as kostenanteil_prozent
from {{ ref('fct_usage_events') }} f
join {{ ref('stg_ai_models') }} m on f.model_id = m.model_id
group by m.model_name
order by kosten_eur desc
```

**So liest du die Abfrage:**
- `from … f` heißt: Nimm die Tabelle mit allen Anfragen.
- `join … m` heißt: Hänge den Namen des Modells an, damit du nicht nur eine Nummer siehst.
- `group by` heißt: Fasse alle Anfragen eines Modells zu einer Zeile zusammen.
- `sum(f.kosten_eur)` heißt: Zähle die Kosten zusammen.
- `order by … desc` heißt: Das teuerste Modell steht oben.
- `{{ ref('…') }}` ist die Art, wie dbt auf eine andere Tabelle des Projekts verweist.

## Schritt 3: Bauen

Im Terminal, im Ordner `dbt`:

```bash
cd dbt
dbt run --profiles-dir . --select mart_kosten_je_modell
```

Am Ende sollte `OK created sql table model` stehen.

## Schritt 4: Ergebnis ansehen

In Snowflake:

```sql
SELECT * FROM KI_NUTZUNG.MARTS.MART_KOSTEN_JE_MODELL;
```

Du siehst eine Zeile je Modell. Die Spalte `kostenanteil_prozent` ergibt zusammen etwa 100.

**Prüfe die Plausibilität:** Die Summe der Kosten sollte mit der Summe aus `MART_KOSTEN_JE_ABTEILUNG_MONAT` übereinstimmen (Abweichung nur durch Rundung). Wenn nicht, stimmt etwas mit deiner Abfrage nicht.

## Schritt 5: Die Auswertung beschreiben

Öffne `dbt/models/marts/schema.yml` und ergänze am Ende der Modellliste:

```yaml
  - name: mart_kosten_je_modell
    description: "Frage 6: Kostenanteil je KI-Modell."
```

Eine Beschreibung hilft dem nächsten Menschen zu verstehen, wozu die Tabelle da ist.

## Schritt 6: Festhalten

```bash
cd ..
git add dbt
git commit -m "Frage 6: Kostenanteil je KI-Modell"
git push
```

Fertig. Du hast eine neue Auswertung gebaut, die jeder im Team nachvollziehen kann.

## Wenn etwas nicht klappt

| Meldung | Was es bedeutet | Was du tust |
|---|---|---|
| `Could not find profile` | dbt findet die Verbindungsdatei nicht | Du bist im falschen Ordner. Wechsle mit `cd` in den Ordner `dbt`. |
| `Object does not exist` | Die Pipeline ist noch nicht durchgelaufen | Führe einmal `bash run_pipeline.sh` im Hauptordner aus. |
| `SQL compilation error` | In der Abfrage ist ein Tippfehler | Vergleiche mit dem Beispiel oben, achte auf Kommas und Klammern. |
| `Failed to login` | Zugangsdaten stimmen nicht | Prüfe die Datei `.env`, siehe README. |

## Eigene Idee? Eine KI um Hilfe bitten

Wenn du eine ganz andere Frage beantworten willst, kannst du ein KI-Werkzeug um einen Entwurf bitten. Gib ihm dabei die Spalten der Tabelle mit, sonst rät es:

> Schreibe eine dbt-Abfrage für Snowflake. Die Tabelle `fct_usage_events` hat die Spalten event_id, event_ts, event_monat, user_id, department_name, use_case_id, model_id, input_tokens, output_tokens, status, ist_erfolg, kosten_eur, hat_anwendungsfall, ist_nach_austritt, ist_bekannte_abteilung. Ich möchte sehen: [deine Frage]. Verwende `{{ ref('fct_usage_events') }}` für die Tabelle und erkläre jede Zeile in einfachen Worten.

**Wichtig:** Prüfe das Ergebnis immer selbst. Eine KI schreibt eine Abfrage, die plausibel aussieht, aber falsch rechnen kann. Vergleiche Summen mit einer vorhandenen Auswertung und frage dich, ob die Zahlen zur Realität passen. Die Verantwortung für das Ergebnis bleibt bei dir.
