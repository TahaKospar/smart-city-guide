import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/comments/MyComments.dart';
import 'package:flutter_application_1/places/FavPage.dart';
import 'package:flutter_application_1/places/addPlace.dart';
import 'package:flutter_application_1/places/details.dart';
import 'package:flutter_application_1/places/favorites_provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with SingleTickerProviderStateMixin {
  Future<void> getToken() async {
    await Firebase.initializeApp();
    String? myToken = await FirebaseMessaging.instance.getToken();
    print("------------------------------------------------------");
    print(myToken);
    print("------------------------------------------------------");
  }

  bool isLoading = true;

  Widget getGridview(List<QueryDocumentSnapshot> data) {
    var favProvider = context.watch<FavProvider>();
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          childAspectRatio: (MediaQuery.of(context).size.width /
              (MediaQuery.of(context).size.height * 0.9)),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Map<String, dynamic> placeData =
                data[index].data() as Map<String, dynamic>;
            placeData["id"] = data[index].id;
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Details(data: placeData),
            ));
          },
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: OctoImage(
                  image: NetworkImage(data[index]["imageLink"]),
                  placeholderBuilder:
                      OctoPlaceholder.circularProgressIndicator(),
                  errorBuilder: OctoError.icon(color: Colors.red),
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    data[index]["imageTitle"],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  IconButton(
                    onPressed: () {
                      favProvider.addOrRemoveFav(data[index].id, data[index]);
                    },
                    icon: Icon(
                      favProvider.favPlaces.any((e) => e.id == data[index].id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: favProvider.favPlaces
                              .any((e) => e.id == data[index].id)
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                data[index]["location"],
                style: const TextStyle(fontWeight: FontWeight.w200),
              ),
              const SizedBox(height: 8),
              Text(
                data[index]["description"],
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  TabController? tabcontroller;
  @override
  void initState() {
    super.initState();
    Provider.of<FavProvider>(context, listen: false).fetchAllPlaces();
    tabcontroller = TabController(length: 3, vsync: this);
    getToken();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var favProvider = context.watch<FavProvider>();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => addPlace(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      drawer: Drawer(
        child: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            String userName = "User ";
            String UserEmail =
                FirebaseAuth.instance.currentUser!.email ?? "No Email";
            String userPhoto = "";

            if (snapshot.hasData && snapshot.data!.exists) {
              userName = snapshot.data!["name"] ?? "User";
              userPhoto = snapshot.data!["photo"] ?? "";
            }
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 50, bottom: 20),
                  color: Colors.cyan,
                  child: ListTile(
                    title: Text(userName),
                    subtitle: Text(UserEmail),
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          userPhoto.isNotEmpty ? NetworkImage(userPhoto) : null,
                      child: userPhoto.isEmpty
                          ? const Icon(Icons.person, size: 30)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                ListTile(
                  leading: const Icon(Icons.comment),
                  title: const Text("My Comments"),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const MyComments(),
                    ));
                  },
                ),
                const SizedBox(height: 50),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text("Setting Account"),
                  onTap: () {},
                ),
                const SizedBox(height: 50),
                ListTile(
                  leading: const Icon(Icons.payment_sharp),
                  title: const Text("payments"),
                  onTap: () {},
                ),
                const SizedBox(height: 50),
                ListTile(
                  leading: const Icon(Icons.login_rounded),
                  title: const Text("Logout"),
                  onTap: () async {
                    GoogleSignIn googleSignIn = GoogleSignIn();
                    try {
                      await googleSignIn.signOut();
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          "login",
                          (route) => false,
                        );
                      }
                    } catch (e) {
                      print("Error signing out: $e");
                    }
                  },
                ),
              ],
            );
          },
        ),
      ),
      appBar: AppBar(
        title: const Text("Smart City Guide"),
        backgroundColor: Colors.cyan,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(
                builder: (context) => const FavPage(),
              ))
                  .then((value) {
                setState(() {});
              });
            },
            icon: const Icon(Icons.favorite),
            color: Colors.red,
          ),
          IconButton(
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: CustomSearch(favProvider: favProvider));
            },
            icon: const Icon(Icons.search),
          )
        ],
        bottom: TabBar(controller: tabcontroller, tabs: const [
          Tab(icon: Icon(Icons.location_city, size: 30), text: "Tourists"),
          Tab(icon: Icon(Icons.restaurant, size: 30), text: "Restaurants"),
          Tab(icon: Icon(Icons.hotel_sharp, size: 30), text: "Hotels"),
        ]),
      ),
      body: favProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : TabBarView(controller: tabcontroller, children: [
              getGridview(favProvider.touristData),
              getGridview(favProvider.restaurantData),
              getGridview(favProvider.hotelData),
            ]),
    );
  }
}

class CustomSearch extends SearchDelegate {
  final FavProvider favProvider;
  CustomSearch({required this.favProvider});
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: const Icon(Icons.close))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    final allData = [
      ...favProvider.touristData,
      ...favProvider.restaurantData,
      ...favProvider.hotelData,
    ];
    final getData = allData
        .where((element) => element["imageTitle"]
            .toString()
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: getData.length,
      itemBuilder: (context, index) {
        return ListTile(
          onTap: () {
            Map<String, dynamic> placeData =
                getData[index].data() as Map<String, dynamic>;
            placeData["id"] = getData[index].id;
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => Details(data: placeData),
            ));
          },
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: OctoImage(
              image: NetworkImage(getData[index]["imageLink"]),
              placeholderBuilder: OctoPlaceholder.circularProgressIndicator(),
              errorBuilder: OctoError.icon(color: Colors.red),
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(getData[index]["imageTitle"]),
          subtitle: Text(getData[index]["location"]),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final allData = [
      ...favProvider.touristData,
      ...favProvider.restaurantData,
      ...favProvider.hotelData,
    ];
    final sourceList = query.isEmpty
        ? allData
        : allData
            .where((element) => element["imageTitle"]
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
    return ListView.builder(
      itemCount: sourceList.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            onTap: () {
              Map<String, dynamic> placeData =
                  sourceList[index].data() as Map<String, dynamic>;
              placeData["id"] = sourceList[index].id;
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => Details(data: placeData),
              ));
            },
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: OctoImage(
                image: NetworkImage(sourceList[index]["imageLink"]),
                placeholderBuilder: OctoPlaceholder.circularProgressIndicator(),
                errorBuilder: OctoError.icon(color: Colors.red),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            title: Text(sourceList[index]["imageTitle"]),
            subtitle: Text(sourceList[index]["location"]),
          ),
        );
      },
    );
  }
}
