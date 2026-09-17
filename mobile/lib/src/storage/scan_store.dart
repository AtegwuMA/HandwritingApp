import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/scan.dart';

/// Local persistence for scans, recognized text, and user edits.
/// Everything here is offline-only; no network calls.
class ScanStore {
  static const _dbName = 'handwriting.db';
  static const _table = 'scans';

  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(dir.path, _dbName);
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE $_table (
          id TEXT PRIMARY KEY,
          imagePath TEXT NOT NULL,
          rawText TEXT NOT NULL,
          correctedText TEXT NOT NULL,
          createdAt TEXT NOT NULL
        )
      '''),
    );
    return _db!;
  }

  Future<void> save(Scan scan) async {
    final db = await _database;
    await db.insert(
      _table,
      scan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateCorrectedText(String id, String correctedText) async {
    final db = await _database;
    await db.update(
      _table,
      {'correctedText': correctedText},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Scan>> all() async {
    final db = await _database;
    final rows = await db.query(_table, orderBy: 'createdAt DESC');
    return rows.map(Scan.fromMap).toList();
  }

  Future<void> delete(String id) async {
    final db = await _database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }
}
