-- Frage 5: Wo liegen Datenqualitätsprobleme?
-- Die vier bewusst eingebauten Probleme werden gezählt, bewertet und erklärt.
-- Sie werden nicht stillschweigend repariert, damit die Fachbereiche sie sehen.
with pruefungen as (

    select
        'Doppelte Ereignisse' as pruefung,
        count(*) - count(distinct event_id) as betroffene_zeilen,
        count(*)                            as geprueft,
        'Dasselbe Ereignis wurde mehrfach geliefert. Die Auswertung zählt es nur einmal.' as erklaerung,
        'Prüfen, ob die Quelle doppelt exportiert oder geliefert hat.' as empfehlung,
        'Quellsystem / IT' as zustaendig
    from {{ source('raw', 'usage_events') }}

    union all

    select
        'Ereignisse ohne Anwendungsfall',
        count_if(not hat_anwendungsfall),
        count(*),
        'Es ist nicht bekannt, wofür die KI hier genutzt wurde. Die Kosten sind enthalten, aber keinem Anwendungsfall zuordenbar.',
        'Die Angabe des Anwendungsfalls bei der Nutzung zur Pflicht machen.',
        'Fachbereich / KI-Verantwortliche'
    from {{ ref('fct_usage_events') }}

    union all

    select
        'Nutzung nach dem Austritt',
        count_if(ist_nach_austritt),
        count(*),
        'Ein Nutzerkonto war nach dem Austritt der Person noch aktiv. Mögliche Ursachen: Konto nicht gesperrt oder weitergegeben.',
        'Konten beim Austritt sperren und die Nutzung prüfen.',
        'IT / Personal'
    from {{ ref('fct_usage_events') }}

    union all

    select
        'Nutzer mit unbekannter Abteilung',
        count_if(d.department_id is null),
        count(*),
        'Der Nutzer ist keiner bekannten Abteilung zugeordnet. Seine Kosten erscheinen unter der Abteilung Unbekannt.',
        'Die Stammdaten der Nutzer pflegen.',
        'Personal / Stammdaten'
    from {{ ref('stg_users') }} u
    left join {{ ref('stg_departments') }} d on u.department_id = d.department_id

)

select
    pruefung,
    betroffene_zeilen,
    geprueft,
    round(betroffene_zeilen / nullif(geprueft, 0) * 100, 2) as anteil_prozent,
    case
        when betroffene_zeilen = 0 then 'grün'
        when betroffene_zeilen / nullif(geprueft, 0) < 0.01 then 'gelb'
        else 'rot'
    end as ampel,
    erklaerung,
    empfehlung,
    zustaendig
from pruefungen
