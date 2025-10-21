{% macro column_cleaner(column_name) %}
    LOWER(TRIM({{ column_name }}))
{% endmacro %}
