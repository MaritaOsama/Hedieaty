import 'package:sqflite/sqflite.dart';
import '/models/gift_model.dart';
import '/localDB/database.dart';

class GiftController {
  final DatabaseClass dbHelper = DatabaseClass();

  Future<int> addGift(Gift gift) async {
    Database? db = await dbHelper.myDB;
    return await db!.insert('Gifts', gift.toMap());
  }

  Future<List<Gift>> getGifts() async {
    Database? db = await dbHelper.myDB;
    final List<Map<String, dynamic>> result = await db!.query('Gifts');
    return result.map((data) => Gift.fromMap(data)).toList();
  }

  Future<int> updateGift(Gift gift) async {
    Database? db = await dbHelper.myDB;
    return await db!.update(
      'Gifts',
      gift.toMap(),
      where: 'ID = ?',
      whereArgs: [gift.id],
    );
  }

  Future<int> deleteGift(int id) async {
    Database? db = await dbHelper.myDB;
    return await db!.delete(
      'Gifts',
      where: 'ID = ?',
      whereArgs: [id],
    );
  }
}
