import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final _storage = const FlutterSecureStorage();
  late final _loadingAnimation;

  @override
  void initState() {
    super.initState();
    if (Get.isDarkMode) {
      _loadingAnimation =
          Lottie.asset('assets/lottie/lottie_loading_dark.json');
    } else {
      _loadingAnimation = Lottie.asset('assets/lottie/lottie_loading.json');
    }
    navigateToHome();
  }

  Future<void> navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    //arası cache icin
    var currentUserMail = await _storage.read(key: 'userMail');
    var currentPassword = await _storage.read(key: 'password');
    if (currentUserMail != null && currentPassword != null) {
      FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: currentUserMail.toString(),
              password: currentPassword.toString())
          .then((kullanici) {
        Navigator.pushReplacementNamed(context, '/home');
      });
      //--------------------------------------------------------
    } else {
      Navigator.pushReplacementNamed(context, '/log');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              child: _loadingAnimation,
              height: MediaQuery.of(context).size.height * 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
