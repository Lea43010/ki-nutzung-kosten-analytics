-- Frage 5: Wo liegen Datenqualitätsprobleme?
-- Die vier bewusst eingebauten Probleme werden hier gezählt, nicht stillschweigend repariert.
select
    'Doppelte event_id in den Rohdaten' as pruefung,
    count(*) - count(distinct event_id) as betroffene_zeilen,
    count(*)                            as geprueft
from {{ source('raw', 'usage_events') }}

union all

select
    'Ereignisse ohne Anwendungsfall',
    count_if(not hat_anwendungsfall),
    count(*)
from {{ ref('fct_usage_events') }}

union all

select
    'Ereignisse nach dem Austritt des Nutzers',
    count_if(ist_nach_austritt),
    count(*)
from {{ ref('fct_usage_events') }}

union all

select
    'Nutzer mit unbekannter Abteilung',
    count_if(d.department_id is null),
    count(*)
from {{ ref('stg_users') }} u
left join {{ ref('stg_departments') }} d on u.department_id = d.department_id
