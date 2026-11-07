-- Anwendungsfälle: Datum und Ja/Nein-Feld in passende Typen umwandeln.
select
    use_case_id,
    use_case_name,
    department_id,
    risk_class,
    status,
    try_to_date(approved_date)                   as approved_date,
    try_to_boolean(documentation_complete)       as documentation_complete
from {{ source('raw', 'use_cases') }}
