import 'package:sqflite/sqflite.dart';
import '/models/list_events_model.dart';
import '/localDB/database.dart';

class ListEventController {
  final DatabaseClass dbHelper = DatabaseClass();

  Future<int> addListEvent(ListEvent listEvent) async {
    Database? db = await dbHelper.myDB;
    return await db!.insert('List_Events', listEvent.toMap());
  }

  Future<List<ListEvent>> getListEvents() async {
    Database? db = await dbHelper.myDB;
    final List<Map<String, dynamic>> result = await db!.query('List_Events');
    return result.map((data) => ListEvent.fromMap(data)).toList();
  }

  Future<int> updateListEvent(ListEvent listEvent) async {
    Database? db = await dbHelper.myDB;
    return await db!.update(
      'List_Events',
      listEvent.toMap(),
      where: 'ID = ?',
      whereArgs: [listEvent.id],
    );
  }

  Future<int> deleteListEvent(int id) async {
    Database? db = await dbHelper.myDB;
    return await db!.delete(
      'List_Events',
      where: 'ID = ?',
      whereArgs: [id],
    );
  }
}
