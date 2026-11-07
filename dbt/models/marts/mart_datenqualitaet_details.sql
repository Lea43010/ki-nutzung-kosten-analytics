-- Die einzelnen betroffenen Datensätze zu jeder Prüfung.
-- Damit können Fachbereiche und IT gezielt nachsehen und korrigieren.
select
    'Doppelte Ereignisse'                       as pruefung,
    'Ereignis'                                  as objekt_typ,
    event_id                                    as objekt_id,
    'in den Rohdaten ' || count(*) || ' Mal geliefert' as detail
from {{ source('raw', 'usage_events') }}
group by event_id
having count(*) > 1

union all

select
    'Ereignisse ohne Anwendungsfall',
    'Ereignis',
    event_id,
    'Nutzer ' || user_id || ', ' || cast(event_ts as varchar)
from {{ ref('fct_usage_events') }}
where not hat_anwendungsfall

union all

select
    'Nutzung nach dem Austritt',
    'Ereignis',
    event_id,
    'Nutzer ' || user_id || ', ' || cast(event_ts as varchar)
from {{ ref('fct_usage_events') }}
where ist_nach_austritt

union all

select
    'Nutzer mit unbekannter Abteilung',
    'Nutzer',
    u.user_id,
    'Abteilungs-ID ' || coalesce(u.department_id, '(leer)')
from {{ ref('stg_users') }} u
left join {{ ref('stg_departments') }} d on u.department_id = d.department_id
where d.department_id is null
