import 'dart:io';
import 'package:chat_app/services/notification_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_app/screens/users_screen.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/database_services.dart';

class UserDataScreen extends StatefulWidget {
  UserDataScreen({Key? key}) : super(key: key);

  @override
  _UserDataScreenState createState() => _UserDataScreenState();
}

class _UserDataScreenState extends State<UserDataScreen> {
  final TextEditingController txtController = TextEditingController();
  var _pickedFile;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);
    setState(() {
      _pickedFile = pickedFile;
    });
  }

  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white70,
      context: context,
      builder: (BuildContext context) => Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height * .15,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
                getImage(ImageSource.camera);
              },
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .1,
                    child: const Icon(
                      Icons.camera,
                      size: 60,
                    ),
                  ),
                  const Text("Camera")
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                getImage(ImageSource.gallery);
              },
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .1,
                    child: const Icon(
                      Icons.photo,
                      size: 60,
                    ),
                  ),
                  const Text("Gallery")
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadImageToFirebaseStorageAndCreateUser() async {
    print("function called");
    if (_pickedFile != null) {
      try {
        final imagePath = 'users/${DateTime.now()}.png';
        final file = File(_pickedFile.path);
        final storageRef = FirebaseStorage.instance.ref().child(imagePath);
        await storageRef.putFile(file);
        print("successfully uploaded");
        final downloadURL = await storageRef.getDownloadURL();
        final userProfile = UserProfile(
          uid: FirebaseAuth.instance.currentUser!.uid,
          name: txtController.text.trim(),
          pfpURL: downloadURL,
          deviceToken: await NotificationServices().getDeviceToken(),
        );

        await DatabaseService().createUserProfile(userProfile: userProfile);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
      } catch (error) {
        // Handle error
        print('Error uploading image to Firebase Storage: $error');
      }
    } else {
      print("pickedFile is null");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _pickedFile == null
                ? GestureDetector(
                    onTap: () => showBottomSheet(context),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: CircleAvatar(
                        radius: 50,
                        child: Text("pick image"),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(File(_pickedFile.path)),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: txtController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: ElevatedButton(
                onPressed: () => _uploadImageToFirebaseStorageAndCreateUser(),
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
