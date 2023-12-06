import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/screens/approve_cashout_screen.dart';
import 'package:event_ease/screens/chat_screen.dart';
import 'package:event_ease/screens/edit_faq_screen.dart';
import 'package:event_ease/screens/event_generation_screen.dart';
import 'package:event_ease/screens/generate_by_budget_screen.dart';
import 'package:event_ease/screens/generate_by_guest_count_screen.dart';
import 'package:event_ease/screens/rate_selected_user_screen.dart';
import 'package:event_ease/screens/selected_supplier_screen.dart';
import 'package:event_ease/screens/settle_payment_screen.dart';
import 'package:event_ease/screens/view_available_suppliers_screen.dart';
import 'package:flutter/material.dart';

class NavigatorRoutes {
  static const String welcome = '/';
  static const String forgotPassword = '/forgotPassword';
  static const String settleMembershipFee = '/settleMembershipFee';
  static const String feedbackHistory = '/feedbackHistory';
  static const String eventHistory = '/eventHistory';
  static const String viewFAQs = '/viewFAQs';
  static const String chatThreads = '/chatThreads';
  static const String pendingRatings = '/pendingRatings';

  //  CLIENT
  static const String clientLogin = '/clientLogin';
  static const String clientRegister = '/clientRegister';
  static const String clientHome = '/clientHome';
  static const String clientProfile = '/clientProfile';
  static const String servicesOffered = '/servicesOffered';
  static const String editClientProfile = '/editClientProfile';
  static const String currentEvent = '/currentEvent';
  static const String addService = '/addService';
  static const String transactionHistory = '/transactionHistory';
  static const String editService = '/editService';
  static const String clientCalendar = '/clientCalendar';
  static const String settleMultiplePayments = '/settleMultiplePayments';

  //  SUPPLIER
  static const String supplierLogin = '/supplierLogin';
  static const String supplierRegister = '/supplierRegister';
  static const String supplierHome = '/supplierHome';
  static const String supplierProfile = '/supplierProfile';
  static const String availPremium = '/availPremium';
  static const String editSupplierProfile = '/editSupplierProfile';
  static const String currentCustomers = '/currentCustomers';
  static const String supplierCalendar = '/supplierCalendar';
  static const String incomeHistory = '/incomeHistory';
  static const String cashOutHistory = '/cashoutHistory';
  static const String newCashOutRequest = '/newCashoutRequest';

  //  ADMIN
  static const String adminHome = '/adminHome';
  static const String membershipRequests = '/membershipRequests';
  static const String premiumRequests = '/premiumRequests';
  static const String handlePayments = '/handlePayments';
  static const String addFAQ = '/addFAQ';
  static const String handleCashouts = '/handleCashouts';

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

  static void generateByBudget(BuildContext context,
      {required DateTime eventDate,
      required double budget,
      required String eventType,
      required hasCatering,
      required hasCosmetologist,
      required hasGuestPlace,
      required hasHost,
      required hasPhotographer,
      required hasTechnician}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => GenerateByBudgetScreen(
              eventDate: eventDate,
              budget: budget,
              eventType: eventType,
              hasCatering: hasCatering,
              hasCosmetologist: hasCosmetologist,
              hasGuestPlace: hasGuestPlace,
              hasHost: hasHost,
              hasPhotographer: hasPhotographer,
              hasTechnician: hasTechnician,
            )));
  }

  static void generateByGuestCount(
    BuildContext context, {
    required DateTime eventDate,
    required int guestCount,
    required String eventType,
    required hasCatering,
    required hasCosmetologist,
    required hasGuestPlace,
    required hasHost,
    required hasPhotographer,
    required hasTechnician,
  }) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => GenerateByGuestCountScreen(
            eventDate: eventDate,
            guestCount: guestCount,
            eventType: eventType,
            hasCatering: hasCatering,
            hasCosmetologist: hasCosmetologist,
            hasGuestPlace: hasGuestPlace,
            hasHost: hasHost,
            hasPhotographer: hasPhotographer,
            hasTechnician: hasTechnician)));
  }

  static void editFAQ(BuildContext context, {required String FAQID}) {
    Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => EditFAQScreen(FAQID: FAQID)));
  }

  static void chat(BuildContext context, {required String otherPersonUID}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChatScreen(otherPersonUID: otherPersonUID)));
  }

  static void approveCashout(BuildContext context,
      {required DocumentSnapshot cashoutDoc,
      required DocumentSnapshot supplierDoc}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ApproveCashoutScreen(
            cashoutDoc: cashoutDoc, supplierDoc: supplierDoc)));
  }

  static void rateSelectedUser(BuildContext context, bool isClient,
      {required DocumentSnapshot feedbackDoc,
      required DocumentSnapshot userDoc}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => RateSelectedUserScreen(
            isClient: isClient, feedbackDoc: feedbackDoc, userDoc: userDoc)));
  }
}
