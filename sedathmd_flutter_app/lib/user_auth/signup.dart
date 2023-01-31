import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController eMailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  bool _isSecure = true;
  bool _isPasswordEightCharacters = false;
  bool _hasPasswordOneNum = false;
  bool _isUserNameExists = false;
  bool _isUserMailExists = false;

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

  @override
  void dispose() {
    eMailController.dispose();
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: eMailController.text, password: passwordController.text)
        .then((user) {
      FirebaseFirestore.instance
          .collection("Users")
          .doc(eMailController.text)
          .set({
        "userMail": eMailController.text,
        "userName": userNameController.text,
        "password": passwordController.text,
        "userId": auth.currentUser!.uid,
      });
    }).then((value) => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route route) => false));
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
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 20,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            height: MediaQuery.of(context).size.height - 100,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: const [
                    Text(
                      "Sign Up",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Create an account, It's free",
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      makeInput(
                          label: "E-mail",
                          cont: eMailController,
                          validate: (eMail) {
                            if (eMail.length > 5 &&
                                eMail.contains('@') &&
                                eMail.endsWith('.com') &&
                                _isUserMailExists == false) {
                              return null;
                            }
                            return 'Enter a Valid Email Address';
                          }),
                      makeInput(
                          validate: (pass) {
                            if (_isPasswordEightCharacters &
                                    _hasPasswordOneNum ==
                                false) {
                              return "Invalid Password Type";
                            }
                            return null;
                          },
                          changed: (password) => onPasswordChanged(password),
                          label: "Password",
                          cont: passwordController,
                          obscureT: _isSecure,
                          suff: Align(
                            widthFactor: 1.0,
                            heightFactor: 1.0,
                            child: InkWell(
                              onTap: () {
                                _changeVisibility();
                              },
                              child: Icon(
                                _isSecure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          )),
                      makeValidatePassword(
                        label: "Contains at least 8 characters",
                        valiColor: _isPasswordEightCharacters
                            ? Colors.green
                            : Colors.transparent,
                        valiBorder: _isPasswordEightCharacters
                            ? Border.all(color: Colors.transparent)
                            : Border.all(color: Colors.black),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      makeValidatePassword(
                        label: "Contains at least 1 number",
                        valiColor: _hasPasswordOneNum
                            ? Colors.green
                            : Colors.transparent,
                        valiBorder: _hasPasswordOneNum
                            ? Border.all(color: Colors.transparent)
                            : Border.all(color: Colors.black),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      makeInput(
                        label: "Username",
                        cont: userNameController,
                        validate: (userName) {
                          if (_isUserNameExists == true) {
                            return "Username already exists";
                          } else if (userName.length < 6 &&
                              userName.length > 15) {
                            return 'Invalid username';
                          } else {
                            return null;
                          }
                        },
                      ),
                      MaterialButton(
                        minWidth: double.infinity,
                        height: 60,
                        onPressed: () async {
                          bool resultUsername =
                              await userNameExists(userNameController.text);
                          bool resultMail =
                              await userMailExists(eMailController.text);
                          setState(() {
                            _isUserNameExists = false;
                            _isUserMailExists = false;
                            if (resultUsername == true) {
                              _isUserNameExists = true;
                            }
                            if (resultMail == true) {
                              _isUserMailExists = true;
                            }
                            if (_formKey.currentState!.validate()) {
                              register();
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Account created. Now you can login.')));
                            }
                          });
                        },
                        color: Colors.blueAccent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 18),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget makeInput(
      {label, obscureT = false, suff, cont, changed, validate, fieldSub}) {
    return Column(
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
            suffixIcon: suff,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

Widget makeValidatePassword({label, valiColor, valiBorder}) {
  return Row(
    children: [
      AnimatedContainer(
        duration: const Duration(microseconds: 500),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
            color: valiColor,
            border: valiBorder,
            borderRadius: BorderRadius.circular(50)),
        child: const Center(
          child: Icon(Icons.check, size: 15),
        ),
      ),
      const SizedBox(width: 10),
      Text(label)
    ],
  );
}
