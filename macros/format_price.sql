{% macro format_price(column_name) %}
    TRY_CAST(REGEXP_REPLACE({{ column_name }}, '[^0-9.]', '') AS FLOAT)
{% endmacro %}
