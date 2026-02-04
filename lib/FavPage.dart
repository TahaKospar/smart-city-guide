import 'package:flutter/material.dart';
import 'package:flutter_application_1/detials.dart';

class FavPage extends StatelessWidget {
  final List allData;

  const FavPage({super.key, required this.allData});

  @override
  Widget build(BuildContext context) {
    List favList =
        allData.where((element) => element["isFav"] == true).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("My Favorites ❤️"),
        backgroundColor: Colors.redAccent,
      ),
      body: favList.isEmpty
          ? Center(child: Text("No Favorites yet! 💔"))
          : ListView.builder(
              itemCount: favList.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.asset(favList[index]["imageLink"],
                        width: 60, fit: BoxFit.cover),
                    title: Text(favList[index]["imageTitle"]),
                    subtitle: Text(favList[index]["location"]),
                    trailing: Icon(Icons.favorite, color: Colors.red),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (c) => Detials(data: favList[index])));
                    },
                  ),
                );
              },
            ),
    );
  }
}
