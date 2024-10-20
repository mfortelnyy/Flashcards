import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';

class DBHelper {
  static const String _databaseName = 'flashcards.db';
  static const int _databaseVersion = 1;

  DBHelper._();
  static final DBHelper _singleton = DBHelper._();

  factory DBHelper() => _singleton;

  Database? _database;

  get db async {
    _database ??= await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    var dbDir = await getApplicationDocumentsDirectory();
    var dbPath = path.join(dbDir.path, _databaseName);

    var db = await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE decks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE flashcards(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            question TEXT,
            answer TEXT,
            deckId INTEGER,
            FOREIGN KEY (deckId) REFERENCES decks(id)
          )
        ''');
      },
    );

    return db;
  }

  Future<int> insertDeck(Deck deck) async {
    final db = await this.db;
    return db.insert('decks', deck.toMap());
  }

  Future<int> insertFlashcard(Flashcard flashcard) async {
    final db = await this.db;
    return db.insert('flashcards', flashcard.toMap());
  }

  Future<List<Deck>> queryDecks() async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query('decks');
    return List.generate(maps.length, (i) {
      return Deck(
        id: maps[i]['id'],
        name: maps[i]['name'],
      );
    });
  }

  Future<List<Flashcard>> queryFlashcards(int? deckId) async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query('flashcards', where: 'deckId = ?', whereArgs: [deckId]);
    return List.generate(maps.length, (i) {
      return Flashcard(
        id: maps[i]['id'],
        question: maps[i]['question'],
        answer: maps[i]['answer'],
        deckId: maps[i]['deckId'],
      );
    });
  }

  Future<int> updateDeck(Deck deck) async {
  final db = await this.db;
  
  return db.update('decks', deck.toMap(), where: 'id = ?', whereArgs: [deck.id],
  );
}

Future<int> updateFlashcard(Flashcard flashcard) async {
  final db = await this.db;
  
  return db.update('flashcards', flashcard.toMap(), where: 'id = ?', whereArgs: [flashcard.id]);
}

 Future<void> removeDeck(Deck deck) async {
    final db = await this.db;
    await db.delete('decks', where: 'id = ?', whereArgs: [deck.id]);
    await db.delete('flashcards', where: 'deckId = ?', whereArgs: [deck.id]);
  }

  Future<void> removeFlashcard(Flashcard flashcard)  async {
    final db = await this.db;
    await db.delete('flashcards', where: 'id = ?', whereArgs: [flashcard.id]);
  }


}
