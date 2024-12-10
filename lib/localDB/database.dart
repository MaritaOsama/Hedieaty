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

  dynamic initialize() async {
    String dbDestination = await getDatabasesPath();
    String dbPath = join(dbDestination, 'mydatabase.db');
    Database myDatabase = await openDatabase(
      dbPath,
      version: Version,
        onCreate: (db, Version) async {
          var batch = db.batch();

          // Users Table
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

          //List/Events Table
          batch.execute('''
          CREATE TABLE List_Events (
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          NAME TEXT NOT NULL,
          LIST_DETAILS_ID INTEGER,
          USER_ID INTEGER NOT NULL,
          STATUS TEXT NOT NULL DEFAULT 'open',
          FOREIGN KEY (USER_ID) REFERENCES Users (ID)
          )
          ''');

          //Friends Table
          batch.execute('''
          CREATE TABLE Friends (
          USER_ID INTEGER NOT NULL,
          FRIEND_ID INTEGER NOT NULL,
          FOREIGN KEY (USER_ID) REFERENCES Users (ID),
          FOREIGN KEY (FRIEND_ID) REFERENCES Users (ID)
          )  
          ''');

          //Gift Table
          batch.execute('''
          CREATE TABLE Gifts (
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          NAME TEXT NOT NULL,
          DESCRIPTION TEXT,
          CATEGORY TEXT,
          PRICE REAL,
          IMAGE TEXT
          )
          ''');

          //Details List/Events List Table
          batch.execute('''
          CREATE TABLE List_Event_Details (
          ID INTEGER PRIMARY KEY AUTOINCREMENT,
          LIST_ID INTEGER NOT NULL,
          GIFT_ID INTEGER NOT NULL,
          STATUS TEXT NOT NULL DEFAULT 'available',
          FOREIGN KEY (LIST_ID) REFERENCES List_Events (ID),
          FOREIGN KEY (PLEDGED_ID) REFERENCES Users (ID)
          )
          ''');

          await batch.commit();
          print("Database has been created .......");
      }
    );
    return myDatabase;
  }

  dynamic readData(String SQL) async {
    Database? mydata = await myDB;
    print("Retrieving Database...");
    var response = await mydata!.rawQuery(SQL);
    return response;
  }

  insertData(String SQL) async {
    Database? mydata = await myDB;
    print("Inserting Into Database...");
    int response = await mydata!.rawInsert(SQL);
    return response;
  }

  deleteData(String SQL) async {
    Database? mydata = await myDB;
    print("Deleting from Database...");
    int response = await mydata!.rawDelete(SQL);
    return response;
  }

  updateData(String SQL) async {
    Database? mydata = await myDB;
    print("Updating Database...");
    int response = await mydata!.rawUpdate(SQL);
    return response;
  }

  mydeletedatabase() async {
    String database = await getDatabasesPath();
    String Path = join(database, 'mydatabase.db');
    bool ifitexist = await databaseExists(Path);
    if (ifitexist == true) {
      print('it exist');
    } else {
      print("it doesn't exist");
    }
    await deleteDatabase(Path);
    print("MyData has been deleted");
  }
}