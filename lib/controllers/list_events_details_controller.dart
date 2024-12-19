import 'package:sqflite/sqflite.dart';
import '/models/list_event_details_model.dart';
import '/localDB/database.dart';

class ListEventDetailController {
  final DatabaseClass dbHelper = DatabaseClass();

  Future<int> addListEventDetail(ListEventDetail detail) async {
    Database? db = await dbHelper.myDB;
    return await db!.insert('List_Event_Details', detail.toMap());
  }

  Future<List<ListEventDetail>> getListEventDetails() async {
    Database? db = await dbHelper.myDB;
    final List<Map<String, dynamic>> result = await db!.query('List_Event_Details');
    return result.map((data) => ListEventDetail.fromMap(data)).toList();
  }

  Future<int> updateListEventDetail(ListEventDetail detail) async {
    Database? db = await dbHelper.myDB;
    return await db!.update(
      'List_Event_Details',
      detail.toMap(),
      where: 'ID = ?',
      whereArgs: [detail.id],
    );
  }

  Future<int> deleteListEventDetail(int id) async {
    Database? db = await dbHelper.myDB;
    return await db!.delete(
      'List_Event_Details',
      where: 'ID = ?',
      whereArgs: [id],
    );
  }
}
