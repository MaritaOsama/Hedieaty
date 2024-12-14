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
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          first_name TEXT NOT NULL,
          last_name TEXT NOT NULL,
          number TEXT,
          email TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL,
          image NOT NULL
          )
          ''');

          //List/Events Table
          batch.execute('''
          CREATE TABLE List_Events (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          list_details_id INTEGER,
          user_id INTEGER NOT NULL,
          status TEXT NOT NULL DEFAULT 'open',
          FOREIGN KEY (user_id) REFERENCES Users (id)
          )
          ''');

          //Friends Table
          batch.execute('''
          CREATE TABLE Friends (
          user_id INTEGER NOT NULL,
          friend_id INTEGER NOT NULL,
          FOREIGN KEY (user_is) REFERENCES Users id),
          FOREIGN KEY (friend_id) REFERENCES Users (id)
          )  
          ''');

          //Gift Table
          batch.execute('''
          CREATE TABLE Gifts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          category TEXT,
          price TEXT,
          image TEXT
          )
          ''');

          //Details List/Events List Table
          batch.execute('''
          CREATE TABLE List_Event_Details (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          list_id INTEGER NOT NULL,
          gift_id INTEGER NOT NULL,
          status TEXT NOT NULL DEFAULT 'available',
          FOREIGN KEY (list_id) REFERENCES List_Events (id),
          FOREIGN KEY (pledged_id) REFERENCES Users (id)
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