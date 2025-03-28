import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import để điều chỉnh UI overlay
import 'package:firebase_core/firebase_core.dart';
import 'package:app_tdmt/screens/home/pms_screen.dart';
import 'package:app_tdmt/screens/home/home_screen.dart';
import 'package:app_tdmt/screens/welcome/welcome_screen.dart';
import 'firebase_options.dart';
import 'package:app_tdmt/app/app_routers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // // Đặt chế độ hiển thị của status bar
  // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
  //   statusBarColor: Colors.transparent, // Làm trong suốt thanh trạng thái
  //   // statusBarBrightness: Brightness.light, // Định dạng icon trên status bar
  //   // statusBarIconBrightness: Brightness.dark, // Màu icon (trắng hoặc đen)
  // ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Welcome Screen',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SafeArea(
        // Thêm SafeArea để tránh giao diện đè lên status bar
        child: WelcomeScreen(),
      ),
    );
  }
}
