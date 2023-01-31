import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../pages/user_settings.dart';
import '../user_auth/login.dart';

class DrawerPart extends StatefulWidget {
  const DrawerPart({super.key});

  @override
  State<DrawerPart> createState() => _DrawerPartState();
}

class _DrawerPartState extends State<DrawerPart> {
  final _storage = const FlutterSecureStorage();
  final currentUser = FirebaseAuth.instance.currentUser;
  var incomingDataUsername = '';
  //profile picture
  var downloadUrl =
      'https://a4draft.com/wp-content/uploads/2022/10/1636540898224.png';

  getUser() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get()
        .then((incomingData) {
      setState(() {
        incomingDataUsername = incomingData.data()?['userName'];
      });
    });
  }

  getUrl() async {
    String contact = await FirebaseStorage.instance
        .ref()
        .child("profilePictures")
        .child(currentUser!.uid)
        .getDownloadURL();
    setState(() {
      downloadUrl = contact;
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
    getUrl();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //wrap with container for width
      width: MediaQuery.of(context).size.width * 0.6,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(downloadUrl),
              ),
              accountEmail: Text(currentUser!.email.toString()),
              accountName: Text(
                incomingDataUsername.toString(),
                style: const TextStyle(fontSize: 20.0),
              ),
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text(
                'User Settings',
                style: TextStyle(fontSize: 16.0),
              ),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserSettings(),
                    ),
                    (Route route) => false);
              },
            ),
            const Divider(
              height: 10,
              thickness: 2,
            ),
            ListTile(
              leading: const Icon(Icons.logout_outlined),
              title: const Text(
                'Log out',
                style: TextStyle(fontSize: 16.0),
              ),
              onTap: () async {
                await _storage.delete(key: 'userMail');
                await _storage.delete(key: 'password');
                FirebaseAuth.instance.signOut().then((deger) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const LoginPage(),
                      ),
                      (Route route) => false);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
