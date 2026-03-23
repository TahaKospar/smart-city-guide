import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Inputtext.dart';
import 'package:flutter_application_1/icon.dart';

class Register extends StatefulWidget {
  Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmPassword = TextEditingController();
  GlobalKey<FormState> formstate = GlobalKey();

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart City Guide Login"),
        backgroundColor: Colors.cyan,
        centerTitle: true,
      ),
      body: Form(
        key: formstate,
        child: ListView(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LogoImage(),
                  Text(
                    "Register",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Register Account to Continue Using The App",
                    style: TextStyle(fontWeight: FontWeight.w200),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "  Name",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Inputtext(
                    hintText: "Enter Name",
                    isPassword: false,
                    myController: name,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "  E-mial",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Inputtext(
                    type: TextInputType.emailAddress,
                    hintText: "Enter E-mail",
                    isPassword: false,
                    myController: email,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "  Password",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Inputtext(
                    hintText: "Enter Password",
                    isPassword: true,
                    myController: password,
                  ),
                  SizedBox(height: 10),
                  Text(
                    " Confirm Password",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Inputtext(
                    hintText: "Confirm Password",
                    isPassword: true,
                    myController: confirmPassword,
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(150, 20),
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () async {
                    String? message = "";
                    if (formstate.currentState!.validate()) {
                      if (password.text != confirmPassword.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Password do not match"),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      try {
                        final creditionl = await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                          email: email.text,
                          password: password.text,
                        );
                        await creditionl.user!.updateDisplayName(name.text);
                        await creditionl.user!.reload();
                        await FirebaseFirestore.instance
                            .collection("users")
                            .doc(creditionl.user!.uid)
                            .set({
                          "name": name.text,
                          "email": email.text,
                          "uid": creditionl.user!.uid,
                          "photo": "",
                        });
                        await FirebaseAuth.instance.currentUser!
                            .sendEmailVerification();
                        if (!mounted) return;
                        AwesomeDialog(
                                context: context,
                                animType: AnimType.rightSlide,
                                dialogType: DialogType.success,
                                btnOkOnPress: () {
                                  Navigator.of(context)
                                      .pushReplacementNamed("login");
                                },
                                btnOkIcon: Icons.library_add_check_sharp,
                                title:
                                    "Emial is created \n message sends to gmail",
                                desc:
                                    "Check You'r Account \n if you don't found the message go to more in gmail then spam")
                            .show();
                      } on FirebaseAuthException catch (e) {
                        if (e.code == "email-already-in-use") {
                          message =
                              "The Email is arleady in use Try another Email";
                        } else if (e.code == "weak-password") {
                          message = "Weak Password";
                        } else {
                          message = "${e.code}";
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    "Create",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(" Have Account? "),
                Align(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed("login");
                    },
                    child: Text("login"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
