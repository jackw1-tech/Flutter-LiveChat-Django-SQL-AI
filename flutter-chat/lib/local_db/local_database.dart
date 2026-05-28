import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase._();
  static final LocalDatabase instance = LocalDatabase._();

  static const String _assetPath = 'assets/data/local_database.sqlite';
  static const String _dbFileName = 'local_database.sqlite';

  Database? _db;

  Future<Database> open() async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbFileName);

    // Always overwrite from the bundled asset so each app launch uses the
    // database snapshot shipped with this template or with your app release.
    final bytes = await rootBundle.load(_assetPath);
    await File(path).writeAsBytes(bytes.buffer.asUint8List(), flush: true);

    final db = await openDatabase(path, readOnly: false);
    _db = db;
    return _db!;
  }
}
