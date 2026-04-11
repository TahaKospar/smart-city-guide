import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/notification_helper.dart';

class EditComment extends StatefulWidget {
  final String commentId;
  final String placeId;
  final String oldComment;
  final String oldStatus;

  const EditComment({
    super.key,
    required this.commentId,
    required this.placeId,
    required this.oldComment,
    required this.oldStatus,
  });

  @override
  State<EditComment> createState() => _EditCommentState();
}

class _EditCommentState extends State<EditComment> {
  GlobalKey<FormState> formstate = GlobalKey();
  TextEditingController commentController = TextEditingController();
  late String isPublic;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    commentController.text = widget.oldComment;
    isPublic = widget.oldStatus;
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {}
    });
  }

  updateComment() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

    Map<String, dynamic> updatedData = {
      "comment": commentController.text,
      "status": isPublic,
    };

    await FirebaseFirestore.instance
        .collection("place")
        .doc(widget.placeId)
        .collection("note")
        .doc(widget.commentId)
        .update(updatedData);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("my_comments")
        .doc(widget.commentId)
        .update(updatedData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Comment"),
        backgroundColor: Colors.cyan,
      ),
      body: isSaving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: formstate,
              child: ListView(
                children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "  Edit Comment",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          validator: (val) {
                            if (val!.isEmpty) {
                              return "Can't be Empty";
                            }
                            return null;
                          },
                          controller: commentController,
                          maxLines: 5,
                          minLines: 3,
                          decoration: InputDecoration(
                              fillColor: Colors.grey[300],
                              filled: true,
                              hintText: "Enter Comment",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20))),
                        ),
                        RadioListTile(
                          activeColor: Colors.black,
                          title: const Text("Public (All people see it)"),
                          value: "Public",
                          groupValue: isPublic,
                          onChanged: (val) {
                            setState(() {
                              isPublic = val.toString();
                            });
                          },
                        ),
                        RadioListTile(
                          activeColor: Colors.black,
                          title: const Text("Private (You only see it)"),
                          value: "Private",
                          groupValue: isPublic,
                          onChanged: (val) {
                            setState(() {
                              isPublic = val.toString();
                            });
                          },
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 50),
                            alignment: Alignment.center,
                            elevation: 5,
                            fixedSize: const Size(150, 40),
                            backgroundColor: Colors.orange),
                        onPressed: () async {
                          if (formstate.currentState!.validate()) {
                            setState(() {
                              isSaving = true;
                            });
                            await updateComment();
                            await NotificationHelper.sendPushMessage(
                                deviceToken:
                                    "c1NGcX5hR3-qgerNEMp3tg:APA91bENy1BTGEYtdSO4MaAYQxoEsmvZXodcuzuZzuOTXrJJw1FUfj087khEWkQErR-vIwq_yx6YyeB4cUEsJAX07aRYZdtp-TCxxhxN0zZkr_-6_3eBvxs",
                                title: "Comment ",
                                body: "Comment Edited ☑️");
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("${"Comment Edited ✅"}")));
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          }
                        },
                        child: const Text(
                          "Save",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
