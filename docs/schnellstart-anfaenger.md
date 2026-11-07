# Schnellstart für absolute Anfänger

Diese Anleitung ist für Menschen **ohne technische Vorkenntnisse**: Betriebswirtinnen, Wirtschaftswissenschaftler, Assistenten der Geschäftsführung. Stell dir vor, dein Chef fragt: *„Was kostet uns eigentlich die KI, und wer nutzt sie?“* Mit dieser Anleitung beantwortest du die Frage mit einer eigenen, überprüfbaren Auswertung.

**Zeitbedarf:** beim ersten Mal etwa 60 bis 90 Minuten, die meiste Zeit geht für Installationen drauf.
**Was du am Ende hast:** fünf fertige Auswertungen (Kosten je Abteilung, aktive Nutzer, Freigabe-Status der Anwendungsfälle, Kosten je Anfrage, Datenqualität), die du als Excel-Datei weitergeben kannst.

> **Wichtig:** Das Projekt arbeitet mit **erfundenen Beispieldaten**. Damit kannst du gefahrlos üben. Bevor du echte Unternehmensdaten verwendest, sprich mit deiner IT und dem Datenschutz.

Die Anleitung beschreibt **Windows**. Auf dem Mac läuft es ähnlich, einzelne Befehle unterscheiden sich.

---

## Teil 1: Die wichtigsten Begriffe (2 Minuten)

| Begriff | Einfach erklärt |
|---|---|
| **Repository (Repo)** | Ein Projektordner im Internet, in dem alle Dateien und alle Änderungen gespeichert sind. Vergleichbar mit einem gemeinsamen Laufwerk, das jede Änderung festhält. |
| **GitHub** | Die Webseite, auf der dieses Repo liegt. |
| **Git** | Das Programm, das Projekte von GitHub auf deinen Rechner holt. |
| **VS Code** | Ein Programm zum Öffnen und Bearbeiten von Projektdateien. Ähnlich wie Word, aber für Code. |
| **Terminal** | Ein Fenster, in dem du Befehle eintippst, statt zu klicken. Du kopierst sie einfach aus dieser Anleitung. |
| **Python** | Die Programmiersprache, in der die Hilfsprogramme geschrieben sind. Du musst sie nicht lernen, nur installieren. |
| **Snowflake** | Eine Datenbank in der Cloud, in der die Daten gespeichert und ausgewertet werden. Wie ein riesiges, sehr schnelles Excel. |
| **dbt** | Ein Werkzeug, das die Daten in Snowflake aufbereitet und prüft. Es wird automatisch mitinstalliert. |
| **Pipeline** | Eine Abfolge von Schritten, die Daten automatisch von A nach B bringen und unterwegs bereinigen. |

---

## Teil 2: Programme installieren (ca. 20 Minuten)

Installiere diese drei Programme. Bei allen kannst du die Standardeinstellungen mit „Weiter“ bestätigen, außer wo unten etwas anderes steht. Falls dein Firmenrechner Installationen sperrt, bitte die IT um Hilfe.

1. **Git für Windows:** Suche im Internet nach „Git for Windows“ und lade es von der offiziellen Seite `git-scm.com` herunter. Dabei wird auch das Terminal „Git Bash“ mitinstalliert.
2. **Python:** Lade Python von `python.org` herunter (Version 3.12 wurde getestet).
   **Wichtig:** Setze im ersten Fenster des Installers unten das Häkchen bei **„Add python.exe to PATH“**, bevor du auf „Install Now“ klickst. Ohne das Häkchen funktionieren spätere Befehle nicht.
3. **Visual Studio Code (VS Code):** Lade es von `code.visualstudio.com` herunter.

Starte danach deinen Rechner einmal neu.

---

## Teil 3: Snowflake-Testkonto anlegen (ca. 10 Minuten)

1. Öffne `signup.snowflake.com` und lege ein kostenloses Testkonto an. Das Testkonto ist zeitlich begrenzt und enthält ein Startguthaben. Die genauen Bedingungen ändern sich, lies sie beim Anmelden.
2. Du erhältst eine Bestätigungs-E-Mail. Klicke auf den Link und vergib Benutzername und Passwort. **Notiere dir beides.**
3. Nach der Anmeldung siehst du die Snowflake-Oberfläche („Snowsight“).
4. **Deine Account-Kennung finden** (du brauchst sie gleich): Schau in die Adresszeile deines Browsers. Sie sieht so aus:
   `https://app.snowflake.com/ABCDEFG/xy12345/...`
   Die beiden Teile nach `app.snowflake.com/` sind deine Kennung, verbunden mit einem Bindestrich: `ABCDEFG-xy12345`.
   Alternativ: Klicke unten links auf deinen Namen, dann auf dein Konto und „View account details“.

---

## Teil 4: Das Projekt auf deinen Rechner holen (ca. 5 Minuten)

1. Öffne **VS Code**.
2. Öffne das Terminal: Menü **Terminal**, dann **New Terminal**. Unten erscheint ein Fenster.
3. Prüfe oben rechts im Terminalfenster, ob dort **bash** steht. Steht dort „powershell“, klicke auf den kleinen Pfeil neben dem Plus-Symbol und wähle **Git Bash**.
4. Kopiere diesen Befehl in das Terminal und drücke Enter:

```bash
git clone https://github.com/lea-zimmer-data/ki-nutzung-kosten-analytics.git
```

   Es erscheint eine Meldung wie „Cloning into …“. Nun liegt ein Ordner `ki-nutzung-kosten-analytics` in deinem Benutzerordner.
5. Öffne den Ordner in VS Code: Menü **File**, dann **Open Folder**. Wähle den Ordner **aus** (nicht hineingehen) und klicke auf „Ordner auswählen“. Bei der Frage, ob du dem Ordner vertraust, antworte mit **Ja**.
6. Öffne ein **neues Terminal** (Menü Terminal, New Terminal). Vorne im Terminal muss jetzt der Name `ki-nutzung-kosten-analytics` stehen. Wenn nicht, bist du im falschen Ordner.

**Das solltest du sehen:** Links im Dateibaum erscheinen Ordner wie `dbt`, `docs`, `scripts` und `sql`.

---

## Teil 5: Python vorbereiten (ca. 5 Minuten)

Kopiere die Befehle nacheinander ins Terminal. Warte jeweils, bis wieder eine neue Eingabezeile erscheint.

```bash
python -m venv .venv
source .venv/Scripts/activate
pip install -r requirements.txt
```

- Der erste Befehl legt einen eigenen, sauberen Bereich für das Projekt an.
- Der zweite schaltet ihn ein. Danach steht vorne im Terminal `(.venv)`.
- Der dritte installiert alle nötigen Hilfsprogramme. Das dauert einige Minuten und zeigt viel Text. Das ist normal.

**Und dbt?** Es ist bei diesem dritten Befehl schon dabei. Du musst dbt nicht extra installieren oder einrichten. Die Verbindungsdatei legt `run_pipeline.sh` in Teil 8 automatisch an.

Falls VS Code fragt, ob es die neue Umgebung verwenden soll, klicke auf **Ja**.

---

## Teil 6: Snowflake vorbereiten (ca. 5 Minuten)

Du richtest einmalig den Arbeitsplatz in Snowflake ein.

1. Öffne in VS Code im Dateibaum den Ordner `sql` und die Datei `setup_snowflake.sql`.
2. Markiere den gesamten Inhalt (**Strg+A**) und kopiere ihn (**Strg+C**).
3. Wechsle zu Snowflake im Browser. Lege ein neues SQL-Arbeitsblatt an (je nach Oberfläche heißt es „Worksheet“ oder „SQL File“, du findest es links unter „Workspaces“ oder „Projects“).
4. Füge den Text ein (**Strg+V**) und klicke auf **Run all** (Pfeil oben rechts).

**Das solltest du sehen:** Am Ende erscheint eine Liste mit fünf Tabellen (`AI_MODELS`, `DEPARTMENTS`, `USAGE_EVENTS`, `USERS`, `USE_CASES`).

---

## Teil 7: Zugangsdaten eintragen (ca. 5 Minuten)

Damit die Programme sich bei Snowflake anmelden können, brauchen sie deine Zugangsdaten. Du trägst sie in eine Datei ein, die **nur auf deinem Rechner** bleibt.

1. Kopiere die Vorlage im Terminal:

```bash
cp .env.example .env
```

2. Öffne im Dateibaum die neue Datei **`.env`** (nicht `.env.example`!).
3. Ersetze die Platzhalter:
   - `SNOWFLAKE_ACCOUNT=` deine Kennung aus Teil 3, zum Beispiel `ABCDEFG-xy12345`
   - `SNOWFLAKE_USER=` dein Snowflake-Benutzername
   - `SNOWFLAKE_PASSWORD=` dein Snowflake-Passwort
4. Speichere mit **Strg+S**.

Schreibe nichts hinter das Gleichheitszeichen außer dem Wert, ohne Anführungszeichen und ohne Leerzeichen.

> **Sicherheit:** Die Datei `.env` enthält dein Passwort. Schicke sie niemandem, lade sie nirgends hoch und füge ihren Inhalt nie in einen Chat ein. Das Projekt ist so eingestellt, dass sie nicht auf GitHub landet.

---

## Teil 8: Alles starten (ca. 3 Minuten)

Gib im Terminal diesen einen Befehl ein:

```bash
bash run_pipeline.sh
```

Das Programm erzeugt die Beispieldaten, lädt sie nach Snowflake, bereitet sie auf und prüft sie. Du siehst viel Text vorbeilaufen.

**Das solltest du am Ende sehen:**
- fünf Zeilen mit „OK“ und die Meldung „Rohdaten vollständig geladen“
- eine Zeile wie `Done. PASS=15 WARN=2 ERROR=0 ...`
- als letzte Zeile „Fertig“

Die **zwei Warnungen sind gewollt**. In den Beispieldaten sind absichtlich Fehler versteckt (zum Beispiel Nutzer ohne bekannte Abteilung), damit du siehst, wie die Qualitätsprüfung arbeitet. Nur „ERROR“ größer als 0 wäre ein Problem.

---

## Teil 9: Ergebnisse ansehen und weitergeben

Öffne in Snowflake ein neues Arbeitsblatt und führe nacheinander aus:

**Kosten je Abteilung und Monat:**

```sql
SELECT * FROM KI_NUTZUNG.MARTS.MART_KOSTEN_JE_ABTEILUNG_MONAT
ORDER BY EVENT_MONAT DESC, KOSTEN_EUR DESC;
```

**Gibt es Datenprobleme?**

```sql
SELECT * FROM KI_NUTZUNG.MARTS.MART_DATENQUALITAET;
```

**Was die Ampel bedeutet:** Grün heißt keine Auffälligkeiten, Gelb weniger als 1 % betroffene Zeilen, Rot 1 % oder mehr. Wie du die Ergebnisse liest und wer sich um welches Problem kümmern sollte, steht in [Datenqualität verstehen](datenqualitaet-verstehen.md).

**Freigabestatus der KI-Anwendungsfälle:**

```sql
SELECT * FROM KI_NUTZUNG.MARTS.MART_ANWENDUNGSFAELLE_KONFORMITAET;
```

**Für die Geschäftsführung:** Unter dem Ergebnis findest du ein Symbol zum **Herunterladen** (meist als Pfeil nach unten). Damit speicherst du die Tabelle als CSV-Datei, die du in Excel öffnest und weitergibst.

> **Prüfe vor der Weitergabe:** Frage dich bei jeder Zahl, ob sie zur Realität passt, und lies in `docs/fachfragen.md` nach, wie gerechnet wurde (zum Beispiel: Fehlgeschlagene Anfragen kosten nichts). Zahlen aus einer Auswertung sind nur so gut wie die Regeln dahinter.

---

## Wenn etwas nicht klappt

| Meldung oder Problem | Was es bedeutet | Was du tust |
|---|---|---|
| `python: command not found` oder „Python wurde nicht gefunden“ | Python ist nicht richtig installiert | Installiere Python neu und setze das Häkchen „Add python.exe to PATH“. Starte den Rechner neu. |
| `bash: command not found` oder `git: command not found` | Git oder Git Bash fehlt | Installiere Git für Windows und starte VS Code neu. |
| Das Terminal zeigt `PS C:\...` statt `$` | Du bist in PowerShell, nicht in Git Bash | Wähle oben rechts im Terminal Git Bash (siehe Teil 4, Schritt 3). |
| `No such file or directory` | Du bist im falschen Ordner | Wechsle in den Projektordner (siehe Teil 4, Schritt 5 und 6). |
| `Failed to login` mit `404 Not Found` | Die Account-Kennung stimmt nicht | Prüfe `SNOWFLAKE_ACCOUNT` in `.env`: Bindestrich in der Mitte, kein `https://`, keine Anführungszeichen. |
| `Failed to login` (anderes) | Benutzername oder Passwort stimmt nicht | Prüfe beides in `.env`. Fragt Snowflake nach einer zusätzlichen Bestätigung (MFA), melde dich bei deiner IT oder lies die Hilfe von Snowflake zur Anmeldung. |
| `Could not find profile` | dbt findet die Verbindungsdatei nicht | Du bist nicht im Hauptordner des Projekts. Starte `bash run_pipeline.sh` dort. |
| `Object does not exist` | Teil 6 wurde nicht ausgeführt | Führe das Snowflake-Skript aus Teil 6 aus. |
| Änderungen in `.env` wirken nicht | Das Terminal kennt noch die alten Werte | Schließe das Terminal und öffne ein neues, dann starte erneut. |

**Wenn du nicht weiterkommst:** Kopiere die Fehlermeldung (**ohne Passwort!**) und frage ein KI-Werkzeug oder eine Kollegin aus der IT. Gib dabei an, welchen Schritt du gerade machst.

---

## Wie geht es weiter?

- Verstehe die Datenqualität und die Ampel: [Datenqualität verstehen](datenqualitaet-verstehen.md)
- Verstehe die Rechenregeln: [Fachfragen und Entscheidungen](fachfragen.md)
- Baue eine eigene Auswertung: [Eigene Auswertung ergänzen](eigene-auswertung-ergaenzen.md)
- Lies im [README](../README.md), wie die Teile zusammenspielen.
- Sieh dir die Dokumentation der Daten an: Gib im Ordner `dbt` (`cd dbt`) den Befehl `dbt docs generate --profiles-dir .` und danach `dbt docs serve --profiles-dir .` ein. Im Browser siehst du alle Tabellen, Spalten, Tests und ihre Zusammenhänge.

Wenn du echte Unternehmensdaten auswerten möchtest, ist das ein **eigenes Projekt**: Es braucht die Freigabe von IT und Datenschutz und eine abgestimmte Plattform. Dieses Beispiel zeigt dir, wie ein solches Projekt aussehen kann.
