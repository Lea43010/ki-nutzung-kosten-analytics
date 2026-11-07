-- Faktentabelle: jedes bereinigte Nutzungsereignis, angereichert mit Kosten,
-- Abteilung und Markierungen für Datenqualitätsprobleme.
-- Kosten = Eingabe-Token/1000 x Preis + Ausgabe-Token/1000 x Preis.
-- Entscheidung: Fehlgeschlagene Anfragen (status = 'fehler') kosten nichts.
select
    e.event_id,
    e.event_ts,
    date_trunc('month', e.event_ts)::date                    as event_monat,
    e.user_id,
    coalesce(d.department_name, 'Unbekannt')                 as department_name,
    e.use_case_id,
    e.model_id,
    e.input_tokens,
    e.output_tokens,
    e.status,
    (e.status = 'erfolg')                                    as ist_erfolg,
    case
        when e.status = 'erfolg' then
            e.input_tokens  / 1000 * m.price_per_1k_input_eur
          + e.output_tokens / 1000 * m.price_per_1k_output_eur
        else 0
    end                                                      as kosten_eur,
    (e.use_case_id is not null)                              as hat_anwendungsfall,
    (u.left_date is not null and e.event_ts::date > u.left_date) as ist_nach_austritt,
    (d.department_id is not null)                            as ist_bekannte_abteilung
from {{ ref('stg_usage_events') }} e
left join {{ ref('stg_users') }}       u on e.user_id = u.user_id
left join {{ ref('stg_departments') }} d on u.department_id = d.department_id
left join {{ ref('stg_ai_models') }}   m on e.model_id = m.model_id
