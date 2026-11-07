-- Frage 4: Welche Anwendungsfälle kosten am meisten je erfolgreicher Anfrage?
-- Nur Anwendungsfälle mit mindestens 100 Ereignissen. Ereignisse ohne Zuordnung bleiben außen vor.
select
    u.use_case_name,
    u.risk_class                              as risikoklasse,
    count_if(f.ist_erfolg)                    as erfolgreiche_anfragen,
    round(sum(f.kosten_eur), 2)               as kosten_eur,
    round(sum(f.kosten_eur) / nullif(count_if(f.ist_erfolg), 0), 4) as kosten_je_erfolgreicher_anfrage_eur
from {{ ref('fct_usage_events') }} f
join {{ ref('stg_use_cases') }} u on f.use_case_id = u.use_case_id
group by u.use_case_name, u.risk_class
having count(*) >= 100
order by kosten_je_erfolgreicher_anfrage_eur desc
