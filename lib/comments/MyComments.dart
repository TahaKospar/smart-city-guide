import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/comments/edit.dart';
import 'package:flutter_application_1/comments/providerComment.dart';
import 'package:flutter_application_1/places/details.dart';
import 'package:provider/provider.dart';

class MyComments extends StatefulWidget {
  const MyComments({super.key});

  @override
  State<MyComments> createState() => _MyCommentsState();
}

class _MyCommentsState extends State<MyComments> {

  @override
  void initState() {
    super.initState();
    Provider.of<ProviderComment>(context, listen: false)
        .getDataFormMyComments();
  }

  @override
  Widget build(BuildContext context) {
    var commentProvider = Provider.of<ProviderComment>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Comments"),
        backgroundColor: Colors.cyan,
        centerTitle: true,
      ),
      body:commentProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          :commentProvider.data.isEmpty
              ? const Center(child: Text("No comments found"))
              : ListView.builder(
                  itemCount: commentProvider.data.length,
                  itemBuilder: (context, index) {
                    String currentUserId =
                        FirebaseAuth.instance.currentUser!.uid;
                    var commentData =
                        commentProvider.data[index].data() as Map<String, dynamic>;
                    String commentOwnerId = commentData["userId"] ?? "";
                    String st = commentData["status"] ?? "";
                    String placeName =
                        commentData["placeTitle"] ?? "Unknown Place";
                    String placeImage = commentData["placeImage"] ?? "";

                    // ✅ طباعة الرابط للتأكد
                    print("Image URL: $placeImage");

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      child: ListTile(
                        onTap: () async {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                                child: CircularProgressIndicator()),
                          );

                          try {
                            DocumentSnapshot placeDoc = await FirebaseFirestore
                                .instance
                                .collection("place")
                                .doc(commentData["placeId"])
                                .get();

                            if (context.mounted) Navigator.of(context).pop();

                            if (placeDoc.exists) {
                              Map<String, dynamic> fullPlaceData =
                                  placeDoc.data() as Map<String, dynamic>;
                              fullPlaceData["id"] = placeDoc.id;

                              if (context.mounted) {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      Details(data: fullPlaceData),
                                ));
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("The Place is Not Found")),
                                );
                              }
                            }
                          } catch (e) {
                            if (context.mounted) Navigator.of(context).pop();
                            print("Error: $e");
                          }
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: placeImage.isNotEmpty
                              ? Image.network(
                                  placeImage,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    print("Error loading image: $error");
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      color: Colors.grey,
                                      child: const Icon(Icons.broken_image,
                                          size: 20),
                                    );
                                  },
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey,
                                  child: const Icon(Icons.image_not_supported,
                                      size: 20),
                                ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                placeName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              st,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    st == "Public" ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          commentData["comment"] ?? "",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        trailing: currentUserId == commentOwnerId
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      await Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => EditComment(
                                          commentId: commentProvider.data[index].id,
                                          placeId: commentData["placeId"],
                                          oldComment:
                                              commentData["comment"] ?? "",
                                          oldStatus:
                                              commentData["status"] ?? "Public",
                                        ),
                                      ));
                                      commentProvider.getDataFormMyComments();
                                    },
                                    child: const Icon(Icons.edit,
                                        color: Colors.blue, size: 20),
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () {
                                      commentProvider.deleteComment(
                                          commentProvider.data[index].id,
                                          commentData["placeId"]);
                                    },
                                    child: const Icon(Icons.delete,
                                        color: Colors.red, size: 20),
                                  ),
                                ],
                              )
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
