-- Frage 3: Welcher Anteil der Anwendungsfälle ist freigegeben und vollständig dokumentiert?
-- Konform = Status 'freigegeben' und Dokumentation vollständig.
-- Eingestellte Anwendungsfälle zählen nicht mit.
select
    risk_class                                                       as risikoklasse,
    count(*)                                                         as anzahl_anwendungsfaelle,
    count_if(status = 'freigegeben' and coalesce(documentation_complete, false)) as anzahl_konform,
    round(
        count_if(status = 'freigegeben' and coalesce(documentation_complete, false))
        / count(*) * 100, 1
    )                                                                as konform_prozent
from {{ ref('stg_use_cases') }}
where status <> 'eingestellt'
group by risk_class
order by case risk_class when 'hoch' then 1 when 'begrenzt' then 2 else 3 end
