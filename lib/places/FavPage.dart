import 'package:flutter/material.dart';
import 'package:flutter_application_1/places/details.dart';
import 'package:flutter_application_1/places/favorites_provider.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';

class FavPage extends StatefulWidget {
  const FavPage({super.key});

  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    Provider.of<FavProvider>(context, listen: false).getData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavProvider>(builder: (context, favProvider, child) {
      if (favProvider.isLoading) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("My Favorites"),
            backgroundColor: Colors.cyan,
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      }
      return Scaffold(
        appBar: AppBar(
          title: const Text("My Favorites"),
          backgroundColor: Colors.cyan,
        ),
        body: favProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : favProvider.favPlaces.isEmpty
                ? const Center(child: Text("No Favorites Yet 💔"))
                : ListView.builder(
                    itemCount: favProvider.favPlaces.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: InkWell(
                          onTap: () {
                            Map<String, dynamic> placeData =
                                favProvider.favPlaces[index].data()
                                    as Map<String, dynamic>;
                            placeData["id"] = favProvider.favPlaces[index].id;

                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Details(data: placeData),
                            ));
                          },
                          child: ListTile(
                            leading: OctoImage(
                              image: NetworkImage(
                                favProvider.favPlaces[index]["imageLink"],
                              ),
                              placeholderBuilder:
                                  OctoPlaceholder.circularProgressIndicator(),
                              errorBuilder: OctoError.icon(color: Colors.red),
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            ),
                            title: Text(
                                favProvider.favPlaces[index]["imageTitle"]),
                            subtitle:
                                Text(favProvider.favPlaces[index]["location"]),
                            trailing: IconButton(
                              onPressed: () async {
                                String placeId =
                                    favProvider.favPlaces[index].id;
                                favProvider.removeFav(placeId);
                              },
                              icon: const Icon(Icons.restore_from_trash),
                              color: Colors.red,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      );
    });
  }
}
