-- Frage 2: Wie viele aktive Nutzer gab es je Monat?
-- Aktiv = mindestens ein erfolgreiches Ereignis im Monat.
-- Ereignisse nach dem Austrittsdatum zählen nicht (sie erscheinen in der Qualitätsübersicht).
select
    event_monat,
    department_name,
    count(distinct user_id) as aktive_nutzer
from {{ ref('fct_usage_events') }}
where ist_erfolg
  and not ist_nach_austritt
group by event_monat, department_name
order by event_monat, department_name
