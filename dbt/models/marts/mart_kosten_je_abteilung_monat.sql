-- Frage 1: Was kostet KI pro Abteilung und Monat?
select
    event_monat,
    department_name,
    count_if(ist_erfolg)                 as erfolgreiche_anfragen,
    sum(input_tokens + output_tokens)    as token_gesamt,
    round(sum(kosten_eur), 2)            as kosten_eur
from {{ ref('fct_usage_events') }}
group by event_monat, department_name
order by event_monat, department_name
