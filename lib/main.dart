import 'package:event_ease/firebase_options.dart';
import 'package:event_ease/screens/client_home_screen.dart';
import 'package:event_ease/screens/client_login_screen.dart';
import 'package:event_ease/screens/client_register_screen.dart';
import 'package:event_ease/screens/settle_membership_fee_screen.dart';
import 'package:event_ease/screens/supplier_home_screen.dart';
import 'package:event_ease/screens/supplier_login_screen.dart';
import 'package:event_ease/screens/supplier_register_screen.dart';
import 'package:event_ease/screens/welcome_screen.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'utils/colors_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final Map<String, WidgetBuilder> _routes = {
  NavigatorRoutes.welcome: (context) => const WelcomeScreen(),
  NavigatorRoutes.clientLogin: (context) => const ClientLoginScreen(),
  NavigatorRoutes.supplierLogin: (context) => const SupplierLoginScreen(),
  NavigatorRoutes.clientRegister: (context) => const ClientRegisterScreen(),
  NavigatorRoutes.supplierRegister: (context) => const SupplierRegisterScreen(),
  NavigatorRoutes.settleMembershipFee: (context) =>
      const SettleMembershipFeeScreen(),
  NavigatorRoutes.clientHome: (context) => const ClientHomeScreen(),
  NavigatorRoutes.supplierHome: (context) => const SupplierHomeScreen()
};

final ThemeData _themeData = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: CustomColors.sweetCorn),
    scaffoldBackgroundColor: Colors.white,
    snackBarTheme: const SnackBarThemeData(
        backgroundColor: CustomColors.sweetCorn,
        contentTextStyle: TextStyle(color: CustomColors.midnightExtress)),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: CustomColors.midnightExtress,
        showSelectedLabels: true,
        showUnselectedLabels: false),
    appBarTheme: const AppBarTheme(
        backgroundColor: CustomColors.midnightExtress,
        iconTheme: IconThemeData(color: CustomColors.sweetCorn)),
    listTileTheme: const ListTileThemeData(
        iconColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)))),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            backgroundColor: CustomColors.midnightExtress,
            textStyle: const TextStyle(color: CustomColors.sweetCorn))),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            foregroundColor: CustomColors.midnightExtress,
            textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                decoration: TextDecoration.underline))),
    tabBarTheme: const TabBarTheme(labelColor: Colors.black));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Event Ease',
        theme: _themeData,
        routes: _routes,
        initialRoute: '/');
  }
}
