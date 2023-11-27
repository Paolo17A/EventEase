import 'package:event_ease/screens/event_generation_screen.dart';
import 'package:event_ease/screens/selected_supplier_screen.dart';
import 'package:event_ease/screens/settle_payment_screen.dart';
import 'package:event_ease/screens/view_available_suppliers_screen.dart';
import 'package:flutter/material.dart';

class NavigatorRoutes {
  static const String welcome = '/';
  static const String forgotPassword = '/forgotPassword';
  static const String settleMembershipFee = '/settleMembershipFee';
  static const String feedbackHistory = '/feedbackHistory';

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
  static const String currentCustomers = '/currentCustomers';

  //  ADMIN
  static const String adminHome = '/adminHome';
  static const String membershipRequests = '/membershipRequests';
  static const String premiumRequests = '/premiumRequests';
  static const String handlePayments = '/handlePayments';

  static void eventGeneration(BuildContext context,
      {required String eventType}) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => EventGenerationScreen(eventType: eventType)));
  }

  static void viewAvailableSuppliers(BuildContext context,
      {required String requiredService, required DateTime eventDate}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ViewAvailableSuppliersScreen(
            requiredService: requiredService, eventDate: eventDate)));
  }

  static void selectedSupplier(BuildContext context,
      {required String supplierUID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            SelectedSupplierScreen(supplierUID: supplierUID)));
  }

  static void settlePayment(BuildContext context,
      {required String eventID,
      required String paymentType,
      required double paymentAmount,
      required String serviceOffered,
      required String supplierID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SettlePaymentScreen(
            eventID: eventID,
            paymentType: paymentType,
            paymentAmount: paymentAmount,
            serviceOffered: serviceOffered,
            supplierID: supplierID)));
  }
}
