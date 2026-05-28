NO_SCHEMA_CONFIGURED

Replace this file with the schema that the AI is allowed to query from the
SQLite database bundled in the Flutter app.

Recommended format:

Database purpose:
- Describe what this database represents.

Queryable tables/views:
- table_or_view_name
  - column_name TYPE: meaning, format, allowed values if relevant
  - another_column TYPE: meaning

Relationships:
- table_a.foreign_key -> table_b.primary_key

Business/query rules:
- Explain which columns represent totals, dates, statuses, names, categories,
  currencies, units, or other domain-specific concepts.
- Explain any date formats and common filters the model should use.
- List anything the model must not query.
