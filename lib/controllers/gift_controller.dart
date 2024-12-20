// controllers/gift_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/models/gift_model.dart';

class GiftController {
  static Future<List<Gift>> loadGifts(CollectionReference giftsCollection) async {
    try {
      QuerySnapshot querySnapshot = await giftsCollection.get();
      return querySnapshot.docs
          .map((doc) => Gift.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error loading gifts: $e");
      return [];
    }
  }

  static void addGift(CollectionReference giftsCollection, Function reloadGifts, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String newName = '';
        String newCategory = '';
        return AlertDialog(
          title: Text("Add New Gift"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: "Gift Name"),
                onChanged: (value) {
                  newName = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: "Gift Category"),
                onChanged: (value) {
                  newCategory = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (newName.isNotEmpty && newCategory.isNotEmpty) {
                  Gift newGift = Gift(id: '', name: newName, category: newCategory);
                  try {
                    await giftsCollection.add(newGift.toMap());
                    reloadGifts();
                    Navigator.pop(context);
                  } catch (e) {
                    print("Error adding gift: $e");
                  }
                }
              },
              child: Text("Add Gift"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  static void deleteGift(String giftId, CollectionReference giftsCollection, Function reloadGifts, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this gift?"),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  await giftsCollection.doc(giftId).delete();
                  reloadGifts();
                  Navigator.pop(context);
                } catch (e) {
                  print("Error deleting gift: $e");
                }
              },
              child: Text("Delete"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  static void editGift(String giftId, String currentName, String currentCategory, CollectionReference giftsCollection, Function reloadGifts, BuildContext context) {
    TextEditingController nameController = TextEditingController(text: currentName);
    TextEditingController categoryController = TextEditingController(text: currentCategory);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Gift"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: InputDecoration(labelText: "Gift Name")),
              TextField(controller: categoryController, decoration: InputDecoration(labelText: "Gift Category")),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String newName = nameController.text;
                String newCategory = categoryController.text;

                if (newName.isNotEmpty && newCategory.isNotEmpty) {
                  try {
                    await giftsCollection.doc(giftId).update({
                      'name': newName,
                      'category': newCategory,
                    });
                    reloadGifts();
                    Navigator.pop(context);
                  } catch (e) {
                    print("Error editing gift: $e");
                  }
                }
              },
              child: Text("Save Changes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }
}
