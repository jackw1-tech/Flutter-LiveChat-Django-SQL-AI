import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Owns the on-device SQLite database. The schema mirrors what the OpenAI
/// SQL prompt declares: keep them in sync with the backend's
/// `SQL_SYSTEM_PROMPT` or the model will hallucinate columns.
class LocalDatabase {
  LocalDatabase._();
  static final LocalDatabase instance = LocalDatabase._();

  Database? _db;

  Future<Database> open() async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'flutter_chat_local.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
    return _db!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        created_at TEXT NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL
      );
    ''');
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        ordered_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
      );
    ''');

    await _seed(db);
  }

  Future<void> _seed(Database db) async {
    final batch = db.batch();
    batch.insert('users', {
      'id': 1,
      'name': 'Alice',
      'email': 'alice@example.com',
      'created_at': '2026-01-10T09:00:00Z',
    });
    batch.insert('users', {
      'id': 2,
      'name': 'Bob',
      'email': 'bob@example.com',
      'created_at': '2026-02-04T14:20:00Z',
    });
    batch.insert('products', {
      'id': 1,
      'name': 'Coffee',
      'price': 3.5,
      'stock': 120,
    });
    batch.insert('products', {
      'id': 2,
      'name': 'Tea',
      'price': 2.8,
      'stock': 80,
    });
    batch.insert('orders', {
      'id': 1,
      'user_id': 1,
      'product_id': 1,
      'quantity': 2,
      'ordered_at': '2026-04-01T10:30:00Z',
    });
    batch.insert('orders', {
      'id': 2,
      'user_id': 2,
      'product_id': 2,
      'quantity': 5,
      'ordered_at': '2026-04-02T11:00:00Z',
    });
    await batch.commit(noResult: true);
  }
}
