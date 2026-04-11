import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/Inputtext.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class addPlace extends StatefulWidget {
  const addPlace({super.key});

  @override
  State<addPlace> createState() => _addPlaceState();
}

class _addPlaceState extends State<addPlace> {
  final TextEditingController name = TextEditingController();
  final TextEditingController location = TextEditingController();
  final TextEditingController link = TextEditingController();
  final TextEditingController description = TextEditingController();
  final GlobalKey<FormState> formstate = GlobalKey();

  bool isUploading = false;
  XFile? selectedImage;

  final List<String> categories = ["tourist", "restaurant", "hotel"];
  String? selectedCategory;

  final CollectionReference place =
      FirebaseFirestore.instance.collection("place");

  Future<bool> _isSupabaseReady() async {
    int attempts = 0;
    while (Supabase.instance.client == null && attempts < 20) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
    return Supabase.instance.client != null;
  }

  Future<void> getImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);

    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  void showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(30),
          height: 150,
          child: Column(
            children: [
              const Text(
                "Choose Image Source",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      getImage(ImageSource.camera);
                    },
                    child: const Column(
                      children: [
                        Icon(Icons.camera_alt_outlined),
                        Text("Camera"),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      getImage(ImageSource.gallery);
                    },
                    child: const Column(
                      children: [Icon(Icons.filter_sharp), Text("Gallery")],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> uploadNewPlace() async {
    final isReady = await _isSupabaseReady();
    if (!isReady) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Supabase is not ready yet. Please try again."),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!formstate.currentState!.validate()) return;

    if (selectedImage == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("اختار صورة الأول يا كينج!"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      final String imageName =
          "${DateTime.now().millisecondsSinceEpoch}-${selectedImage!.name}";
      final File imageFile = File(selectedImage!.path);

      // رفع الصورة
      await Supabase.instance.client.storage.from("images").upload(
            imageName,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      // ✅ استخدام createSignedUrl بدل getPublicUrl
      final signedUrl = await Supabase.instance.client.storage
          .from("images")
          .createSignedUrl(imageName, 60 * 60 * 24 * 30); // 30 يوم

      print("========== SIGNED URL ==========");
      print(signedUrl);
      print("=================================");

      // تخزين البيانات في Firestore
      await place.add({
        "imageTitle": name.text,
        "category": selectedCategory,
        "description": description.text,
        "isFavorite": false,
        "location": location.text,
        "map": link.text,
        "imageLink": signedUrl, // ✅ الرابط الموقع
        "isApproved": false,
      });

      if (mounted) {
        setState(() {
          selectedImage = null;
        });
        name.clear();
        location.clear();
        link.clear();
        description.clear();

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Place Added Wating Approved"),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil(
          "homepage",
          (route) => false,
        );
      }
    } catch (e) {
      print("Error during upload: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("فشل الرفع: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Place"),
        backgroundColor: Colors.cyan,
        centerTitle: true,
      ),
      body: Form(
        key: formstate,
        child: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    if (!isUploading) showImagePickerOptions(context);
                  },
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.file(
                              File(selectedImage!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(
                            Icons.add_a_photo_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text("    Place Name"),
                const SizedBox(height: 5),
                Inputtext(
                    hintText: "Place Name",
                    isPassword: false,
                    myController: name),
                const SizedBox(height: 15),
                const Text("    Place Category"),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    border: Border.all(color: Colors.black87),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      hint: const Text("Choose Category Type"),
                      value: selectedCategory,
                      isExpanded: true,
                      items: categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                const Text("    City "),
                const SizedBox(height: 5),
                Inputtext(
                    hintText: "City Of Place",
                    isPassword: false,
                    myController: location),
                const SizedBox(height: 15),
                const Text("   Description "),
                const SizedBox(height: 5),
                Inputtext(
                    hintText: "Description",
                    isPassword: false,
                    myController: description),
                const SizedBox(height: 15),
                const Text("    Location"),
                const SizedBox(height: 5),
                Inputtext(
                    hintText: "Enter Map Link",
                    isPassword: false,
                    myController: link),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: isUploading ? null : uploadNewPlace,
              style: ElevatedButton.styleFrom(
                backgroundColor: isUploading ? Colors.grey : Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Add Place"),
            ),
          ],
        ),
      ),
    );
  }
}
