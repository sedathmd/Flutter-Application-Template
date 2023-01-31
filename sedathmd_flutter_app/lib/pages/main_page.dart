import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../part/drawer_part.dart';
import '../theme/themes_controller.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final themeController = Get.find<ThemeController>();
  final currentUser = FirebaseAuth.instance.currentUser;
  //Lotti
  late AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    if (Get.isDarkMode) {
      controller.animateTo(0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          actions: [
            InkWell(
              onTap: () {
                //get package'ı ile theme degistirdim
                if (Get.isDarkMode) {
                  themeController.changeThemeMode(ThemeMode.light);
                  themeController.saveTheme(false);
                  controller.animateTo(1);
                } else {
                  themeController.changeThemeMode(ThemeMode.dark);
                  themeController.saveTheme(true);
                  controller.animateTo(0.5);
                }
              },
              child: Lottie.asset('assets/lottie/lottie_theme_change.json',
                  repeat: false, controller: controller),
            ),
          ],
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(30))),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Find Your',
                      style: TextStyle(fontSize: 25),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Inspiration',
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
        drawer: const DrawerPart());
  }
}
