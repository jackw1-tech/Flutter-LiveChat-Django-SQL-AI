import 'package:flutter_chat/local_db/local_database.dart';
import 'package:flutter_chat/network/service/local_sql_service.dart';

class UnsafeSqlException implements Exception {
  final String message;
  const UnsafeSqlException(this.message);
  @override
  String toString() => 'UnsafeSqlException: $message';
}

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

  @override
  Future<List<Map<String, dynamic>>> runQuery(String sql) async {
    final cleaned = sql.trim().replaceAll(RegExp(r';\s*$'), '');
    if (!_selectOnly.hasMatch(cleaned) || _forbidden.hasMatch(cleaned)) {
      throw UnsafeSqlException('Only SELECT statements are allowed: $cleaned');
    }
    final db = await _db.open();
    return db.rawQuery(cleaned);
  }
}
