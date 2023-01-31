import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sedathmd_flutter_app/user_auth/login.dart';

class PasswordReset extends StatefulWidget {
  const PasswordReset({super.key});

  @override
  State<PasswordReset> createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  bool _isSecure = true;
  bool _isPasswordEightCharacters = false;
  bool _hasPasswordOneNum = false;
  final currentUser = FirebaseAuth.instance.currentUser;

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
    passwordController.dispose();
    super.dispose();
  }

  updateUser() {
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
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Now you can login with your new password')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
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
                    "Reset Password",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "set a new password",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    makeInput(
                        validate: (input) {
                          if (_isPasswordEightCharacters & _hasPasswordOneNum ==
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
                    const SizedBox(height: 20),
                    MaterialButton(
                      minWidth: double.infinity,
                      height: 60,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          updateUser();
                        }
                      },
                      color: Colors.blueAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      child: const Text(
                        "Change Password",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 18),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
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

Widget makeInput({label, obscureT = false, suff, cont, changed, validate}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
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
        height: 30,
      ),
    ],
  );
}
