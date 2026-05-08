import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProviderComment with ChangeNotifier {
  List<QueryDocumentSnapshot> data = [];
  TextEditingController imageLink = TextEditingController();
  TextEditingController comment = TextEditingController();

  bool isLoading = true;
  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  getData(String noteId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("place")
        .doc(noteId)
        .collection("note")
        .where(Filter.or(Filter("status", isEqualTo: "Public"),
            Filter("userId", isEqualTo: uid)))
        .get();
    data = querySnapshot.docs;
    isLoading = false;
    notifyListeners();
  }

  getDataFormMyComments() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("my_comments")
        .get();

    data = querySnapshot.docs;
    isLoading = false;
    notifyListeners();
  }

  deleteComment(String commentId, String noteId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final backComment = data.indexWhere((e) => e.id == commentId);
    final backUpElement = data[backComment];
    data.removeAt(backComment);
    notifyListeners();
    try {
      var placeRef = await FirebaseFirestore.instance
          .collection("place")
          .doc(noteId)
          .collection("note")
          .doc(commentId);
      var userRef = await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("my_comments")
          .doc(commentId);

      await Future.wait([
        placeRef.delete(),
        userRef.delete(),
      ]);
    } catch (e) {
      data.insert(backComment, backUpElement);
      notifyListeners();
      print("Error to Remove");
    }
  }

  Future<void> addComment(String docid, String status) async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    var userDoc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    var placeDoc =
        await FirebaseFirestore.instance.collection("place").doc(docid).get();
    String userName = userDoc.data()?["name"] ?? "User";
    String userImage = userDoc.data()?["photo"] ?? "";
    String placeName = placeDoc.data()?["imageTitle"] ?? "Unknown place";
    String placeImage = placeDoc.data()?["imageLink"] ?? "";

    Map<String, dynamic> commentData = {
      "comment": comment.text,
      "status": status,
      "userId": user.uid,
      "userName": userName,
      "userImage": userImage,
      "placeId": docid,
      "placeTitle": placeName,
      "placeImage": placeImage,
    };
    comment.clear();
    notifyListeners();

    try {
      DocumentReference placeCommentRef = FirebaseFirestore.instance
          .collection("place")
          .doc(docid)
          .collection("note")
          .doc();

      DocumentReference userCommentRef = FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("my_comments")
          .doc(placeCommentRef.id);

      comment.clear();
      notifyListeners();
      await placeCommentRef.set(commentData);
      await userCommentRef.set(commentData);
      print("Comment Added to both Place and User profile");
      await getData(docid);
    } catch (e) {
      print("Error $e");
    }
  }
}
