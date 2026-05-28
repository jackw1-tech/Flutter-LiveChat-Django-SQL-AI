import 'package:flutter_chat/local_db/local_database.dart';
import 'package:flutter_chat/network/service/local_sql_service.dart';

class LocalSqlServiceImpl implements LocalSqlService {
  LocalSqlServiceImpl(this._db);

  final LocalDatabase _db;

  static final RegExp _selectOnly = RegExp(
    r'^\s*SELECT\b',
    caseSensitive: false,
  );

  // Defence in depth: even though the backend prompt forbids mutating
  // statements, never trust the model output and gate it client-side too.
  static final RegExp _forbidden = RegExp(
    r'\b(INSERT|UPDATE|DELETE|DROP|ALTER|CREATE|REPLACE|ATTACH|DETACH|PRAGMA)\b',
    caseSensitive: false,
  );

  // Aggregate signals — the query is considered "summary-shaped" when any of
  // these appear, in which case we trust the model's row count and skip the
  // defensive LIMIT (the result is already small by construction).
  static final RegExp _aggregate = RegExp(
    r'\b(GROUP\s+BY|SUM\s*\(|COUNT\s*\(|AVG\s*\(|MIN\s*\(|MAX\s*\(|TOTAL\s*\(|GROUP_CONCAT\s*\()',
    caseSensitive: false,
  );

  // Strips a trailing top-level LIMIT clause so COUNT(*) sees the real total.
  // Matches `LIMIT N`, `LIMIT N OFFSET M`, `LIMIT M, N`. A LIMIT inside a
  // subquery sits before a closing paren, so it won't match.
  static final RegExp _trailingLimit = RegExp(
    r'\s+LIMIT\s+\d+(\s*,\s*\d+|\s+OFFSET\s+\d+)?\s*$',
    caseSensitive: false,
  );

  @override
  Future<LocalQueryResult> runQuery(String sql) async {
    final cleaned = sql.trim().replaceAll(RegExp(r';\s*$'), '');
    if (!_selectOnly.hasMatch(cleaned) || _forbidden.hasMatch(cleaned)) {
      throw UnsafeSqlException('Only SELECT statements are allowed: $cleaned');
    }

    final db = await _db.open();
    final isAggregate = _aggregate.hasMatch(cleaned);

    try {
      if (isAggregate) {
        final rows = await db.rawQuery(cleaned);
        return LocalQueryResult(
          rows: rows,
          executedSql: cleaned,
          totalRowCount: rows.length,
          truncated: false,
        );
      }

      // Non-aggregate list query: count the underlying total, then run the
      // capped query so the payload stays small even if the model forgot LIMIT.
      // Strip the model-supplied trailing LIMIT before counting, otherwise the
      // count would just echo the cap and `truncated` would never trigger.
      final forCount = cleaned.replaceFirst(_trailingLimit, '');
      final totalRow =
          await db.rawQuery('SELECT COUNT(*) AS c FROM ($forCount) sub');
      final totalRowCount = (totalRow.first['c'] as num?)?.toInt() ?? 0;

      // Wrap with outer LIMIT only if the model's own LIMIT exceeds the cap or
      // is missing. If the model already asked for <= maxRows, run it as-is.
      final limitMatch = _trailingLimit.firstMatch(cleaned);
      final modelLimit = limitMatch != null
          ? int.tryParse(limitMatch.group(0)!.replaceAll(RegExp(r'[^\d]'), '').trim())
          : null;
      final needsWrap = modelLimit == null || modelLimit > LocalSqlService.maxRows;
      final executed = needsWrap
          ? 'SELECT * FROM ($cleaned) sub LIMIT ${LocalSqlService.maxRows}'
          : cleaned;
      final rows = await db.rawQuery(executed);

      return LocalQueryResult(
        rows: rows,
        executedSql: executed,
        totalRowCount: totalRowCount,
        truncated: rows.length < totalRowCount,
      );
    } catch (e) {
      throw UnsafeSqlException('SQL execution failed: $e\nQuery: $cleaned');
    }
  }
}
