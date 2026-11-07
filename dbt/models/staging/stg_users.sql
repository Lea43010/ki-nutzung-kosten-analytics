-- Nutzer: Datumsangaben von Text in echte Datumswerte umwandeln.
select
    user_id,
    department_id,
    try_to_date(hired_date) as hired_date,
    try_to_date(left_date)  as left_date
from {{ source('raw', 'users') }}
