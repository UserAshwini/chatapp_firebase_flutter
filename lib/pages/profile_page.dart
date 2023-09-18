import 'dart:io';

import 'package:chatapp_firebase_flutter/helper/helper_function.dart';
import 'package:chatapp_firebase_flutter/pages/auth/login_page.dart';
import 'package:chatapp_firebase_flutter/pages/home_page.dart';
import 'package:chatapp_firebase_flutter/service/auth_service.dart';
import 'package:chatapp_firebase_flutter/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:chatapp_firebase_flutter/service/database_service.dart';


class ProfilePage extends StatefulWidget {
  String userName;
  String email;
   String uid;
  ProfilePage({Key? key, required this.email, required this.userName, required this.uid})
      : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  File? _image; // Variable to store the selected image
  final imagePicker = ImagePicker();
  String? downloadURL;
  AuthService authService = AuthService();
  User? user;

  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();
  }

  getCurrentUserIdandName() async {
    await HelperFunctions.getUserNameFromSF().then((value) {
      setState(() {
        widget.userName = value!;
      });
    });
    user = FirebaseAuth.instance.currentUser;
  }
  
  // void PickAndUploadImage()async {
  //   final image = await imagePicker.pickImage(source: ImageSource.gallery);
  //   Reference ref = FirebaseStorage.instance.ref().child("profilePic").child(user as String); // Use UID as the image path
  // await ref.putFile(File(image!.path));
  // await ref.getDownloadURL().then((value){
  //   print(value);
  // });
  // }

  Future getImageFromGallery() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
        showSnackbar(context, Colors.red, "No image found");
        Future.delayed(Duration(milliseconds: 400) );
      }
    });
  }


//   Future uploadImage() async {
//   Reference ref = FirebaseStorage.instance.ref().child("profilePic").child("images"); // Use UID as the image path
//   await ref.putFile(_image!);
//   downloadURL= await ref.getDownloadURL();
//   print(downloadURL);

//   // // Update the profile picture URL in Firestore
//   // await DatabaseService(uid: widget.uid).savingUserData(widget.userName, widget.email, downloadURL);
  
//   // setState(() {
//   //   // Update the UI to display the new profile picture
//   //   // You can set the _image variable to the new profile picture URL or update your UI accordingly
//   //   _image = File(downloadURL);
//   // });
//   showSnackbar(context, Colors.green, "Profile picture updated");
//         Future.delayed(Duration(milliseconds: 400) );

// }


  Future uploadImage() async {
    Reference ref = FirebaseStorage.instance.ref().child("image");
    await ref.putFile(_image!);
    downloadURL = await ref.getDownloadURL();
    print(downloadURL);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(209, 3, 120, 81),
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(
              color: Colors.white, fontSize: 27, fontWeight: FontWeight.bold),
        ),
      ),
      drawer: Drawer(
          child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 50),
        children: <Widget>[
          Icon(
            Icons.account_circle,
            size: 150,
            color: Colors.grey[700],
          ),
          const SizedBox(
            height: 15,
          ),
          Text(
            widget.userName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 30,
          ),
          const Divider(
            height: 2,
          ),
          ListTile(
            onTap: () {
              nextScreen(context, const HomePage());
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.group),
            title: const Text(
              "Groups",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ListTile(
            onTap: () {},
            selected: true,
            selectedColor: Theme.of(context).primaryColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.group),
            title: const Text(
              "Profile",
              style: TextStyle(color: Colors.black),
            ),
          ),
          ListTile(
            onTap: () async {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Logout"),
                      content: const Text("Are you sure you want to logout?"),
                      actions: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await authService.signOut();
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()),
                                (route) => false);
                          },
                          icon: const Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    );
                  });
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: const Icon(Icons.exit_to_app),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.black),
            ),
          )
        ],
      )),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 170),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _image != null
                  ? ClipOval(
                      child: Image.network(
                        _image!.path,
                        width: 200,
                        height: 200,
                        fit: BoxFit
                            .cover, // Use BoxFit.cover to fill the circular shape
                      ),
                    )
                  : Icon(
                      Icons.account_circle,
                      size: 200,
                      color: Colors.grey[700],
                    ),
              const SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Full Name", style: TextStyle(fontSize: 17)),
                  Text(widget.userName, style: const TextStyle(fontSize: 17)),
                ],
              ),
              const Divider(
                height: 20,
                thickness: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Email", style: TextStyle(fontSize: 17)),
                  Text(widget.email, style: const TextStyle(fontSize: 17)),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 40,
                child:  _image != null
                  ?ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  onPressed: uploadImage,
                  child: Text('Upload Image'),
                )
                  :ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  onPressed: getImageFromGallery,
                  child: Text('Select Image from Gallery'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
