import 'package:flutter/material.dart';
import 'package:app_tdmt/screens/home/pms_screen.dart';
import 'package:app_tdmt/screens/home/home_screen.dart';
import 'package:app_tdmt/screens/welcome/welcome_screen.dart';

class AppRouters {
  static const String welcomeScreen = "/welcome";
  static const String homeScreen = "/home";
  static const String homeScreen02 = "/home02";
  //
  static final routes = <String, WidgetBuilder>{
    welcomeScreen: (BuildContext context) => const WelcomeScreen(),
    homeScreen: (BuildContext context) => const HomeScreen(),
    homeScreen02: (BuildContext context) => const PmsScreen(),
  };
}
