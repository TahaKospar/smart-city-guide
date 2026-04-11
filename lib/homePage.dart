import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/FavPage.dart';
import 'package:flutter_application_1/Reviews/MyComments.dart';
import 'package:flutter_application_1/detials.dart';
import 'package:flutter_application_1/places/addPlace.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:octo_image/octo_image.dart';

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

  bool isLodaing = true;
  List<QueryDocumentSnapshot> touristData = [];
  List<QueryDocumentSnapshot> restaurantData = [];
  List<QueryDocumentSnapshot> hotelData = [];
  getData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("place")
        .where("isApproved", isEqualTo: true)
        .get();

    touristData = querySnapshot.docs.where((element) {
      final data = element.data() as Map<String, dynamic>;
      return data.containsKey('category') && data['category'] == "tourist";
    }).toList();

    restaurantData = querySnapshot.docs.where((element) {
      final data = element.data() as Map<String, dynamic>;
      return data.containsKey('category') && data['category'] == "restaurant";
    }).toList();

    hotelData = querySnapshot.docs.where((element) {
      final data = element.data() as Map<String, dynamic>;
      return data.containsKey('category') && data['category'] == "hotel";
    }).toList();

    isLodaing = false;
    setState(() {});
  }

  addOrRemoveFav(String placeId) async {
    String uid = FirebaseAuth.instance.currentUser!.uid;

//id بتدور على حاجة، أو عايز تجيب لستة حاجات، أو بتضيف حاجة جديدة ومعايا ال
    CollectionReference favRef = FirebaseFirestore.instance
        .collection("place")
        .doc(placeId)
        .collection("favorite");
    var favCheck = await favRef.where("userId", isEqualTo: uid).get();

    if (favCheck.docs.isEmpty) {
      await favRef.add({"userId": uid});
    } else {
      await favRef.doc(favCheck.docs.first.id).delete();
    }
    setState(() {});
  }

  TabController? tabcontroller;
  @override
  void initState() {
    super.initState();
    getData();
    tabcontroller = TabController(length: 3, vsync: this);
    getToken();
  }

  @override
  void dispose() {
    tabcontroller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            String userPhote = "";

            if (snapshot.hasData && snapshot.data!.exists) {
              userName = snapshot.data!["name"] ?? "User";
              userPhote = snapshot.data!["photo"] ?? "";
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
                          userPhote.isNotEmpty ? NetworkImage(userPhote) : null,
                      child: userPhote.isEmpty
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
                  delegate: CustomSearch(listData: [
                    ...touristData,
                    ...restaurantData,
                    ...hotelData
                  ]));
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
      body: isLodaing
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(controller: tabcontroller, children: [
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 4 : 2,
                    childAspectRatio: (MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height * 0.9)),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20),
                itemCount: touristData.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Map<String, dynamic> placeData =
                          touristData[index].data() as Map<String, dynamic>;
                      placeData["id"] = touristData[index].id;
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Detials(data: placeData),
                      ));
                    },
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: OctoImage(
                            image:
                                NetworkImage(touristData[index]["imageLink"]),
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
                              touristData[index]["imageTitle"],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            IconButton(
                              onPressed: () {
                                addOrRemoveFav(touristData[index].id);
                              },
                              icon: FutureBuilder<QuerySnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection("place")
                                    .doc(touristData[index].id)
                                    .collection("favorite")
                                    .where("userId",
                                        isEqualTo: FirebaseAuth
                                            .instance.currentUser?.uid)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data!.docs.isNotEmpty) {
                                    return const Icon(Icons.favorite,
                                        color: Colors.red);
                                  }
                                  return const Icon(Icons.favorite_border);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          touristData[index]["location"],
                          style: const TextStyle(fontWeight: FontWeight.w200),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          touristData[index]["description"],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 4 : 2,
                    childAspectRatio: (MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height * 0.9)),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20),
                itemCount: restaurantData.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Map<String, dynamic> placeData =
                          restaurantData[index].data() as Map<String, dynamic>;
                      placeData["id"] = restaurantData[index].id;
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Detials(data: placeData),
                      ));
                    },
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          // تعديل الصورة هنا
                          child: OctoImage(
                            image: NetworkImage(
                                restaurantData[index]["imageLink"]),
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
                              restaurantData[index]["imageTitle"],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            IconButton(
                              onPressed: () {
                                addOrRemoveFav(restaurantData[index].id);
                              },
                              icon: FutureBuilder<QuerySnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection("place")
                                    .doc(restaurantData[index].id)
                                    .collection("favorite")
                                    .where("userId",
                                        isEqualTo: FirebaseAuth
                                            .instance.currentUser?.uid)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data!.docs.isNotEmpty) {
                                    return const Icon(Icons.favorite,
                                        color: Colors.red);
                                  }
                                  return const Icon(Icons.favorite_border);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          restaurantData[index]["location"],
                          style: const TextStyle(fontWeight: FontWeight.w200),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          restaurantData[index]["description"],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
              GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        MediaQuery.of(context).size.width > 600 ? 4 : 2,
                    childAspectRatio: (MediaQuery.of(context).size.width /
                        (MediaQuery.of(context).size.height * 0.9)),
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20),
                itemCount: hotelData.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      Map<String, dynamic> placeData =
                          hotelData[index].data() as Map<String, dynamic>;
                      placeData["id"] = hotelData[index].id;
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => Detials(data: placeData),
                      ));
                    },
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          // تعديل الصورة هنا
                          child: OctoImage(
                            image: NetworkImage(hotelData[index]["imageLink"]),
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
                              hotelData[index]["imageTitle"],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            IconButton(
                              onPressed: () {
                                addOrRemoveFav(hotelData[index].id);
                              },
                              icon: FutureBuilder<QuerySnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection("place")
                                    .doc(hotelData[index].id)
                                    .collection("favorite")
                                    .where("userId",
                                        isEqualTo: FirebaseAuth
                                            .instance.currentUser?.uid)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data!.docs.isNotEmpty) {
                                    return const Icon(Icons.favorite,
                                        color: Colors.red);
                                  }
                                  return const Icon(Icons.favorite_border);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hotelData[index]["location"],
                          style: const TextStyle(fontWeight: FontWeight.w200),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          hotelData[index]["description"],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ]),
    );
  }
}

class CustomSearch extends SearchDelegate {
  final List listData;
  CustomSearch({required this.listData});
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
    final getData = listData
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
              builder: (context) => Detials(data: placeData),
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
    final sourceList = query.isEmpty
        ? listData
        : listData
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
                builder: (context) => Detials(data: placeData),
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
