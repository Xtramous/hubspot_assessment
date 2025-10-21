{% macro date_cast(column_name) %}
    TRY_CAST({{ column_name }} AS DATE)
{% endmacro %}
