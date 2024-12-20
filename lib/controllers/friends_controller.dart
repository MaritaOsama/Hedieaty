import 'package:sqflite/sqflite.dart';
import '/models/friends_model.dart';
import '/localDB/database.dart';

class FriendController {
  final DatabaseClass dbHelper = DatabaseClass();

  Future<int> addFriend(Friend friend) async {
    Database? db = await dbHelper.myDB;
    return await db!.insert('Friends', friend.toMap());
  }

  Future<List<Friend>> getFriends() async {
    Database? db = await dbHelper.myDB;
    final List<Map<String, dynamic>> result = await db!.query('Friends');
    return result.map((data) => Friend.fromMap(data)).toList();
  }

  Future<int> deleteFriend(int userId, int friendId) async {
    Database? db = await dbHelper.myDB;
    return await db!.delete(
      'Friends',
      where: 'USER_ID = ? AND FRIEND_ID = ?',
      whereArgs: [userId, friendId],
    );
  }
}
