import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_otp/email_otp.dart';
import 'package:sedathmd_flutter_app/user_auth/password.dart';

class PasswordResetPage extends StatefulWidget {
  const PasswordResetPage({super.key});

  @override
  State<PasswordResetPage> createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _eMailKey = GlobalKey<FormState>();
  final _otpKey = GlobalKey<FormState>();
  TextEditingController eMailController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  EmailOTP myauth = EmailOTP();
  var incomingDataEmail;
  var incomingDataPassword;

  getUser() async {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(eMailController.text)
        .get()
        .then((incomingData) {
      setState(() {
        incomingDataEmail = incomingData.data()?['userMail'];
        incomingDataPassword = incomingData.data()?['password'];
      });
    });
  }

  @override
  void dispose() {
    eMailController.dispose();
    otpController.dispose();
    super.dispose();
  }

  loginPasswordReset() async {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: incomingDataEmail, password: incomingDataPassword)
        .then((kullanici) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (BuildContext context) => PasswordReset()),
          (Route route) => false);
    });
  }

  sendOtp() async {
    myauth.setConfig(
        appName: "Email OTP",
        userEmail: eMailController.text,
        otpLength: 6,
        otpType: OTPType.digitsOnly);
    if (await myauth.sendOTP() == true && incomingDataEmail != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("OTP has been sent"),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Oops, OTP send failed"),
      ));
    }
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
            height: MediaQuery.of(context).size.height - 200,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: const [
                    Text(
                      "Reset Password",
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Then Check Your E-mail",
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                Form(
                  key: _eMailKey,
                  child: Column(
                    children: [
                      makeInput(
                          label: "E-mail",
                          cont: eMailController,
                          validate: (eMail) {
                            if (eMail != null) {
                              if (eMail.length > 5 &&
                                  eMail.contains('@') &&
                                  eMail.endsWith('.com')) {
                                return null;
                              }
                              return 'Enter a Valid Email Address';
                            }
                          }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: MaterialButton(
                          minWidth: double.maxFinite,
                          height: 45,
                          onPressed: () async {
                            if (_eMailKey.currentState!.validate()) {
                              getUser();
                              await sendOtp();
                            }
                          },
                          color: Colors.blueAccent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          child: const Text("Send OTP",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 18)),
                        ),
                      ),
                    ],
                  ),
                ),
                Form(
                  key: _otpKey,
                  child: Column(
                    children: [
                      makeInput(
                          label: "One Time Password",
                          cont: otpController,
                          validate: (otp) {
                            if (otp != null) {
                              if (otp.length == 6) {
                                return null;
                              }
                              return 'Enter a Valid OTP';
                            }
                          }),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: MaterialButton(
                          minWidth: double.infinity,
                          height: 45,
                          onPressed: () async {
                            if (_otpKey.currentState!.validate()) {
                              if (await myauth.verifyOTP(
                                      otp: otpController.text) ==
                                  true) {
                                loginPasswordReset();
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text("Invalid OTP"),
                                ));
                              }
                            }
                          },
                          color: Colors.blueAccent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          child: const Text(
                            "Reset Password",
                            style: TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget makeInput({label, cont, validate}) {
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
          controller: cont,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            border:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
          ),
        ),
        const SizedBox(
          height: 30,
        ),
      ],
    );
  }
}
