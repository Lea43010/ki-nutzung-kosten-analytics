# Datenqualität verstehen

Gute Auswertungen brauchen gute Daten. Diese Seite erklärt für Fachbereiche, **wie das Projekt Datenprobleme findet, wo du sie siehst und was sie bedeuten**. Du brauchst keine technischen Vorkenntnisse.

## Das Grundprinzip

Die Pipeline **repariert Fehler nicht heimlich**. Sie macht sie sichtbar. Der Grund: Ob ein doppeltes Ereignis ein Versehen oder ein echtes Doppel ist, ob eine fehlende Abteilung ein Pflegefehler ist, kann nur der Fachbereich beurteilen. Eine Pipeline, die still korrigiert, versteckt solche Fragen.

Dafür gibt es zwei Mechanismen:

1. **Automatische Tests (dbt test):** Sie prüfen bei jedem Lauf, ob die Daten bestimmten Regeln folgen, zum Beispiel „Jede Ereignisnummer kommt nur einmal vor“.
2. **Eine Qualitätsübersicht in Snowflake:** Sie zählt die Auffälligkeiten, bewertet sie mit einer Ampel und erklärt sie in einfachen Worten.

## Die vier Prüfungen im Beispiel

In den Beispieldaten sind vier Probleme **bewusst eingebaut**, damit du siehst, wie die Prüfung arbeitet.

| Prüfung | Was ist passiert? | Was tut die Pipeline? | Wer klärt es? |
|---|---|---|---|
| **Doppelte Ereignisse** | Dasselbe Ereignis wurde mehrfach geliefert. | Zählt es nur einmal. | Quellsystem / IT |
| **Ereignisse ohne Anwendungsfall** | Es ist nicht bekannt, wofür die KI genutzt wurde. | Behält die Kosten, kann sie aber keinem Anwendungsfall zuordnen. | Fachbereich / KI-Verantwortliche |
| **Nutzung nach dem Austritt** | Ein Konto war nach dem Austritt der Person noch aktiv. | Zählt diese Nutzung nicht als aktive Nutzer und meldet sie. | IT / Personal |
| **Nutzer mit unbekannter Abteilung** | Ein Nutzer gehört zu keiner bekannten Abteilung. | Zeigt seine Kosten unter „Unbekannt“. | Personal / Stammdaten |

## Wo siehst du die Ergebnisse?

### 1. Die Qualitätsübersicht (am einfachsten)

Führe in Snowflake aus:

```sql
SELECT PRUEFUNG, BETROFFENE_ZEILEN, ANTEIL_PROZENT, AMPEL, ERKLAERUNG, EMPFEHLUNG, ZUSTAENDIG
FROM KI_NUTZUNG.MARTS.MART_DATENQUALITAET;
```

Du siehst eine Zeile je Prüfung:

| Spalte | Bedeutung |
|---|---|
| `PRUEFUNG` | Was geprüft wurde |
| `BETROFFENE_ZEILEN` | Wie viele Datensätze auffällig sind |
| `ANTEIL_PROZENT` | Wie viel Prozent aller geprüften Datensätze das sind |
| `AMPEL` | **grün** = keine Auffälligkeit, **gelb** = weniger als 1 % betroffen, **rot** = 1 % oder mehr betroffen |
| `ERKLAERUNG` | Was das Problem bedeutet |
| `EMPFEHLUNG` | Was du tun kannst |
| `ZUSTAENDIG` | Wer sich kümmern sollte |

**Im Beispiel** ergibt sich bei den erzeugten Daten (Zufallswert fest eingestellt) etwa: 139 doppelte Ereignisse (gelb), rund 1.100 Ereignisse ohne Anwendungsfall (rot), rund 170 Ereignisse nach dem Austritt (gelb) und 5 Nutzer mit unbekannter Abteilung (rot). Kleine Abweichungen sind möglich.

### 2. Die einzelnen betroffenen Datensätze

Wenn du wissen möchtest, **welche** Datensätze betroffen sind, damit du sie korrigieren kannst:

```sql
SELECT * FROM KI_NUTZUNG.MARTS.MART_DATENQUALITAET_DETAILS
WHERE PRUEFUNG = 'Nutzer mit unbekannter Abteilung';
```

Ersetze den Text hinter `PRUEFUNG =` durch eine der vier Prüfungen aus der Tabelle oben. Über das Download-Symbol unter dem Ergebnis kannst du die Liste als CSV-Datei speichern und in Excel öffnen.

### 3. Die Dokumentationsseite von dbt (grafisch)

dbt kann aus den Beschreibungen im Projekt eine **Webseite** erzeugen. Dort siehst du jede Tabelle mit Beschreibung, jede Spalte mit Erklärung, die zugehörigen Tests und ein **Diagramm, das zeigt, wie die Daten von den Rohdaten bis zur Auswertung fließen**.

Starte im Hauptordner des Projekts:

```bash
set -a; source .env; set +a
cd dbt
dbt docs generate --profiles-dir .
dbt docs serve --profiles-dir .
```

Es öffnet sich eine Seite im Browser (Adresse `http://localhost:8080`). Falls nicht, öffne diese Adresse selbst. Links wählst du eine Tabelle aus, unten rechts findest du das Symbol für das Diagramm des Datenflusses. Beenden kannst du mit **Strg+C** im Terminal.

Die Seite läuft nur auf deinem Rechner, solange der Befehl aktiv ist. Sie enthält keine Daten, nur Beschreibungen der Tabellen und Spalten.

## Die Test-Ausgabe im Terminal lesen

Am Ende von `bash run_pipeline.sh` steht eine Zeile wie:

```
Done. PASS=15 WARN=2 ERROR=0 SKIP=0 NO-OP=0 REUSED=0 TOTAL=17
```

| Wort | Bedeutung |
|---|---|
| `PASS` | Test bestanden, die Regel ist erfüllt |
| `WARN` | Regel verletzt, aber nicht kritisch. Die Pipeline läuft weiter, du solltest dir die Ursache ansehen. |
| `ERROR` | Ein Test ist fehlgeschlagen oder ein Fehler ist aufgetreten. Die Auswertung sollte nicht verwendet werden, bis es geklärt ist. |
| `TOTAL` | Anzahl aller Tests |

Im Beispiel sind **zwei Warnungen gewollt**: Sie stammen von den eingebauten Problemen „unbekannte Abteilung“ und „ohne Anwendungsfall“. `ERROR` sollte immer 0 sein.

## Wie gehe ich mit einem Qualitätsproblem um?

1. **Verstehen:** Lies die Erklärung in der Qualitätsübersicht.
2. **Eingrenzen:** Sieh dir in der Detailliste einzelne Datensätze an.
3. **Ursache klären:** Sprich mit der Stelle aus der Spalte `ZUSTAENDIG`.
4. **An der Quelle beheben:** Korrigiere die Daten dort, wo sie entstehen, nicht in der Auswertung.
5. **Erneut laufen lassen:** Mit `bash run_pipeline.sh` siehst du, ob die Ampel besser wird.

## Eigene Regel ergänzen

Eine zusätzliche Prüfung ergänzt du in der Datei `dbt/models/marts/schema.yml` oder `dbt/models/staging/schema.yml`. Ein Beispiel: Sollen Anwendungsfälle mit hohem Risiko immer dokumentiert sein, kann dafür ein eigener Test geschrieben werden. Die Anleitung [Eigene Auswertung ergänzen](eigene-auswertung-ergaenzen.md) zeigt das Vorgehen für neue Auswertungen.

## Was die Prüfung nicht kann

- Sie erkennt nur Probleme, für die jemand eine **Regel** formuliert hat. Fehler, an die niemand gedacht hat, bleiben unentdeckt.
- Sie sagt nicht, ob ein Wert **fachlich richtig** ist, nur ob er den Regeln entspricht.
- Die Ampelgrenze von 1 % ist ein Beispielwert. In einem echten Projekt legen Fachbereich und IT gemeinsam fest, was akzeptabel ist.
