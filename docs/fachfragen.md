# Fachfragen und Entscheidungen

Alle Daten in diesem Repo sind synthetisch (siehe `scripts/generate_data.py`).
Die Fragen simulieren, was ein Fachbereich oder Controlling von einer KI-Nutzungsauswertung erwartet.

## Frage 1: Was kostet KI pro Abteilung und Monat?

- Kosten je Event = Eingabe-Token / 1.000 × Preis Eingabe + Ausgabe-Token / 1.000 × Preis Ausgabe.
- **Entscheidung:** Fehlgeschlagene Anfragen (`status = fehler`) zählen **nicht** zu den Kosten. Offen ist, ob der Anbieter sie abrechnet. In diesem Beispiel nehmen wir an: nein.
- **Entscheidung:** Duplikate (gleiche `event_id`) werden vor der Berechnung entfernt.
- Events ohne Zuordnung zu einem Anwendungsfall bleiben in den Kosten und erscheinen als „nicht zugeordnet“.

## Frage 2: Wie viele aktive Nutzer gab es je Monat?

- **Entscheidung:** Aktiv heißt: mindestens ein erfolgreiches Event im Monat.
- **Entscheidung:** Events nach dem Austrittsdatum zählen nicht als aktive Nutzung, werden aber als Qualitätsproblem gemeldet.
- Nutzer mit unbekannter Abteilung erscheinen unter „Unbekannt“.

## Frage 3: Welcher Anteil der Anwendungsfälle ist nach Risikoklasse freigegeben und vollständig dokumentiert?

- **Entscheidung:** „Konform“ heißt: Status `freigegeben` und `documentation_complete = true`.
- **Entscheidung:** Eingestellte Anwendungsfälle zählen nicht in den Nenner.
- Die Auswertung erfolgt je Risikoklasse (minimal, begrenzt, hoch).

## Frage 4: Welche Anwendungsfälle verursachen die höchsten Kosten je erfolgreicher Anfrage?

- Kosten je erfolgreicher Anfrage = Gesamtkosten / Anzahl erfolgreicher Events.
- Es werden nur Anwendungsfälle mit mindestens 100 Events betrachtet.

## Frage 5: Wo liegen Datenqualitätsprobleme?

Die Daten enthalten vier bewusst eingebaute Probleme. Jedes hat einen dbt-Test und erscheint in einer Qualitätsübersicht:

1. doppelte `event_id`
2. Events ohne `use_case_id`
3. Events von Nutzern nach ihrem Austritt
4. Nutzer mit unbekannter `department_id`

Ziel ist, dass die Pipeline sie erkennt und sichtbar macht, nicht dass sie sie stillschweigend repariert.
