import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

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
              _editEventButton()
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
                          label: 'Price: ${supplierData['fixedRate']}',
                          fontSize: 23,
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
    return ElevatedButton(
        onPressed: () => Navigator.of(context)
            .pushReplacementNamed(NavigatorRoutes.editService),
        child: comicNeueText(
            label: 'Edit Event',
            fontSize: 21,
            color: CustomColors.sweetCorn,
            fontWeight: FontWeight.bold));
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
                                  label: 'Total Paid Amount: ',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25),
                              if (paymentStatus == 'PENDING DOWN PAYMENT' ||
                                  paymentStatus == 'PROCESSING DOWN PAYMENT')
                                comicNeueText(label: '0.00', fontSize: 20)
                              else if (paymentStatus ==
                                      'PENDING COMPLETION PAYMENT' ||
                                  paymentStatus ==
                                      'PROCESSING COMPLETION PAYMENT')
                                comicNeueText(
                                    label: (fixedRate / 2).toStringAsFixed(2),
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
                                    'Your have X days to settle the down payment.',
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
                                child: Text('SETTLE DOWN PAYMENT',
                                    style: buttonSweetCornStyle())),
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('CANCEL SERVICE',
                                style: buttonSweetCornStyle())),
                      )
                    ],
                  ),
                ),
              ),
            ));
  }
}
