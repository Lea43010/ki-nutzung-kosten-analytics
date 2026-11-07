-- KI-Modelle: Preise von Text in Zahlen umwandeln.
select
    model_id,
    model_name,
    try_to_decimal(price_per_1k_input_eur, 18, 6)  as price_per_1k_input_eur,
    try_to_decimal(price_per_1k_output_eur, 18, 6) as price_per_1k_output_eur
from {{ source('raw', 'ai_models') }}
