import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/widgets/app_bottom_navbar_widget.dart';
import 'package:event_ease/widgets/custom_button_widgets.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../utils/log_out_util.dart';
import '../utils/navigator_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  bool _isLoading = true;
  String profileImageURL = '';
  String formattedName = '';
  bool hasCurrentEvent = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getClientData();
  }

  void getClientData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final userData = await getCurrentUserData();
      profileImageURL = userData['profileImageURL'];
      formattedName = '${userData['firstName']} ${userData['lastName']}';
      hasCurrentEvent = userData['currentEventID'].toString().isNotEmpty;

      //  The user has no current event. No Need to check for payment deadlines
      if (!hasCurrentEvent) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final eventData = await getThisEvent(userData['currentEventID']);
      final eventDate = (eventData['eventDate'] as Timestamp).toDate();

      if (eventDate.difference(DateTime.now()).inDays < 30) {
        //  The event will be auto cancelled because the client has no approved suppliers yet.
        if (eventData['catering']['supplier'].toString().isEmpty &&
            eventData['cosmetologist']['supplier'].toString().isEmpty &&
            eventData['guestPlace']['supplier'].toString().isEmpty &&
            eventData['host']['supplier'].toString().isEmpty &&
            eventData['host']['supplier'].toString().isEmpty &&
            eventData['host']['supplier'].toString().isEmpty) {
          await cancelEvent(userData['currentEventID'],
              'Your event has been auto-cancelled since you have not yet availed any suppliers 30 days before the event.');
          setState(() {
            hasCurrentEvent = false;
            _isLoading = false;
          });
          return;
        }

        bool mustPayCatering = eventData['catering']['status'] != 'TO RATE' &&
            await mustSettlePayment(
                'completionPaymentTransaction', eventData['catering']);
        bool mustPayCosmetics =
            eventData['cosmetologist']['status'] != 'TO RATE' &&
                await mustSettlePayment(
                    'completionPaymentTransaction', eventData['cosmetologist']);
        bool mustPayGuestPlace =
            eventData['guestPlace']['status'] != 'TO RATE' &&
                await mustSettlePayment(
                    'completionPaymentTransaction', eventData['guestPlace']);
        bool mustPayHost = eventData['host']['status'] != 'TO RATE' &&
            await mustSettlePayment(
                'completionPaymentTransaction', eventData['host']);
        bool mustPayPhotographer =
            eventData['photographer']['status'] != 'TO RATE' &&
                await mustSettlePayment(
                    'completionPaymentTransaction', eventData['photographer']);
        bool mustPayTechnician =
            eventData['technician']['status'] != 'TO RATE' &&
                await mustSettlePayment(
                    'completionPaymentTransaction', eventData['technician']);

        if (mustPayCatering ||
            mustPayGuestPlace ||
            mustPayCosmetics ||
            mustPayGuestPlace ||
            mustPayHost ||
            mustPayPhotographer ||
            mustPayTechnician) {
          if (eventDate.difference(DateTime.now()).inDays < 7) {
            await cancelEvent(userData['currentEventID'],
                'You have exceeded the deadline for settling the completion payments. Your event has been auto-cancelled.');
          } else {
            await cancelEvent(userData['currentEventID'],
                'You have exceeded the deadline for settling the down payments. Your event has been auto-cancelled.');
          }
          hasCurrentEvent = false;
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting client data: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future cancelEvent(String eventID, String cancellationMessage) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'currentEventID': ''});
    await FirebaseFirestore.instance
        .collection('events')
        .doc(eventID)
        .update({'isCancelled': true});
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    comicNeueText(
                        label: cancellationMessage,
                        textAlign: TextAlign.justify,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                    ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('CLOSE', style: buttonSweetCornStyle()))
                  ],
                ),
              ),
            ));
  }

  Future<bool> mustSettlePayment(
      String requiredTransactionType, Map<dynamic, dynamic> supplierMap) async {
    try {
      //  1. Check if this service has an availed supplier
      String supplier = supplierMap['supplier'];
      if (supplier.isEmpty) {
        return false;
      }

      //  2. Check if a transaction has been made
      String transactionID = supplierMap[requiredTransactionType];
      if (transactionID.isEmpty) return true;

      //3. Check if the transaction has been verified
      final transaction = await getThisTransaction(transactionID);
      return transaction['verified'];
    } catch (error) {
      return false;
    }
  }

  //  BUILD WIDGET
  //============================================================================
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showLogOutModal(context);
        return false;
      },
      child: Scaffold(
          appBar: profileAppBar(context,
              profileImageURL: profileImageURL, formattedName: formattedName),
          bottomNavigationBar: bottomNavigationBar(context,
              index: 0,
              isClient: true,
              isHomeScreen: true,
              hasEvent: hasCurrentEvent),
          body: switchedLoadingContainer(
              _isLoading,
              SingleChildScrollView(
                child: Column(
                  children: [
                    whiteBGHeaderText(context, label: 'My Account'),
                    const Gap(50),
                    _actionButtons()
                  ],
                ),
              ))),
    );
  }

  //  COMPONENT WIDGETS
  //============================================================================
  Widget _actionButtons() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        roundedImageButton(context,
            label: 'Transactions',
            imagePath: 'assets/images/Transactions.png',
            onPress: () => Navigator.of(context)
                .pushNamed(NavigatorRoutes.transactionHistory)),
        roundedImageButton(context,
            label: 'Feedbacks',
            imagePath: 'assets/images/Feedback.png',
            onPress: () => Navigator.of(context)
                .pushNamed(NavigatorRoutes.feedbackHistory))
      ]),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          roundedImageButton(context,
              label: 'Calendar',
              imagePath: 'assets/images/Calendar.png', onPress: () {
            if (hasCurrentEvent) {
              Navigator.of(context).pushNamed(NavigatorRoutes.clientCalendar);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('You have no current event')));
            }
          }),
          roundedImageButton(context,
              label: 'Event History',
              imagePath: 'assets/images/Event History.png',
              onPress: () =>
                  Navigator.of(context).pushNamed(NavigatorRoutes.eventHistory))
        ]),
      ),
      roundedImageButton(context,
          label: 'Help Center',
          imagePath: 'assets/images/Help Center.png',
          onPress: () =>
              Navigator.of(context).pushNamed(NavigatorRoutes.viewFAQs))
    ]);
  }
}
