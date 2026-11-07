-- Abteilungen: nur sauber benannt, keine Änderung am Inhalt.
select
    department_id,
    department_name,
    cost_center
from {{ source('raw', 'departments') }}
