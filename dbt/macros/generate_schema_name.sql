-- Standardmäßig hängt dbt den Schema-Namen an den Ziel-Schema-Namen an (z. B. STAGING_MARTS).
-- Diese Regel sorgt dafür, dass genau die Schemas STAGING und MARTS verwendet werden.
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- if custom_schema_name is none -%}
        {{ target.schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
