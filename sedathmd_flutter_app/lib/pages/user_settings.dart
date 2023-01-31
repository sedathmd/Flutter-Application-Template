import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../user_auth/login.dart';
import 'main_page.dart';

class UserSettings extends StatefulWidget {
  const UserSettings({super.key});

  @override
  State<UserSettings> createState() => _UserSettingsState();
}

class _UserSettingsState extends State<UserSettings> {
  final _eMailKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();
  final _usernameKey = GlobalKey<FormState>();
  TextEditingController eMailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isSecure = true;
  bool _isPasswordEightCharacters = false;
  bool _hasPasswordOneNum = false;
  bool _isUserNameExists = false;
  bool _isUserMailExists = false;
  final currentUser = FirebaseAuth.instance.currentUser;
  var incomingDataUsername = '';
  var incomingDataEmail = '';
  var incomingDataPassword = '';
  var incomingDataId = '';
  //profile picture
  late File file;
  final _firebaseStorage = FirebaseStorage.instance;
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
        incomingDataEmail = incomingData.data()?['userMail'];
        incomingDataPassword = incomingData.data()?['password'];
        incomingDataId = incomingData.data()?['userId'];
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

  onPasswordChanged(String password) {
    final numericRegex = RegExp(r'[0-9]');
    setState(() {
      _isPasswordEightCharacters = false;
      if (password.length >= 8) _isPasswordEightCharacters = true;

      _hasPasswordOneNum = false;
      if (numericRegex.hasMatch(password)) _hasPasswordOneNum = true;
    });
  }

  void _changeVisibility() {
    setState(() {
      _isSecure = !_isSecure;
    });
  }

  uploadFromCamera() async {
    var pickedFile = await ImagePicker().getImage(source: ImageSource.camera);
    setState(() {
      file = File(pickedFile!.path);
    });
    var snapshot = await _firebaseStorage
        .ref()
        .child("profilePictures")
        .child(currentUser!.uid)
        .putFile(file);
    var url = await snapshot.ref.getDownloadURL();
    setState(() {
      downloadUrl = url;
    });
  }

  uploadFromGallery() async {
    var pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      file = File(pickedFile!.path);
    });
    var snapshot = await _firebaseStorage
        .ref()
        .child("profilePictures")
        .child(currentUser!.uid)
        .putFile(file);
    var url = await snapshot.ref.getDownloadURL();
    setState(() {
      downloadUrl = url;
    });
  }

  deleteImage() async {
    await FirebaseStorage.instance
        .refFromURL(downloadUrl)
        .delete()
        .then((value) => emptyProfile());
  }

  emptyProfile() {
    setState(() {
      downloadUrl =
          'https://a4draft.com/wp-content/uploads/2022/10/1636540898224.png';
      getUrl();
    });
  }

  Future<bool> userMailExists(email) async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .where('userMail', isEqualTo: email)
        .get()
        .then((value) => value.size > 0 ? true : false);
  }

  Future<bool> userNameExists(username) async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .where('userName', isEqualTo: username)
        .get()
        .then((value) => value.size > 0 ? true : false);
  }

  @override
  void initState() {
    super.initState();
    getUrl();
    getUser();
  }

  @override
  void dispose() {
    eMailController.dispose();
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  updateEmail() async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(incomingDataEmail)
        .delete()
        .then((value) => FirebaseFirestore.instance
                .collection("Users")
                .doc(eMailController.text)
                .set({
              "userMail": eMailController.text,
              "userName": incomingDataUsername,
              "password": incomingDataPassword,
              "userId": incomingDataId,
            }).then((value) => changeEmail()));
  }

  changeEmail() async {
    await currentUser!.updateEmail(eMailController.text);
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route route) => false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('E-mail changed, Please login with your new e-mail')));
  }

  updatePassword() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .update({"password": passwordController.text}).then(
            (value) => changePassword());
  }

  changePassword() async {
    await currentUser!.updatePassword(passwordController.text);
    FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route route) => false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Password changed, Please login with your new password')));
  }

  updateUsername() {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .update({"userName": userNameController.text})
        .then((value) => userNameController.clear())
        .then((value) => FocusScope.of(context).unfocus());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
                (Route route) => false);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 25),
        child: ListView(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 125,
                    height: 125,
                    decoration: BoxDecoration(
                        border: Border.all(width: 2, color: Colors.grey),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(downloadUrl))),
                  ),
                  Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                          height: 35,
                          width: 35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 2, color: Colors.grey),
                            color: Colors.blue,
                          ),
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Wrap(
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.browse_gallery),
                                        title: Text('From Gallery'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          uploadFromGallery();
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.camera),
                                        title: Text('From Camera'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          uploadFromCamera();
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.delete),
                                        title: Text('Delete Profile Picture'),
                                        onTap: () {
                                          deleteImage();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            ),
                          )))
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Form(
              key: _eMailKey,
              child: makeInput(
                validate: (eMail) {
                  if (eMail.length > 5 &&
                      eMail.contains('@') &&
                      eMail.endsWith('.com') &&
                      _isUserMailExists == false) {
                    return null;
                  }
                  return 'Enter a Valid Email Address';
                },
                func: () async {
                  bool result = await userMailExists(eMailController.text);
                  setState(() {
                    _isUserMailExists = false;
                    if (result == true) {
                      _isUserMailExists = true;
                    }
                    if (_eMailKey.currentState!.validate()) {
                      updateEmail();
                    }
                  });
                },
                label: "E-mail",
                cont: eMailController,
                hint: currentUser!.email,
              ),
            ),
            Form(
              key: _passwordKey,
              child: makeInput(
                  validate: (pass) {
                    if (_isPasswordEightCharacters & _hasPasswordOneNum ==
                        false) {
                      return "Invalid Password Type";
                    }
                    return null;
                  },
                  changed: (password) => onPasswordChanged(password),
                  func: () {
                    if (_passwordKey.currentState!.validate()) {
                      updatePassword();
                    }
                  },
                  label: "Password",
                  cont: passwordController,
                  obscureT: _isSecure,
                  hint: '********',
                  suff: Align(
                    widthFactor: 6.0,
                    heightFactor: 1.0,
                    child: InkWell(
                      onTap: () {
                        _changeVisibility();
                      },
                      child: Icon(
                        _isSecure ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  )),
            ),
            Form(
              key: _usernameKey,
              child: makeInput(
                validate: (userName) {
                  if (_isUserNameExists == true) {
                    return "Username already exists";
                  } else if (userName.length < 6 && userName.length > 15) {
                    return 'Invalid username';
                  } else {
                    return null;
                  }
                },
                func: () async {
                  bool result = await userNameExists(userNameController.text);
                  setState(() {
                    _isUserNameExists = false;
                    if (result == true) {
                      _isUserNameExists = true;
                    }
                    if (_usernameKey.currentState!.validate()) {
                      updateUsername();
                      getUser();
                    }
                  });
                },
                label: "Username",
                cont: userNameController,
                hint: incomingDataUsername,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget makeInput(
    {label,
    obscureT = false,
    suff,
    cont,
    changed,
    validate,
    fieldSub,
    hint,
    func}) {
  return Stack(children: [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
        ),
        const SizedBox(
          height: 5,
        ),
        TextFormField(
          validator: validate,
          onChanged: changed,
          obscureText: obscureT,
          controller: cont,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suff,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10),
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    ),
    Positioned(
        bottom: 26,
        right: 10,
        child: Container(
            height: 35,
            width: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(width: 2, color: Colors.grey),
              color: Colors.blue,
            ),
            child: InkWell(
              onTap: func,
              child: const Icon(
                Icons.save,
                color: Colors.white,
              ),
            )))
  ]);
}
