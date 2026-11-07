-- Nutzungsereignisse: Duplikate entfernen und Typen umwandeln.
-- Kommt dieselbe event_id mehrfach vor, behalten wir genau eine Zeile.
with ranked as (
    select
        *,
        row_number() over (partition by event_id order by event_ts) as zeilen_nr
    from {{ source('raw', 'usage_events') }}
)

select
    event_id,
    try_to_timestamp(event_ts)       as event_ts,
    user_id,
    nullif(use_case_id, '')          as use_case_id,
    model_id,
    try_to_number(input_tokens)      as input_tokens,
    try_to_number(output_tokens)     as output_tokens,
    try_to_number(latency_ms)        as latency_ms,
    status
from ranked
where zeilen_nr = 1
