import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'loading/loading_screen.dart';
import 'pages/main_page.dart';
import 'theme/themes.dart';
import 'theme/themes_controller.dart';
import 'user_auth/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); //for firebase
  await GetStorage.init(); //for themechange
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final themeController = Get.put(ThemeController());
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'sedathmdflutterapp',
      themeMode: themeController.theme,
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
      //home: LoginPage(),
      routes: {
        '/': (context) => const LoadingScreen(),
        '/home': (context) => HomePage(),
        '/log': (context) => const LoginPage(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            return const LoadingScreen();
          },
        );
      },
    );
  }
}
