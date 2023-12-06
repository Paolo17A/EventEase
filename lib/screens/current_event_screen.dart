import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../utils/custom_string_util.dart';

class CurrentEventScreen extends StatefulWidget {
  const CurrentEventScreen({super.key});

  @override
  State<CurrentEventScreen> createState() => _CurrentEventScreenState();
}

class _CurrentEventScreenState extends State<CurrentEventScreen> {
  bool _isLoading = true;
  String eventID = '';
  String eventType = '';
  DateTime eventDate = DateTime(1970);
  DocumentSnapshot? catering;
  String cateringStatus = '';
  DocumentSnapshot? cosmetologist;
  String cosmetologistStatus = '';
  DocumentSnapshot? guestPlace;
  String guestPlaceStatus = '';
  DocumentSnapshot? host;
  String hostStatus = '';
  DocumentSnapshot? photographer;
  String photographerStatus = '';
  DocumentSnapshot? technician;
  String technicianStatus = '';
  bool isFinished = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCurrentEvent();
  }

  void getCurrentEvent() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final userData = await getCurrentUserData();
      eventID = userData['currentEventID'];
      final eventData = await getThisEvent(eventID);
      eventType = eventData['eventType'];
      eventDate = (eventData['eventDate'] as Timestamp).toDate();
      isFinished = eventData['isFinished'];
      catering = eventData['catering']['confirmed'] == true
          ? await FirebaseFirestore.instance
              .collection('users')
              .doc(eventData['catering']['supplier'])
              .get()
          : null;
      cateringStatus = eventData['catering']['status'];

      cosmetologist = eventData['cosmetologist']['confirmed'] == true
          ? await FirebaseFirestore.instance
              .collection('users')
              .doc(eventData['cosmetologist']['supplier'])
              .get()
          : null;
      cosmetologistStatus = eventData['cosmetologist']['status'];

      guestPlace = eventData['guestPlace']['confirmed'] == true
          ? await FirebaseFirestore.instance
              .collection('users')
              .doc(eventData['guestPlace']['supplier'])
              .get()
          : null;
      guestPlaceStatus = eventData['guestPlace']['status'];

      host = eventData['host']['confirmed'] == true
          ? await FirebaseFirestore.instance
              .collection('users')
              .doc(eventData['host']['supplier'])
              .get()
          : null;
      hostStatus = eventData['host']['status'];

      photographer = eventData['photographer']['confirmed'] == true
          ? await FirebaseFirestore.instance
              .collection('users')
              .doc(eventData['photographer']['supplier'])
              .get()
          : null;
      photographerStatus = eventData['photographer']['status'];

      technician = eventData['technician']['confirmed'] == true
          ? await FirebaseFirestore.instance
              .collection('users')
              .doc(eventData['technician']['supplier'])
              .get()
          : null;
      technicianStatus = eventData['technician']['status'];

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error getting current event details: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void cancelThisSupplier(DocumentSnapshot supplierDoc) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      final supplierData = supplierDoc.data() as Map<dynamic, dynamic>;
      String offeredService = supplierData['offeredService'];
      String serviceParameter = getServiceParameter(offeredService);

      final eventData = await getThisEvent(eventID);
      Map<dynamic, dynamic> currentSupplierMap = eventData[serviceParameter];
      currentSupplierMap['confirmed'] = false;
      currentSupplierMap['supplier'] = '';
      currentSupplierMap['completionPaymentTransaction'] = '';
      currentSupplierMap['downPaymentTransaction'] = '';
      currentSupplierMap['status'] = '';
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventID)
          .update({serviceParameter: currentSupplierMap});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(supplierDoc.id)
          .update({
        'currentEvents': FieldValue.arrayRemove([eventID]),
        'currentClients':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
      });
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully cancelled this supplier')));
      getCurrentEvent();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error cancelling this supplier: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool eligibleForPayAllAtOnce() {
    bool pendingCatering = cateringStatus == 'PENDING DOWN PAYMENT' ||
        cateringStatus == 'PENDING COMPLETION PAYMENT';
    bool pendingCosmetologist = cosmetologistStatus == 'PENDING DOWN PAYMENT' ||
        cosmetologistStatus == 'PENDING COMPLETION PAYMENT';
    bool pendingGuestPlace = guestPlaceStatus == 'PENDING DOWN PAYMENT' ||
        guestPlaceStatus == 'PENDING COMPLETION PAYMENT';
    bool pendingHost = hostStatus == 'PENDING DOWN PAYMENT' ||
        hostStatus == 'PENDING COMPLETION PAYMENT';
    bool pendingPhotographer = photographerStatus == 'PENDING DOWN PAYMENT' ||
        photographerStatus == 'PENDING COMPLETION PAYMENT';
    bool pendingTechnician = technicianStatus == 'PENDING DOWN PAYMENT' ||
        technicianStatus == 'PENDING COMPLETION PAYMENT';
    return pendingCatering ||
        pendingCosmetologist ||
        pendingGuestPlace ||
        pendingHost ||
        pendingPhotographer ||
        pendingTechnician;
  }

  bool eligibleForEventCompletion() {
    bool eligibleCatering =
        catering == null || (cateringStatus == 'TO RATE' && catering != null);
    bool eligibleCosmetologist = cosmetologist == null ||
        (cosmetologistStatus == 'TO RATE' && cosmetologist != null);
    bool eligibleGuestPlace = guestPlace == null ||
        (guestPlaceStatus == 'TO RATE' && guestPlace != null);
    bool eligibleHost =
        host == null || (hostStatus == 'TO RATE' && host != null);
    bool eligiblePhotographer = photographer == null ||
        (photographerStatus == 'TO RATE' && photographer != null);
    bool eligibleTechnician = technician == null ||
        (technicianStatus == 'TO RATE' && technician != null);
    return (eligibleCatering ||
        eligibleCosmetologist ||
        eligibleGuestPlace ||
        eligibleHost ||
        eligiblePhotographer ||
        eligibleTechnician);
  }

  void markEventAsComplete() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventID)
          .update({'isFinished': true});

      if (catering != null) {
        String feedbackID = DateTime.now().millisecondsSinceEpoch.toString();
        await FirebaseFirestore.instance
            .collection('feedbacks')
            .doc(feedbackID)
            .set({
          'rated': false,
          'rating': 0,
          'feedback': '',
          'rater': FirebaseAuth.instance.currentUser!.uid,
          'receiver': catering!.id
        });

        feedbackID = DateTime.now().millisecondsSinceEpoch.toString();
        await FirebaseFirestore.instance
            .collection('feedbacks')
            .doc(feedbackID)
            .set({
          'rated': false,
          'rating': 0,
          'feedback': '',
          'receiver': FirebaseAuth.instance.currentUser!.uid,
          'rater': catering!.id
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(catering!.id)
            .update({
          'currentClients':
              FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
      }

      if (cosmetologist != null) {
        String feedbackID = DateTime.now().millisecondsSinceEpoch.toString();
        await FirebaseFirestore.instance
            .collection('feedbacks')
            .doc(feedbackID)
            .set({
          'rated': false,
          'rating': 0,
          'feedback': '',
          'rater': FirebaseAuth.instance.currentUser!.uid,
          'receiver': cosmetologist!.id
        });

        feedbackID = DateTime.now().millisecondsSinceEpoch.toString();
        await FirebaseFirestore.instance
            .collection('feedbacks')
            .doc(feedbackID)
            .set({
          'rated': false,
          'rating': 0,
          'feedback': '',
          'receiver': FirebaseAuth.instance.currentUser!.uid,
          'rater': cosmetologist!.id
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(cosmetologist!.id)
            .update({
          'currentClients':
              FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
      }

      if (guestPlace != null) {
        String feedbackID = DateTime.now().millisecondsSinceEpoch.toString();
        await FirebaseFirestore.instance
            .collection('feedbacks')
            .doc(feedbackID)
            .set({
          'rated': false,
          'rating': 0,
          'feedback': '',
          'rater': FirebaseAuth.instance.currentUser!.uid,
          'receiver': guestPlace!.id
        });

        feedbackID = DateTime.now().millisecondsSinceEpoch.toString();
        await FirebaseFirestore.instance
            .collection('feedbacks')
            .doc(feedbackID)
            .set({
          'rated': false,
          'rating': 0,
          'feedback': '',
          'receiver': FirebaseAuth.instance.currentUser!.uid,
          'rater': guestPlace!.id
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(guestPlace!.id)
            .update({
          'currentClients':
              FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
      }

      if (host != null) {
        String feedbackID = DateTime.now().millisecondsSinceEpoch.toString();
        await FirebaseFirestore.instance
            .collection('feedbacks')
            .doc(feedbackID)
            .set({
          'rated': false,
          'rating': 0,
          'feedback': '',
          'rater': FirebaseAuth.instance.currentUser!.uid,
          'receiver': host!.id
        });

        feedbackID = DateTime.now().millisecondsSinceEpoch.toString();
        await FirebaseFirestore.instance
            .collection('feedbacks')
            .doc(feedbackID)
            .set({
          'rated': false,
          'rating': 0,
          'feedback': '',
          'receiver': FirebaseAuth.instance.currentUser!.uid,
          'rater': host!.id
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(host!.id)
            .update({
          'currentClients':
              FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
      }

      if (photographer != null) {
        String feedbackID = DateTime.now().millisecondsSinceEpoch.toString();
        await FirebaseFirestore.instance
            .collection('feedbacks')
            .doc(feedbackID)
            .set({
          'rated': false,
          'rating': 0,
          'feedback': '',
          'rater': FirebaseAuth.instance.currentUser!.uid,
          'receiver': photographer!.id
        });

        feedbackID = DateTime.now().millisecondsSinceEpoch.toString();
        await FirebaseFirestore.instance
            .collection('feedbacks')
            .doc(feedbackID)
            .set({
          'rated': false,
          'rating': 0,
          'feedback': '',
          'receiver': FirebaseAuth.instance.currentUser!.uid,
          'rater': photographer!.id
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(photographer!.id)
            .update({
          'currentClients':
              FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
      }

      if (technician != null) {
        String feedbackID = DateTime.now().millisecondsSinceEpoch.toString();
        await FirebaseFirestore.instance
            .collection('feedbacks')
            .doc(feedbackID)
            .set({
          'rated': false,
          'rating': 0,
          'feedback': '',
          'rater': FirebaseAuth.instance.currentUser!.uid,
          'receiver': technician!.id
        });

        feedbackID = DateTime.now().millisecondsSinceEpoch.toString();
        await FirebaseFirestore.instance
            .collection('feedbacks')
            .doc(feedbackID)
            .set({
          'rated': false,
          'rating': 0,
          'feedback': '',
          'receiver': FirebaseAuth.instance.currentUser!.uid,
          'rater': technician!.id
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(technician!.id)
            .update({
          'currentClients':
              FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'currentEventID': ''});
      setState(() {
        _isLoading = false;
      });
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully marked event as complete.')));
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.clientHome);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error marking event as complete: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: emptyWhiteAppBar(context),
      body: switchedLoadingContainer(
          _isLoading,
          Column(
            children: [
              midnightBGHeaderText(context, label: 'Current Event Details'),
              _eventDetailsContainer(),
              Divider(thickness: 2, color: CustomColors.midnightExtress),
              _currentSuppliersContainer(),
              if (eventDate.difference(DateTime.now()).inDays > 30)
                _editEventButton(),
              if (eligibleForPayAllAtOnce()) _settleAllPaymentsButton(),
              if ((!DateTime.now().isBefore(eventDate)) &&
                  eligibleForEventCompletion())
                postEventWidgets()
            ],
          )),
    );
  }

  Widget _eventDetailsContainer() {
    return all20Pix(
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              comicNeueText(
                  label: 'Event: $eventType',
                  color: CustomColors.midnightExtress,
                  fontWeight: FontWeight.bold,
                  fontSize: 26),
              Gap(7),
              comicNeueText(
                  label:
                      'Date: ${DateFormat('MMM dd, yyyy').format(eventDate)}',
                  color: CustomColors.midnightExtress,
                  fontWeight: FontWeight.bold,
                  fontSize: 26),
            ],
          ),
        ],
      ),
    );
  }

  Widget _currentSuppliersContainer() {
    return Column(children: [
      if (catering != null)
        _currentSupplier(catering!, cateringStatus,
            () => displayCurrentSupplierData(catering!, cateringStatus)),
      if (cosmetologist != null)
        _currentSupplier(
            cosmetologist!,
            cosmetologistStatus,
            () => displayCurrentSupplierData(
                cosmetologist!, cosmetologistStatus)),
      if (guestPlace != null)
        _currentSupplier(guestPlace!, guestPlaceStatus,
            () => displayCurrentSupplierData(guestPlace!, guestPlaceStatus)),
      if (host != null)
        _currentSupplier(host!, hostStatus,
            () => displayCurrentSupplierData(host!, hostStatus)),
      if (photographer != null)
        _currentSupplier(
            photographer!,
            photographerStatus,
            () =>
                displayCurrentSupplierData(photographer!, photographerStatus)),
      if (technician != null)
        _currentSupplier(technician!, technicianStatus,
            () => displayCurrentSupplierData(technician!, technicianStatus)),
    ]);
  }

  Widget _currentSupplier(
      DocumentSnapshot supplierDoc, String paymentStatus, Function onPress) {
    final supplierData = supplierDoc.data() as Map<dynamic, dynamic>;
    return vertical10Pix(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 120,
        child: ElevatedButton(
            onPressed: () => onPress(),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(
                    color: CustomColors.midnightExtress, width: 2)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  //color: Colors.yellow,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildProfileImageWidget(
                          profileImageURL: supplierData['profileImageURL']),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  //color: Colors.red,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      comicNeueText(
                          label: supplierData['offeredService'],
                          color: CustomColors.midnightExtress,
                          fontSize: 23,
                          fontWeight: FontWeight.w900),
                      comicNeueText(
                          label:
                              'Price: PHP ${formatPrice(supplierData['fixedRate'])}',
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: CustomColors.midnightExtress),
                      comicNeueText(
                          label: 'Status:\n$paymentStatus',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: CustomColors.midnightExtress)
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget _editEventButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.65,
      child: ElevatedButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(NavigatorRoutes.editService),
          child: comicNeueText(
              label: 'Add Supplier',
              fontSize: 21,
              color: CustomColors.sweetCorn,
              fontWeight: FontWeight.bold)),
    );
  }

  Widget _settleAllPaymentsButton() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.65,
      child: ElevatedButton(
          onPressed: () => Navigator.of(context)
              .pushNamed(NavigatorRoutes.settleMultiplePayments),
          child: comicNeueText(
              label: 'Settle All Payments',
              fontSize: 21,
              color: CustomColors.sweetCorn,
              fontWeight: FontWeight.bold)),
    );
  }

  void displayCurrentSupplierData(
      DocumentSnapshot supplierDoc, String paymentStatus) {
    final supplierData = supplierDoc.data() as Map<dynamic, dynamic>;
    String profileImageURL = supplierData['profileImageURL'];
    String formattedName =
        '${supplierData['firstName']} ${supplierData['lastName']}';
    String businessName = supplierData['businessName'];
    double fixedRate = supplierData['fixedRate'];
    String offeredService = supplierData['offeredService'];
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                      color: CustomColors.midnightExtress, width: 5)),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      buildProfileImageWidget(profileImageURL: profileImageURL),
                      Gap(40),
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              comicNeueText(
                                  label: 'Supplier Name: ',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25),
                              comicNeueText(label: formattedName, fontSize: 20),
                              Gap(15),
                              comicNeueText(
                                  label: 'Business Name: ',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25),
                              comicNeueText(label: businessName, fontSize: 20),
                              Gap(15),
                              comicNeueText(
                                  label: 'Service Offered: ',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25),
                              comicNeueText(
                                  label: offeredService, fontSize: 20),
                              Gap(15),
                              comicNeueText(
                                  label: 'Total Paid Amount:',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25),
                              if (paymentStatus == 'PENDING DOWN PAYMENT' ||
                                  paymentStatus == 'PROCESSING DOWN PAYMENT')
                                comicNeueText(label: 'PHP 0.00', fontSize: 20)
                              else if (paymentStatus ==
                                      'PENDING COMPLETION PAYMENT' ||
                                  paymentStatus ==
                                      'PROCESSING COMPLETION PAYMENT')
                                comicNeueText(
                                    label: 'PHP ${formatPrice(fixedRate / 2)}',
                                    fontSize: 20)
                              else
                                comicNeueText(
                                    label: 'PHP ${formatPrice(fixedRate)}',
                                    fontSize: 20),
                              Gap(20)
                            ],
                          ),
                        ],
                      ),
                      if (paymentStatus == 'PENDING DOWN PAYMENT')
                        ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              NavigatorRoutes.settlePayment(context,
                                  eventID: eventID,
                                  paymentType: 'DOWN PAYMENT',
                                  paymentAmount: (fixedRate / 2),
                                  serviceOffered: offeredService,
                                  supplierID: supplierDoc.id);
                            },
                            child: Text('SETTLE DOWN PAYMENT',
                                style: buttonSweetCornStyle()))
                      else if (paymentStatus == 'PROCESSING DOWN PAYMENT')
                        comicNeueText(
                            label: 'Your down payment is still being processed',
                            textAlign: TextAlign.center,
                            color: CustomColors.midnightExtress,
                            fontSize: 20)
                      else if (paymentStatus == 'PENDING COMPLETION PAYMENT')
                        Column(
                          children: [
                            comicNeueText(
                                label:
                                    'Your have ${eventDate.difference(DateTime.now()).inDays} days to settle the completion payment.',
                                textAlign: TextAlign.center,
                                color: CustomColors.midnightExtress,
                                fontSize: 18),
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  NavigatorRoutes.settlePayment(context,
                                      eventID: eventID,
                                      paymentType: 'COMPLETION PAYMENT',
                                      paymentAmount: (fixedRate / 2),
                                      serviceOffered: offeredService,
                                      supplierID: supplierDoc.id);
                                },
                                child: comicNeueText(
                                    label: 'SETTLE COMPLETION PAYMENT',
                                    color: CustomColors.sweetCorn,
                                    fontWeight: FontWeight.bold,
                                    textAlign: TextAlign.center,
                                    fontSize: 20)),
                          ],
                        )
                      else if (paymentStatus == 'PROCESSING COMPLETION PAYMENT')
                        comicNeueText(
                            label:
                                'Your completion payment is still being processed',
                            textAlign: TextAlign.center,
                            color: CustomColors.midnightExtress,
                            fontSize: 20),
                      Gap(30),
                      if (paymentStatus == 'PENDING COMPLETION PAYMENT' ||
                          paymentStatus == 'PENDING DOWN PAYMENT' ||
                          paymentStatus == 'PROCESSING DOWN PAYMENT')
                        cancelSelectedClient(supplierDoc)
                      else if (paymentStatus == 'TO RATE')
                        comicNeueText(
                            label:
                                'Please wait until after the event is completed to rate this supplier',
                            textAlign: TextAlign.center,
                            color: CustomColors.midnightExtress,
                            fontSize: 20)
                    ],
                  ),
                ),
              ),
            ));
  }

  Widget cancelSelectedClient(DocumentSnapshot supplierDoc) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            showConfirmSupplierCancelDialoog(supplierDoc);
          },
          child: Text('CANCEL SERVICE', style: buttonSweetCornStyle())),
    );
  }

  void showConfirmSupplierCancelDialoog(DocumentSnapshot supplierDoc) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: comicNeueText(
                      label:
                          'Are you sure you want to cancel this supplier? All payments made will not be refunded.',
                      fontSize: 18)),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: comicNeueText(label: 'Go Back')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      cancelThisSupplier(supplierDoc);
                    },
                    child: comicNeueText(label: 'Cancel Supplier'))
              ],
            ));
  }

  Widget postEventWidgets() {
    return all20Pix(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: markEventAsComplete,
          child: Text('MARK EVENT AS COMPLETED',
              textAlign: TextAlign.center, style: buttonSweetCornStyle()),
        ),
      ),
    );
  }
}
