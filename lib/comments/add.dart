import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/comments/providerComment.dart';
import 'package:flutter_application_1/notification_helper.dart';
import 'package:provider/provider.dart';

class Add extends StatefulWidget {
  final String? docid;
  const Add({super.key, required this.docid});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  String isPublic = "Private";

  GlobalKey<FormState> formstate = GlobalKey();
  String? Function(String?)? validator;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {}
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var providerAdd = context.watch<ProviderComment>();
    return Scaffold(
      appBar: AppBar(
        title: Text("Add comment"),
        backgroundColor: Colors.cyan,
      ),
      body: Form(
        key: formstate,
        child: ListView(
          children: [
            Container(
              margin: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "   Comment",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    validator: (val) {
                      if (val!.isEmpty) {
                        return "Can't be Empty";
                      }
                    },
                    controller: providerAdd.comment,
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
                    title: Text("Puplic All people see it"),
                    value: "Public",
                    groupValue: isPublic,
                    onChanged: (val) {
                      setState(() {
                        isPublic = val!;
                      });
                    },
                  ),
                  RadioListTile(
                    activeColor: Colors.black,
                    title: Text(" Private You only see it "),
                    value: "Private",
                    groupValue: isPublic,
                    onChanged: (val) {
                      setState(() {
                        isPublic = val!;
                      });
                    },
                  ),
                  SizedBox(
                    height: 100,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 50),
                      alignment: Alignment.center,
                      elevation: 5,
                      fixedSize: Size(150, 20),
                      backgroundColor: Colors.orange),
                  onPressed: () async {
                    if (formstate.currentState!.validate()) {
                      providerAdd.addComment(widget.docid!, isPublic);
                      Navigator.of(context).pop();
                      await NotificationHelper.sendPushMessage(
                          deviceToken:
                              "evdBr7Z9QDSQOfyDKwjL7E:APA91bFUIQaEYpCmqduF4BSrPSnEJMWJfXjLbRe3ODl-vIQEUUG6FTcx2FEhSinP69OR6x9Dq1ZVUO-Lh7qgw9sA_Lt1ncc0jtND1FSFsscVZloXlloK-0c",
                          title: "Comment ",
                          body: "Comment Added 🤦‍♂️☑️");
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("${"Comment Added ✅"}")));
                      if (context.mounted) {}
                    }
                  },
                  child: Text(
                    "Add",
                    style: TextStyle(color: Colors.white),
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
