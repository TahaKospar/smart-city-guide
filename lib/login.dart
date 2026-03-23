import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Inputtext.dart';
import 'package:flutter_application_1/icon.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLoading = false;
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  final GlobalKey<FormState> formstate = GlobalKey();

  Future signInWithGoogle() async {
    try {
      isLoading = true;
      setState(() {});
      final GoogleSignInAccount? googleUsr = await GoogleSignIn().signIn();
      if (googleUsr == null) {
        setState(() {
          isLoading = false;
        });
        print("Null");
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUsr.authentication;

      final credential = await GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      isLoading = false;
      setState(() {});
      print("Error during Google Sign-In: $e");
    }

    final user = FirebaseAuth.instance.currentUser;
    final usrRef =
        FirebaseFirestore.instance.collection("users").doc(user!.uid);

    final doc = await usrRef.get();
    if (!doc.exists) {
      // if user sign in first time
      String nameInput = "";
      String? userName = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Enter Your Name"),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: "Name"),
            onChanged: (value) {
              nameInput = value;
            },
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pop(nameInput.isEmpty ? null : nameInput);
                },
                child: Text("Ok"))
          ],
        ),
      );
      await usrRef.set({
        "name": userName ?? user.displayName ?? "User",
        "email": user.email,
        "photo": user.photoURL ?? ""
      });
    } else {
      print("Welcome back ${doc["name"]}");
    }
    Navigator.of(context).pushReplacementNamed("homepage");
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
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
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
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
                          "Login",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Login to Continue Using The App",
                          style: TextStyle(fontWeight: FontWeight.w200),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "  E-mial",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
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
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        Inputtext(
                          hintText: "Enter Password",
                          isPassword: true,
                          myController: password,
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                            onPressed: () async {
                              if (email.text == "") {
                                AwesomeDialog(
                                  context: context,
                                  animType: AnimType.leftSlide,
                                  dialogType: DialogType.error,
                                  title: "Email is Empty",
                                  desc: "Please Enter Emial First5",
                                  btnOkOnPress: () {},
                                ).show();
                                return;
                              }
                              try {
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(email: email.text);
                                if (!mounted) return;
                                AwesomeDialog(
                                  context: context,
                                  animType: AnimType.leftSlide,
                                  dialogType: DialogType.info,
                                  title: "Reset password is Send",
                                  desc:
                                      "Check Your Account Reset password is Send",
                                  btnOkOnPress: () {},
                                ).show();
                              } on FirebaseAuthException catch (e) {
                                if (e.code ==
                                    "firebase_auth/network-request-failed] A network error (such as timeout, interrupted connection or unreachable host) has occurred") {
                                  AwesomeDialog(
                                    context: context,
                                    animType: AnimType.leftSlide,
                                    dialogType: DialogType.error,
                                    title: "No internet",
                                    desc:
                                        "Please Check Your Internet Connection",
                                    btnOkOnPress: () {},
                                  ).show();
                                }
                              } catch (e) {
                                print("======================================");
                                print(e);
                              }
                            },
                            child: Text("Forget Password"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
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
                            try {
                              isLoading = true;
                              setState(() {});
                              final creditional = await FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: email.text,
                                      password: password.text);

                              if (!mounted) return;
                              await FirebaseAuth.instance.currentUser!.reload();
                              isLoading = false;
                              setState(() {});
                              if (FirebaseAuth
                                  .instance.currentUser!.emailVerified) {
                                Navigator.of(context)
                                    .pushReplacementNamed("homepage");
                              } else {
                                AwesomeDialog(
                                        context: context,
                                        animType: AnimType.rightSlide,
                                        dialogType: DialogType.error,
                                        title: "Email Not Verified",
                                        btnOkOnPress: () {},
                                        desc:
                                            "please Verifi from your account first")
                                    .show();
                              }
                            } on FirebaseAuthException catch (e) {
                              isLoading = false;
                              setState(() {});
                              if (e.code == "user-not-found") {
                                message = "Error Data";
                              } else if (e.code == "invalid-credential") {
                                message = "Error Data";
                              } else {
                                message = "Error ${e.code}";
                              }
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("${message}"),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.red,
                              ));
                            }
                          }
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "  Or Login With...",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(120),
                        child: Image.asset("assets/google.png", height: 70),
                        onTap: () {
                          signInWithGoogle();
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't Have Account? "),
                      Align(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacementNamed("register");
                          },
                          child: Text("register"),
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
