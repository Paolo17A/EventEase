import 'package:event_ease/screens/event_generation_screen.dart';
import 'package:event_ease/screens/select_service_screen.dart';
import 'package:event_ease/screens/view_available_suppliers_screen.dart';
import 'package:flutter/material.dart';

class NavigatorRoutes {
  static const String welcome = '/';
  static const String forgotPassword = '/forgotPassword';
  static const String settleMembershipFee = '/settleMembershipFee';

  //  CLIENT
  static const String clientLogin = '/clientLogin';
  static const String clientRegister = '/clientRegister';
  static const String clientHome = '/clientHome';
  static const String clientProfile = '/clientProfile';
  static const String servicesOffered = '/servicesOffered';
  static const String editClientProfile = '/editClientProfile';
  static const String currentEvent = '/currentEvent';
  static const String addService = '/addService';

  //  SUPPLIER
  static const String supplierLogin = '/supplierLogin';
  static const String supplierRegister = '/supplierRegister';
  static const String supplierHome = '/supplierHome';
  static const String supplierProfile = '/supplierProfile';
  static const String availPremium = '/availPremium';
  static const String editSupplierProfile = '/editSupplierProfile';

  //  ADMIN
  static const String adminHome = '/adminHome';
  static const String membershipRequests = '/membershipRequests';

  static void eventGeneration(BuildContext context,
      {required String eventType}) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => EventGenerationScreen(eventType: eventType)));
  }

  static void selectService(BuildContext context,
      {required String eventType, required DateTime eventDate}) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) =>
            SelectServiceScreen(eventType: eventType, eventDate: eventDate)));
  }

  static void viewAvailableSuppliers(BuildContext context,
      {required String requiredService, required DateTime eventDate}) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => ViewAvailableSuppliersScreen(
            requiredService: requiredService, eventDate: eventDate)));
  }
}
