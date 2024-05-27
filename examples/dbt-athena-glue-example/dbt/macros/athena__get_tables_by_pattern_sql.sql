-- Fix for dbt_utils issue. See https://github.com/dbt-labs/dbt-codegen/issues/109
{% macro athena__get_tables_by_pattern_sql(
    schema_pattern, table_pattern, exclude="", database=target.database
) %}

    select distinct
        table_schema as {{ adapter.quote("table_schema") }},
        table_name as {{ adapter.quote("table_name") }},
        {{ dbt_utils.get_table_types_sql() }}
    from {{ database }}.information_schema.tables
    where
        table_schema like lower('{{ schema_pattern }}')
        and table_name like lower('{{ table_pattern }}')
        and table_name not like lower('{{ exclude }}')

{% endmacro %}
