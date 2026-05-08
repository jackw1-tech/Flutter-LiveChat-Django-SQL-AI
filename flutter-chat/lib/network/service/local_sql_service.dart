abstract class LocalSqlService {
  /// Step 7 — execute the SQL produced by OpenAI on the on-device SQLite
  /// database and return the rows as plain JSON-friendly maps.
  Future<List<Map<String, dynamic>>> runQuery(String sql);
}
