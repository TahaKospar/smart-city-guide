import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Reviews/review.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class Detials extends StatefulWidget {
  final data;
  const Detials({
    super.key,
    this.data,
  });

  @override
  State<Detials> createState() => _DetialsState();
}

class _DetialsState extends State<Detials> {
  String? distaceText;
  getPermission() async {
    bool serviceEnable;
    LocationPermission permission;

    serviceEnable = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnable) {
      AwesomeDialog(
              context: context,
              animType: AnimType.bottomSlide,
              dialogType: DialogType.error,
              btnOkOnPress: () {},
              title: "GPS is Off",
              desc: "Please Open Location In Your Device")
          .show();
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AwesomeDialog(
                context: context,
                animType: AnimType.bottomSlide,
                dialogType: DialogType.error,
                btnOkOnPress: () {},
                title: "Please Check Permission")
            .show();
      }
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      Position position = await Geolocator.getCurrentPosition();
      double distanceMetter = Geolocator.distanceBetween(widget.data["lat"],
          widget.data["lng"], position.latitude, position.longitude);
      double distanceInKM = distanceMetter / 1000;
      setState(() {
        distaceText = "${distanceInKM.toStringAsFixed(2)}KM ";
      });
    }
  }

  Future<void> openMap() async {
    final Uri googleUrl = Uri.parse(widget.data["map"]);

    if (!await launchUrl(googleUrl, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open the map.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart City Guide"),
        centerTitle: true,
        backgroundColor: Colors.cyan,
      ),
      body: Container(
        margin: EdgeInsets.all(15),
        child: ListView(
          children: [
            Column(
              children: [
                Image.network(
                  widget.data["imageLink"],
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  widget.data["imageTitle"],
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        openMap();
                      },
                      icon: Icon(Icons.location_on_outlined),
                      color: Colors.red,
                      iconSize: 40,
                    ),
                    Text(
                      widget.data["location"],
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  widget.data["description"],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey),
                  onPressed: () {
                    openMap();
                  },
                  child: Text(
                    "Boot It Now",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey),
                  onPressed: () {
                    getPermission();
                  },
                  child: Text(
                    "Calc Defrence ",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Review(noteId: widget.data["id"]),
                    ));
                  },
                  child: Text(
                    "View Reviews",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (distaceText != null)
                  Container(
                    width: 300,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(60)),
                    child: Text(
                      "$distaceText",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
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
