import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavProvider with ChangeNotifier {
  List<QueryDocumentSnapshot> favPlaces = [];
  List<QueryDocumentSnapshot> touristData = [];
  List<QueryDocumentSnapshot> restaurantData = [];
  List<QueryDocumentSnapshot> hotelData = [];
  bool isLoading = true;

  getData() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot places =
        await FirebaseFirestore.instance.collection("place").get();

    List<QueryDocumentSnapshot> temp = [];

    for (var place in places.docs) {
      var favCheck = await FirebaseFirestore.instance
          .collection("place")
          .doc(place.id)
          .collection("favorite")
          .where("userId", isEqualTo: uid)
          .get();

      if (favCheck.docs.isNotEmpty) {
        temp.add(place);
      }
    }

    favPlaces = temp;
    isLoading = false;
    notifyListeners();
  }

  void removeFavorite(String placeId) {
    favPlaces.removeWhere((place) => place.id == placeId);
    notifyListeners();
  }

  void addOrRemoveFav(String placeId, QueryDocumentSnapshot placeDoc) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    int index = favPlaces.indexWhere((element) => element.id == placeId);

    if (index != -1) {
      favPlaces.removeAt(index);
    } else {
      favPlaces.add(placeDoc);
    }
    notifyListeners();

    CollectionReference favRef = FirebaseFirestore.instance
        .collection("place")
        .doc(placeId)
        .collection("favorite");
    var favCheck = await favRef.where("userId", isEqualTo: uid).get();

    if (favCheck.docs.isEmpty) {
      await favRef.add({"userId": uid});
    } else {
      await favRef.doc(favCheck.docs.first.id).delete();
    }
    notifyListeners();
  }

  Future<void> fetchAllPlaces() async {
    if (touristData.isNotEmpty ||
        restaurantData.isNotEmpty ||
        hotelData.isNotEmpty) {
      isLoading = false;
      return;
    }

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection("place")
          .where("isApproved", isEqualTo: true)
          .get();

      touristData =
          querySnapshot.docs.where((e) => e['category'] == "tourist").toList();
      restaurantData = querySnapshot.docs
          .where((e) => e['category'] == "restaurant")
          .toList();
      hotelData =
          querySnapshot.docs.where((e) => e['category'] == "hotel").toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      print(e);
    }
  }

  Future<void> removeFav(String placeId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final index = favPlaces.indexWhere((e) => e.id == placeId);

    if (index != -1) {
      final backUpFav = favPlaces[index];

      favPlaces.removeAt(index);
      notifyListeners();
      try {
        var favCheck = await FirebaseFirestore.instance
            .collection("place")
            .doc(placeId)
            .collection("favorite")
            .where("userId", isEqualTo: uid)
            .get();
        if (favCheck.docs.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection("place")
              .doc(placeId)
              .collection("favorite")
              .doc(favCheck.docs.first.id)
              .delete();
          removeFavorite(placeId);
        }
      } catch (e) {
        favPlaces.insert(index, backUpFav);
        notifyListeners();
        print("Error $e");
      }
    }
  }
}
