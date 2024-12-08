import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseClass {
  static Database? _myDB;

  Future<Database?> get myDB async {
    if (_myDB == null) {
      _myDB = await initialize();
      return _myDB;
    }
    else {
      return _myDB;
    }
  }

  int Version = 1;

  initialize() async {
    String dbDestination = await getDatabasesPath();
    String dbPath = join(dbDestination, 'mydatabase.db');
    Database myDatabase = await openDatabase(
      dbPath,
      version: Version,
        onCreate: (db, Version) async {
          var batch = db.batch();

          batch.execute('''
          CREATE TABLE Users (
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          FIRST_NAME TEXT NOT NULL,
          LAST_NAME TEXT NOT NULL,
          NUMBER TEXT,
          EMAIL TEXT UNIQUE NOT NULL,
          PASSWORD TEXT NOT NULL,
          IMAGE NOT NULL
          )
          ''');

          batch.execute('''
          CREATE TABLE Events (
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          NAME TEXT NOT NULL,
          LIST_DETAILS_ID INTEGER,
          USER_ID INTEGER NOT NULL,
          STATUS TEXT NOT NULL DEFAULT 'OPEN',
          FOREIGN KEY (USER_ID) REFERENCES Users (ID)
          )
          ''');

          batch.execute('''
          CREATE TABLE FRIENDS (
          USER_ID INTEGER NOT NULL,
          FRIEND_ID INTEGER NOT NULL,
          FOREIGN KEY (USER_ID) REFERENCES Users (ID),
          FOREIGN KEY (FRIEND_ID) REFERENCES Users (ID)
          )  
          ''');


      }
    );
  }
}