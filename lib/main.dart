import 'package:event_ease/firebase_options.dart';
import 'package:event_ease/screens/add_service_screen.dart';
import 'package:event_ease/screens/admin_home_screen.dart';
import 'package:event_ease/screens/avail_premium_screen.dart';
import 'package:event_ease/screens/client_home_screen.dart';
import 'package:event_ease/screens/client_login_screen.dart';
import 'package:event_ease/screens/client_profile_screen.dart';
import 'package:event_ease/screens/client_register_screen.dart';
import 'package:event_ease/screens/current_customers_screen.dart';
import 'package:event_ease/screens/current_event_screen.dart';
import 'package:event_ease/screens/edit_client_profile_screen.dart';
import 'package:event_ease/screens/edit_supplier_profile_screen.dart';
import 'package:event_ease/screens/feedback_history_screen.dart';
import 'package:event_ease/screens/forgot_password_screen.dart';
import 'package:event_ease/screens/handle_payment_screen.dart';
import 'package:event_ease/screens/membership_requests_screen.dart';
import 'package:event_ease/screens/premium_requests_screen.dart';
import 'package:event_ease/screens/services_offered_screen.dart';
import 'package:event_ease/screens/settle_membership_fee_screen.dart';
import 'package:event_ease/screens/supplier_home_screen.dart';
import 'package:event_ease/screens/supplier_login_screen.dart';
import 'package:event_ease/screens/supplier_profile_screen.dart';
import 'package:event_ease/screens/supplier_register_screen.dart';
import 'package:event_ease/screens/welcome_screen.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'utils/colors_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

final Map<String, WidgetBuilder> _routes = {
  NavigatorRoutes.welcome: (context) => const WelcomeScreen(),
  NavigatorRoutes.forgotPassword: (context) => ForgotPasswordScreen(),
  NavigatorRoutes.settleMembershipFee: (context) =>
      const SettleMembershipFeeScreen(),
  NavigatorRoutes.feedbackHistory: (context) => const FeedBackHistoryScreen(),

  //CLIENT
  NavigatorRoutes.clientLogin: (context) => const ClientLoginScreen(),
  NavigatorRoutes.clientRegister: (context) => const ClientRegisterScreen(),
  NavigatorRoutes.clientHome: (context) => const ClientHomeScreen(),
  NavigatorRoutes.clientProfile: (context) => const ClientProfileScreen(),
  NavigatorRoutes.servicesOffered: (context) => const ServicesOfferedScreen(),
  NavigatorRoutes.editClientProfile: (context) => EditClientProfileScreen(),
  NavigatorRoutes.addService: (context) => const AddServiceScreen(),
  NavigatorRoutes.currentEvent: (context) => const CurrentEventScreen(),

  //SUPPLIER
  NavigatorRoutes.supplierLogin: (context) => const SupplierLoginScreen(),
  NavigatorRoutes.supplierRegister: (context) => const SupplierRegisterScreen(),
  NavigatorRoutes.supplierHome: (context) => const SupplierHomeScreen(),
  NavigatorRoutes.supplierProfile: (context) => const SupplierProfileScreen(),
  NavigatorRoutes.availPremium: (context) => const AvailPremiumScreen(),
  NavigatorRoutes.editSupplierProfile: (context) =>
      const EditSupplierProfileScreen(),
  NavigatorRoutes.currentCustomers: (context) => const CurrentCustomersScreen(),

  //ADMIN
  NavigatorRoutes.adminHome: (context) => const AdminHomeScreen(),
  NavigatorRoutes.membershipRequests: (context) =>
      const MembershipRequestsScreen(),
  NavigatorRoutes.premiumRequests: (context) => const PremiumRequestsScreen(),
  NavigatorRoutes.handlePayments: (context) => const HandlePaymentScreen()
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
