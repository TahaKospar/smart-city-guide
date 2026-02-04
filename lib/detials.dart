import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class Detials extends StatefulWidget {
  final data;
  const Detials({super.key, this.data});

  @override
  State<Detials> createState() => _DetialsState();
}

class _DetialsState extends State<Detials> {
  String? distanceText;
  bool locationService = false;
  LocationPermission? locationPermission;

  Future<void> _openMap() async {
    final String mapLink = widget.data['map'];
    final Uri url = Uri.parse(mapLink);

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      print("Error opening map: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Detials"),
      ),
      body: ListView(
        children: [
          Image.asset(
            widget.data["imageLink"],
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 15),
            child: Text(
              textAlign: TextAlign.center,
              widget.data["imageTitle"],
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Delius",
                  fontSize: 40),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _openMap,
                icon: Icon(
                  Icons.location_pin,
                ),
                iconSize: 40,
                color: Colors.red,
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  textAlign: TextAlign.center,
                  widget.data["location"],
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontFamily: "Delius"),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(15),
            margin: EdgeInsets.symmetric(vertical: 15),
            child: Text(
              textAlign: TextAlign.center,
              widget.data["description"],
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Delius",
                  fontSize: 30),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 60),
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(60)),
              color: Colors.black,
              textColor: Colors.white,
              onPressed: () async {
                double? distanceInMetter;
                locationService = await Geolocator.isLocationServiceEnabled();
                if (!locationService) {
                  AwesomeDialog(
                    context: context,
                    animType: AnimType.scale,
                    dialogType: DialogType.error,
                    btnCancelIcon: Icons.close,
                    title: "Location not Enabeld",
                    desc: "please turn on of the location",
                    btnCancelOnPress: () {},
                  ).show();
                  return;
                }
                locationPermission = await Geolocator.checkPermission();
                if (locationPermission == LocationPermission.denied) {
                  locationPermission = await Geolocator.requestPermission();
                  if (locationPermission == LocationPermission.denied) {
                    AwesomeDialog(
                      context: context,
                      animType: AnimType.scale,
                      dialogType: DialogType.error,
                      btnCancelIcon: Icons.close,
                      title: "Permission denied",
                      desc: "please give the permission",
                      btnCancelOnPress: () {},
                    ).show();
                    return;
                  }
                  if (locationPermission == LocationPermission.deniedForever) {
                    AwesomeDialog(
                      context: context,
                      animType: AnimType.scale,
                      dialogType: DialogType.error,
                      btnCancelIcon: Icons.close,
                      title: "Permission denied Forever",
                      desc: "please give the permission",
                      btnCancelOnPress: () {},
                    ).show();
                    return;
                  }
                }
                Position position = await Geolocator.getCurrentPosition();
                distanceInMetter = Geolocator.distanceBetween(
                    widget.data["lat"],
                    widget.data["long"],
                    position.latitude,
                    position.longitude);
                setState(() {
                  distanceText = (distanceInMetter! / 1000).toStringAsFixed(1);
                });
              },
              child: Text("Distnation Between"),
            ),
          ),
          distanceText == null
              ? SizedBox()
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(20),
                  alignment: Alignment.center,
                  child: Text("Distance is : $distanceText km"),
                ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 60),
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(60)),
              color: Colors.blueAccent,
              textColor: Colors.white,
              onPressed: _openMap,
              child: Text("Boot it now"),
            ),
          )
        ],
      ),
    );
  }
}
