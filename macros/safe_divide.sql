{% macro safe_divide(numerator, denominator) %}
    CASE WHEN {{ denominator }} = 0 OR {{ denominator }} IS NULL THEN 0
         ELSE {{ numerator }} / {{ denominator }}
    END
{% endmacro %}
