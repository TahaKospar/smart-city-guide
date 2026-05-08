import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/comments/add.dart';
import 'package:flutter_application_1/comments/edit.dart';
import 'package:flutter_application_1/comments/providerComment.dart';
import 'package:flutter_application_1/notification_helper.dart';
import 'package:provider/provider.dart';

class Review extends StatefulWidget {
  final String noteId;
  const Review({super.key, required this.noteId});

  @override
  State<Review> createState() => _ReviewState();
}

class _ReviewState extends State<Review> {
  @override
  void initState() {
    Provider.of<ProviderComment>(context, listen: false).getData(widget.noteId);
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print("========++++++++++=============++++++++++++=============");
        print("title is:--  ${message.notification!.title}");
        print("body is:--  ${message.notification!.body}");
        print("========++++++++++=============++++++++++++=============");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var commentProvider = context.watch<ProviderComment>();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => Add(
              docid: widget.noteId,
            ),
          ));
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("Reviews"),
        backgroundColor: Colors.cyan,
        centerTitle: true,
      ),
      body: commentProvider.isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: commentProvider.data.length,
              itemBuilder: (context, index) {
                String currentUserId = FirebaseAuth.instance.currentUser!.uid;
                var commentData =
                    commentProvider.data[index].data() as Map<String, dynamic>;
                String commentOwnerId = commentData["userId"] ?? "";
                String userName = commentData["userName"] ?? "unKnown";
                String userImage = commentData["userImage"] ?? "";
                String st = commentData["status"] ?? "";

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.cyan,
                        backgroundImage: userImage.isNotEmpty
                            ? NetworkImage(userImage)
                            : null,
                        child: userImage.isEmpty
                            ? Text(
                                userName.isNotEmpty
                                    ? userName[0].toUpperCase()
                                    : "U",
                                style: TextStyle(color: Colors.white))
                            : null,
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              userName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            commentData["status"],
                            style: TextStyle(
                              fontSize: 12,
                              color: commentData["status"] == "Public"
                                  ? Colors.green
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                      subtitle: Text(
                        commentData["comment"],
                        style: TextStyle(fontSize: 15),
                      ),
                      trailing: currentUserId == commentOwnerId
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    await Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => EditComment(
                                        commentId:
                                            commentProvider.data[index].id,
                                        placeId: commentData["placeId"] ??
                                            widget.noteId,
                                        oldComment: commentData["comment"],
                                        oldStatus: commentData["status"],
                                      ),
                                    ));
                                  },
                                  child: const Icon(Icons.edit,
                                      color: Colors.blue, size: 20),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: () async {
                                    commentProvider.deleteComment(
                                        commentProvider.data[index].id,
                                        widget.noteId);
                                    await NotificationHelper.sendPushMessage(
                                        deviceToken:
                                            "c1NGcX5hR3-qgerNEMp3tg:APA91bENy1BTGEYtdSO4MaAYQxoEsmvZXodcuzuZzuOTXrJJw1FUfj087khEWkQErR-vIwq_yx6YyeB4cUEsJAX07aRYZdtp-TCxxhxN0zZkr_-6_3eBvxs",
                                        title: "Comment ",
                                        body: "Comment Deleted 🤦‍♂️☑️");
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                "${"Comment Deleted ✅"}")));
                                  },
                                  child: const Icon(Icons.delete,
                                      color: Colors.red, size: 20),
                                ),
                              ],
                            )
                          : null),
                );
              },
            ),
    );
  }
}
