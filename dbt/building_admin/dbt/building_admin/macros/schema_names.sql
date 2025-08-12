{% macro generate_schema_name(custom_schema_name, node) -%}
  {# If a custom schema is set on a model/folder, use it as-is.
     Otherwise use the target.schema from the profile. #}
  {%- if custom_schema_name is none -%}
    {{ target.schema }}
  {%- else -%}
    {{ custom_schema_name | trim }}
  {%- endif -%}
{%- endmacro %}
