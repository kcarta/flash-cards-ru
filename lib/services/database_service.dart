import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/word_model.dart';

class DatabaseService {
  Database? _database;
  bool _initialized = false;

  Future<Database> get database async {
    if (_initialized) return _database!;
    _database = await initDb();
    _initialized = true;
    return _database!;
  }

  Future<Database> initDb() async {
    String path = join(await getDatabasesPath(), 'russian_flashcards.db');
    return await openDatabase(path, version: 1, onCreate: (db, version) async {
      await db.execute(
        "CREATE TABLE words(id INTEGER PRIMARY KEY, english TEXT, russian TEXT, type TEXT, icon TEXT, forms TEXT, isLearned INTEGER)",
      );
      await _seedDatabase(db);
    });
  }

  Future<void> _seedDatabase(Database db) async {
    List<String> dataSources = [
      "assets/data_adjectives.json",
      "assets/data_nouns.json",
      "assets/data_numbers.json",
      "assets/data_phrases.json",
      "assets/data_prepositions.json",
      "assets/data_pronouns.json",
      "assets/data_time.json",
      "assets/data_verbs.json"
    ];
    for (var source in dataSources) {
      String data = await rootBundle.loadString(source);
      List<dynamic> jsonData = jsonDecode(data);
      List<Word> seedData = jsonData.map((json) => Word.fromMap(json)).toList();
      for (var word in seedData) {
        await db.insert('Words', word.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
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

  Future<List<Word>> getAllWords() async {
    final db = await database;
    var res = await db.query("words");
    List<Word> list = res.isNotEmpty ? res.map((c) => Word.fromMap(c)).toList() : [];
    return list;
  }

  // Deletes and re-inits the DB
  Future<void> reset() async {
    final db = await database;
    await db.delete("words");
    await _seedDatabase(db);
  }
}
