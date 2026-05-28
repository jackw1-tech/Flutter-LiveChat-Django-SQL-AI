class UnsafeSqlException implements Exception {
  final String message;
  const UnsafeSqlException(this.message);
  @override
  String toString() => 'UnsafeSqlException: $message';
}

class LocalQueryResult {
  /// Rows actually returned to the caller (capped to [LocalSqlService.maxRows]).
  final List<Map<String, dynamic>> rows;

  /// The SQL that was finally executed (may differ from the input if a
  /// defensive LIMIT was injected).
  final String executedSql;

  /// Total rows the underlying query would have returned without the cap.
  /// Equal to `rows.length` for aggregate queries.
  final int totalRowCount;

  /// True when [rows.length] < [totalRowCount].
  final bool truncated;

  const LocalQueryResult({
    required this.rows,
    required this.executedSql,
    required this.totalRowCount,
    required this.truncated,
  });
}

abstract class LocalSqlService {
  /// Hard cap on the number of rows returned to the backend.
  static const int maxRows = 200;

  /// Step 7 — execute the SQL produced by OpenAI on the on-device SQLite
  /// database. For non-aggregate queries a defensive LIMIT is injected and
  /// the underlying total row count is reported alongside the rows.
  Future<LocalQueryResult> runQuery(String sql);
}
