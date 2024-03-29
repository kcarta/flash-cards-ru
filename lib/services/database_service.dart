import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/word_model.dart';

class DatabaseService {
  late Database _database;

  Future<Database> get database async {
    try {
      return _database; // Try returning _database directly.
    } catch (_) {
      _database = await initDb(); // Initialize it if it hasn't been yet.
      return _database;
    }
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'russian_flashcards.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await (Database db) async {
        await db.execute(
          "CREATE TABLE words(id INTEGER PRIMARY KEY, english TEXT, russian TEXT, type TEXT, icon TEXT, isLearned INTEGER)",
        );
        await _seedDatabase();
      }(db);
    });
  }

  Future<void> _seedDatabase() async {
    String data = await rootBundle.loadString('assets/seed_data.json');
    List<dynamic> jsonData = jsonDecode(data);
    List<Word> seedData = jsonData.map((json) => Word.fromMap(json)).toList();
    for (var word in seedData) {
      await database.then((db) {
        db.insert('Words', word.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      });
    }
  }

  Future<void> updateWordLearnedStatus(int id, bool isLearned) async {
    final db = await database;
    await db.update(
      "words",
      {"isLearned": isLearned ? 1 : 0},
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // getAllWords returns all words from the database.
  Future<List<Word>> getAllWords() async {
    final db = await database;
    var res = await db.query("words");
    List<Word> list =
        res.isNotEmpty ? res.map((c) => Word.fromMap(c)).toList() : [];
    return list;
  }

  // Deletes and re-inits the DB
  Future<void> reset() async {
    final db = await database;
    await db.delete("words");
    await _seedDatabase();
  }
}
