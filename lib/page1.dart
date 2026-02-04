import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'detials.dart';
import 'homePage.dart';
import 'FavPage.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

StreamSubscription<Position>? positionStream;

class _Page1State extends State<Page1> with SingleTickerProviderStateMixin {
  String? userName = "";
  getData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    setState(() {
      userName = sharedPreferences.getString("name");
    });
  }

  void saveFav() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> likedItem = [];

    for (var item in TouristItem) {
      if (item["isFav"] == true) {
        likedItem.add(item["imageTitle"]);
      }
    }
    for (var item in RestaurantItem) {
      if (item["isFav"] == true) {
        likedItem.add(item["imageTitle"]);
      }
    }
    await sharedPreferences.setStringList("my_fav", likedItem);
  }

  void loadFav() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    List<String> savedFav = sharedPreferences.getStringList("my_fav") ?? [];
    if (savedFav.isNotEmpty) {
      setState(() {
        for (var item in TouristItem) {
          if (savedFav.contains(item["imageTitle"])) {
            item["isFav"] = true;
          }
        }
      });
    }
    if (savedFav.isNotEmpty) {
      setState(() {
        for (var item in RestaurantItem) {
          if (savedFav.contains(item["imageTitle"])) {
            item["isFav"] = true;
          }
        }
      });
    }
  }

  late TabController tebcontroller;
  @override
  void initState() {
    super.initState();
    getData();
    loadFav();
    tebcontroller = TabController(length: 2, vsync: this);
    userName;
  }

  List TouristItem = [
    {
      "imageLink": "assets/1.png",
      "imageTitle": "Pyramids",
      "location": "elgiza",
      "lat": 29.9792,
      "long": 31.1342,
      "description":
          "Experience ancient history at the Great Pyramids of Giza and the Sphinx",
      "map": "https://www.google.com/maps/search/?api=1&query=Pyramids+of+Giza",
      "isFav": false,
    },
    {
      "imageLink": "assets/3.png",
      "imageTitle": "Cairo Tour",
      "location": "Cairo",
      "lat": 30.0459,
      "long": 31.2243,
      "description":
          "Enjoy panoramic views from Cairo Tower and the majesty of the Citadel",
      "map": "https://www.google.com/maps/search/?api=1&query=Cairo+Tower",
      "isFav": false,
    },
    {
      "imageLink": "assets/4.png",
      "imageTitle": "World",
      "location": "Aswan",
      "lat": 24.0258,
      "long": 32.8847,
      "description":
          "The land of gold. Sail the Nile to the beautiful Philae Temple",
      "map":
          "https://www.google.com/maps/search/?api=1&query=Philae+Temple+Aswan",
      "isFav": false,
    },
    {
      "imageLink": "assets/5.png",
      "imageTitle": "Elcaranc",
      "location": "Luxor",
      "lat": 25.7188,
      "long": 32.6575,
      "description":
          "The world's greatest open-air museum. Explore the massive Karnak Temple",
      "map":
          "https://www.google.com/maps/search/?api=1&query=Karnak+Temple+Luxor",
      "isFav": false,
    },
  ];
  List RestaurantItem = [
    {
      "imageLink": "assets/11.jpg",
      "imageTitle": "Abou El Sid",
      "location": "Cairo",
      "lat": 30.0595,
      "long": 31.2216,
      "description":
          "Authentic Egyptian cuisine in a classic setting at Zamalek, popular for traditional dishes like molokhia and feteer.",
      "map":
          "https://www.google.com/maps/search/?api=1&query=Abou+El+Sid+Restaurant+Zamalek",
      "isFav": false,
    },
    {
      "imageLink": "assets/12.jpg",
      "imageTitle": "Abou Tarek",
      "location": "Cairo",
      "lat": 30.0526,
      "long": 31.2386,
      "description":
          "Famous for its iconic koshari, a must-try Egyptian national dish with lentils, rice and pasta.",
      "map":
          "https://www.google.com/maps/search/?api=1&query=Koshary+Abou+Tarek",
      "isFav": false,
    },
    {
      "imageLink": "assets/13.jpg",
      "imageTitle": "Felfela",
      "location": "Cairo",
      "lat": 30.0442,
      "long": 31.2378,
      "description":
          "Historic restaurant offering Egyptian and Middle Eastern cuisine in Downtown Cairo.",
      "map": "https://www.google.com/maps/search/?api=1&query=Felfela+Downtown",
      "isFav": false,
    },
    {
      "imageLink": "assets/14.jpg",
      "imageTitle": "Zitouni",
      "location": "Cairo",
      "lat": 30.0366,
      "long": 31.2283,
      "description":
          "Elegant Nile-side restaurant at Four Seasons offering Egyptian and Lebanese classics.",
      "map":
          "https://www.google.com/maps/search/?api=1&query=Zitouni+Restaurant+Cairo",
      "isFav": false,
    },
    {
      "imageLink": "assets/15.jpg",
      "imageTitle": "Bab El Nil",
      "location": "Cairo",
      "lat": 30.0715,
      "long": 31.2282,
      "description":
          "Popular venue on the Nile Corniche with traditional Egyptian cuisine and outdoor seating.",
      "map":
          "https://www.google.com/maps/search/?api=1&query=Bab+El+Nil+Restaurant",
      "isFav": false,
    },
    {
      "imageLink": "assets/16.jpg",
      "imageTitle": "Saigon Restaurant",
      "location": "Cairo",
      "lat": 30.0715,
      "long": 31.2282,
      "description":
          "Asian fusion restaurant with Thai and Chinese dishes in a lively atmosphere.",
      "map":
          "https://www.google.com/maps/search/?api=1&query=Saigon+Restaurant+and+Lounge",
      "isFav": false,
    },
    {
      "imageLink": "assets/17.jpg",
      "imageTitle": "Le Bodega",
      "location": "Cairo",
      "lat": 30.0595,
      "long": 31.2216,
      "description":
          "Italian dining in Zamalek known for pasta, pizzas and Mediterranean flavors.",
      "map": "https://www.google.com/maps/search/?api=1&query=Le+Bodega+Cairo",
      "isFav": false,
    },
    {
      "imageLink": "assets/18.jpg",
      "imageTitle": "JWs Steakhouse",
      "location": "Cairo",
      "lat": 30.0744,
      "long": 31.4345,
      "description":
          "Fine dining steakhouse offering premium grills in a stylish setting.",
      "map":
          "https://www.google.com/maps/search/?api=1&query=JW+Steakhouse+Cairo",
      "isFav": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: Drawer(
        child: Container(
          child: ListView(
            children: [
              Row(children: [
                Container(
                  margin: EdgeInsets.all(15),
                  color: Colors.red,
                  child: CircleAvatar(
                    radius: 35,
                    child: Text(
                      userName != null && userName!.isNotEmpty
                          ? userName![0].toUpperCase()
                          : "U",
                      style: TextStyle(fontSize: 40),
                    ),
                  ),
                ),
                Expanded(
                    child: ListTile(
                  title: Text("$userName"),
                ))
              ]),
              Container(
                height: 100,
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text("SignOut"),
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Homepage(),
                    ),
                    (route) => false,
                  );
                },
              )
            ],
          ),
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: coustemSreach(
                        listData: [...TouristItem, ...RestaurantItem]));
              },
              icon: Icon(Icons.search)),
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FavPage(allData: [...TouristItem, ...RestaurantItem]),
                    ));
              },
              icon: Icon(
                Icons.favorite,
                color: Colors.red,
              ))
        ],
        title: Text("Smart City Guide"),
        bottom: TabBar(controller: tebcontroller, tabs: [
          Tab(
            icon: Icon(Icons.location_city),
            text: "Tourist attractions ",
          ),
          Tab(
            icon: Icon(Icons.restaurant),
            text: "restaurant Location",
          ),
        ]),
      ),
      body: TabBarView(controller: tebcontroller, children: [
        GridView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: screenWidth > 600 ? 4 : 2, mainAxisExtent: 300),
          itemCount: TouristItem.length,
          itemBuilder: (context, index) {
            return Container(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Detials(
                          data: TouristItem[index],
                        ),
                      ));
                },
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.asset(
                        TouristItem[index]["imageLink"],
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Expanded(
                        child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                TouristItem[index]["imageTitle"],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    TouristItem[index]["isFav"] =
                                        !TouristItem[index]["isFav"];
                                    saveFav();
                                  });
                                },
                                icon: Icon(TouristItem[index]["isFav"]
                                    ? Icons.favorite
                                    : Icons.favorite_border),
                                color: TouristItem[index]["isFav"]
                                    ? Colors.red
                                    : Colors.grey,
                              )
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            TouristItem[index]["location"],
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 6),
                          Text(
                            TouristItem[index]["description"],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ))
                  ],
                ),
              ),
            );
          },
        ),
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: screenWidth > 600 ? 4 : 2,
            mainAxisExtent: 300,
          ),
          itemCount: RestaurantItem.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Detials(
                      data: RestaurantItem[index],
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.asset(
                        RestaurantItem[index]["imageLink"],
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                RestaurantItem[index]["imageTitle"].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    RestaurantItem[index]["isFav"] =
                                        !RestaurantItem[index]["isFav"];
                                    saveFav();
                                  });
                                },
                                icon: Icon(RestaurantItem[index]["isFav"]
                                    ? Icons.favorite
                                    : Icons.favorite_border),
                                color: RestaurantItem[index]["isFav"]
                                    ? Colors.red
                                    : Colors.grey,
                              )
                            ],
                          ),
                          SizedBox(height: 4),
                          Text(
                            RestaurantItem[index]["location"],
                            style: TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 6),
                          Text(
                            RestaurantItem[index]["description"],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
      ]),
    );
  }
}

class coustemSreach extends SearchDelegate {
  List listData;
  coustemSreach({required this.listData});
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = "";
          },
          icon: Icon(Icons.close))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List filterList;
    if (query == "") {
      filterList = listData;
    } else {
      filterList = listData
          .where((element) =>
              element["imageTitle"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    return ListView.builder(
      itemCount: filterList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(filterList[index]["imageTitle"]),
          leading: Image.asset(
            filterList[index]["imageLink"],
            width: 50,
            height: 50,
            fit: BoxFit.cover,
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Detials(
                    data: filterList[index],
                  ),
                ));
          },
        );
      },
    );
  }
}
