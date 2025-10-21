{% macro null_handler(column_name, default_value) %}
    COALESCE({{ column_name }}, {{ default_value }})
{% endmacro %}
