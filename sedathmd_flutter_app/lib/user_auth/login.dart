import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../pages/main_page.dart';
import 'otp.dart';
import 'signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController eMailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();
  bool _isSecure = true;
  bool _isPasswordEightCharacters = false;
  bool _hasPasswordOneNum = false;

  onPasswordChanged(String password) {
    final numericRegex = RegExp(r'[0-9]');
    setState(() {
      _isPasswordEightCharacters = false;
      if (password.length >= 8) _isPasswordEightCharacters = true;

      _hasPasswordOneNum = false;
      if (numericRegex.hasMatch(password)) _hasPasswordOneNum = true;
    });
  }

  @override
  void dispose() {
    eMailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _changeVisibility() {
    setState(() {
      _isSecure = !_isSecure;
    });
  }

  login() async {
    await _storage.write(key: 'userMail', value: eMailController.text);
    await _storage.write(key: 'password', value: passwordController.text);
    //üstü cache icin
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: eMailController.text, password: passwordController.text)
        .then((kullanici) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
          (Route route) => false);
    });
  }

  Future<bool> userAuth(userMail, userPassword) async {
    return await FirebaseFirestore.instance
        .collection('Users')
        .where('userMail', isEqualTo: userMail)
        .where('password', isEqualTo: userPassword)
        .get()
        .then((value) => value.size > 0 ? true : false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(elevation: 0),
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - 150,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: const [
                          Text(
                            "Login",
                            style: TextStyle(
                                fontSize: 30, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            "Login to your account",
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              makeInput(
                                  validate: (eMail) {
                                    if (eMail.length > 5 &&
                                        eMail.contains('@') &&
                                        eMail.endsWith('.com')) {
                                      return null;
                                    }
                                    return 'Enter a Valid Email Address';
                                  },
                                  label: "Email",
                                  cont: eMailController),
                              makeInput(
                                  validate: (input) {
                                    if (_isPasswordEightCharacters &
                                            _hasPasswordOneNum ==
                                        false) {
                                      return "Invalid Password Type";
                                    }
                                    return null;
                                  },
                                  changed: (password) =>
                                      onPasswordChanged(password),
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
                              InkWell(
                                onTap: () {
                                  eMailController.clear();
                                  passwordController.clear();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const PasswordResetPage()));
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              const SizedBox(height: 15),
                              MaterialButton(
                                minWidth: double.infinity,
                                height: 60,
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    bool result = await userAuth(
                                        eMailController.text,
                                        passwordController.text);
                                    if (result == true) {
                                      login();
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'Wrong e-mail or password')));
                                    }
                                  }
                                },
                                color: Colors.blueAccent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50)),
                                child: const Text(
                                  "Login",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18),
                                ),
                              ),
                              const SizedBox(height: 15),
                              InkWell(
                                onTap: () {
                                  eMailController.clear();
                                  passwordController.clear();
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const SignUpPage()));
                                },
                                child: const Text('New User? Create an Account',
                                    style: TextStyle(fontSize: 15)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget makeInput({label, obscureT = false, suff, cont, changed, validate}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        TextFormField(
          validator: validate,
          onChanged: changed,
          controller: cont,
          obscureText: obscureT,
          decoration: InputDecoration(
            suffixIcon: suff,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
      ],
    );
  }
}
