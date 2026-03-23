import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/detials.dart';
import 'package:octo_image/octo_image.dart';

class FavPage extends StatefulWidget {
  const FavPage({super.key});

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  bool isLoading = true;
  List<QueryDocumentSnapshot> favPlaces = [];

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
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Favorites"),
        backgroundColor: Colors.cyan,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favPlaces.isEmpty
              ? const Center(child: Text("No Favorites Yet 💔"))
              : ListView.builder(
                  itemCount: favPlaces.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: InkWell(
                        onTap: () {
                          Map<String, dynamic> placeData =
                              favPlaces[index].data() as Map<String, dynamic>;
                          placeData["id"] = favPlaces[index].id;

                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => Detials(data: placeData),
                          ));
                        },
                        child: ListTile(
                          leading: OctoImage(
                            image: AssetImage(
                              favPlaces[index]["imageLink"],
                            ),
                            placeholderBuilder:
                                OctoPlaceholder.circularProgressIndicator(),
                            errorBuilder: OctoError.icon(color: Colors.red),
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                          ),
                          title: Text(favPlaces[index]["imageTitle"]),
                          subtitle: Text(favPlaces[index]["location"]),
                          trailing: IconButton(
                            onPressed: () async {
                              String uid =
                                  FirebaseAuth.instance.currentUser!.uid;
                              String placeId = favPlaces[index].id;
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
                                favPlaces.removeAt(index);
                                setState(() {});
                              }
                            },
                            icon: const Icon(Icons.restore_from_trash),
                            color: Colors.red,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
