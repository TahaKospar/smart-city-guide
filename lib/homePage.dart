import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/packege/dropDown.dart';
import 'package:flutter_application_1/page1.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int selectedIndex = 0;

  TextEditingController namecontroller = TextEditingController();
  TextEditingController gendercontroller = TextEditingController();
  TextEditingController agecontroller = TextEditingController();

  List<SelectedListItem<String>> KindList = [
    SelectedListItem<String>(data: "Male"),
    SelectedListItem<String>(data: "Female"),
  ];

  @override
  void dispose() {
    namecontroller.dispose();
    gendercontroller.dispose();
    agecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (value) async {
            if (value == 0) {
            } else if (value == 1) {
              if (namecontroller.text.isEmpty ||
                  gendercontroller.text.isEmpty ||
                  agecontroller.text.isEmpty) {
                AwesomeDialog(
                  context: context,
                  animType: AnimType.rightSlide,
                  dialogType: DialogType.info,
                  btnOkIcon: Icons.task_alt_rounded,
                  btnCancelIcon: Icons.close,
                  title: "Warning",
                  desc: "please Enter Data",
                  btnCancelText: "ok",
                  btnCancelOnPress: () {},
                ).show();
              } else {
                AwesomeDialog(
                  context: context,
                  animType: AnimType.rightSlide,
                  dialogType: DialogType.info,
                  btnOkIcon: Icons.task_alt_rounded,
                  btnCancelIcon: Icons.close,
                  title: "Warining",
                  desc: "Are u Sure From This Data?",
                  btnOkText: "Yep i'm Sure",
                  btnCancelText: "No i'm not Sure",
                  btnOkOnPress: () async {
                    SharedPreferences sharedPreferences =
                        await SharedPreferences.getInstance();
                    sharedPreferences.setString("name", namecontroller.text);
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Page1(),
                      ),
                      (route) => false,
                    );
                  },
                  btnCancelOnPress: () {},
                ).show();
              }
            }
          },
          iconSize: 40,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.arrow_circle_left_rounded),
                label: "Login Page"),
            BottomNavigationBarItem(
                icon: Icon(Icons.arrow_circle_right), label: "Signin Page"),
          ]),
      appBar: AppBar(
        title: Text("Login in Smart City Guide"),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
                textEditingController: namecontroller,
                title: "Enter Your Name ",
                hint: "Name",
                isCitySelected: false),
            Text(
              "Enter your age",
              textAlign: TextAlign.start,
            ),
            Container(
              height: 5,
            ),
            TextField(
              controller: agecontroller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(
                    left: 8,
                    bottom: 0,
                    top: 0,
                    right: 15,
                  ),
                  filled: true,
                  hintText: "age",
                  fillColor: Colors.black12,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(60))),
            ),
            Container(
              height: 20,
            ),
            AppTextField(
              textEditingController: gendercontroller,
              title: "Enter Your gender ",
              hint: "gender",
              isCitySelected: true,
              dataList: KindList,
            ),
          ],
        ),
      ),
    );
  }
}
