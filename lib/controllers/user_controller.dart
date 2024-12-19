import 'package:sqflite/sqflite.dart';
import '/models/users_model.dart';
import '/localDB/database.dart';

class UserController {
  final DatabaseClass dbHelper = DatabaseClass();

  Future<int> addUser(User user) async {
    Database? db = await dbHelper.myDB;
    return await db!.insert('Users', user.toMap());
  }

  Future<List<User>> getUsers() async {
    Database? db = await dbHelper.myDB;
    final List<Map<String, dynamic>> result = await db!.query('Users');
    return result.map((data) => User.fromMap(data)).toList();
  }

  Future<int> updateUser(User user) async {
    Database? db = await dbHelper.myDB;
    return await db!.update(
      'Users',
      user.toMap(),
      where: 'ID = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int id) async {
    Database? db = await dbHelper.myDB;
    return await db!.delete(
      'Users',
      where: 'ID = ?',
      whereArgs: [id],
    );
  }
}
