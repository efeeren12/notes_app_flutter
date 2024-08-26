import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:notes_app_flutter/models/category.dart';
import 'package:notes_app_flutter/models/notes.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> _initializeDatabase() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "notes.db");

    // Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "notes.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing database");
    }

    // Open the database
    var db = await openDatabase(
      path,
      version: 2, // Veritabanı versiyonunu artırın
      onUpgrade: _onUpgrade, // onUpgrade metodunu ekleyin
    );
    return db;
  }

 
  // onUpgrade metodunu ekliyoruz
  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute("ALTER TABLE note ADD COLUMN categoryTitle TEXT");
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    var db = await _initializeDatabase();
    var result = await db.query("category");
    return result;
  }

  Future<int> addCategory(Category category) async {
    var db = await _initializeDatabase();
    var result = await db.insert("category", category.toMap());
    return result;
  }

  Future<int> updateCategory(Category category) async {
    var db = await _initializeDatabase();
    var result = await db.update("category", category.toMap(),
        where: "categoryID = ?", whereArgs: [category.categoryID]);
    return result;
  }

  Future<int> deleteCategory(int categoryID) async {
    var db = await _initializeDatabase();
    var result = await db
        .delete("category", where: "categoryID = ?", whereArgs: [categoryID]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getNotes() async {
    var db = await _initializeDatabase();
    var result = await db.rawQuery(
        "select * from note inner join category  on category.categoryID = note.categoryID;");
    return result;
  }

  Future<List<Note>> getNoteList() async {
    var noteMapList = await getNotes();
    var noteList = <Note>[];
    for (Map<String, dynamic> map in noteMapList) {
      noteList.add(Note.fromMap(map));
    }
    return noteList;
  }

  Future<int> addNote(Note note) async {
    var db = await _initializeDatabase();
    var result = await db.insert("note", note.toMap());
    return result;
  }

  Future<int> updateNote(Note note) async {
    var db = await _initializeDatabase();
    var result = await db.update("note", note.toMap(),
        where: "noteID = ?", whereArgs: [note.noteID]);
    return result;
  }

  Future<int> deleteNote(int noteID) async {
    var db = await _initializeDatabase();
    var result =
        await db.delete("note", where: "noteID = ?", whereArgs: [noteID]);
    return result;
  }

  String dateFormat(DateTime tm) {
    DateTime today = new DateTime.now();
    Duration oneDay = new Duration(days: 1);
    Duration twoDay = new Duration(days: 2);
    Duration oneWeek = new Duration(days: 7);
    String? month;
    switch (tm.month) {
      case 1:
        month = "Ocak";
        break;
      case 2:
        month = "Şubat";
        break;
      case 3:
        month = "Mart";
        break;
      case 4:
        month = "Nisan";
        break;
      case 5:
        month = "Mayıs";
        break;
      case 6:
        month = "Haziran";
        break;
      case 7:
        month = "Temmuz";
        break;
      case 8:
        month = "Ağustos";
        break;
      case 9:
        month = "Eylül";
        break;
      case 10:
        month = "Ekim";
        break;
      case 11:
        month = "Kasım";
        break;
      case 12:
        month = "Aralık";
        break;
    }

    Duration difference = today.difference(tm);

    if (difference.compareTo(oneDay) < 1) {
      return "Bugün";
    } else if (difference.compareTo(twoDay) < 1) {
      return "Dün";
    } else if (difference.compareTo(oneWeek) < 1) {
      switch (tm.weekday) {
        case 1:
          return "Pazartesi";
        case 2:
          return "Salı";
        case 3:
          return "Çarşamba";
        case 4:
          return "Perşembe";
        case 5:
          return "Cuma";
        case 6:
          return "Cumartesi";
        case 7:
          return "Pazar";
      }
    } else if (tm.year == today.year) {
      return '${tm.day} $month';
    } else {
      return '${tm.day} $month ${tm.year}';
    }
    return "";
  }
}