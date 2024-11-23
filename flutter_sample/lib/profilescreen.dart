import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sample/loginscreen.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _selectedImage;

  // Method to pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
            child: Column(
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () {
                      // image picker
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SafeArea(
                          child: Wrap(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text("Gallery"),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _pickImage(ImageSource.gallery);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text("Camera"),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _pickImage(ImageSource.camera);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text("Delete"),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    _selectedImage = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  "images/204815.jpg",
                                  height: 150,
                                  width: 150,
                                  fit: BoxFit.fill,
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "New User",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
         
        ],
      ),
    );
  }
}
