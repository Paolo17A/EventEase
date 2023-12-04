import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/custom_string_util.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/custom_styling_widgets.dart';

class SettleMultiplePaymentScreen extends StatefulWidget {
  const SettleMultiplePaymentScreen({super.key});

  @override
  State<SettleMultiplePaymentScreen> createState() =>
      _SettleMultiplePaymentScreenState();
}

class _SettleMultiplePaymentScreenState
    extends State<SettleMultiplePaymentScreen> {
  bool _isLoading = true;

  double totalPayableAmount = 0;
  List<String> eligibleSuppliers = [];
  String currentEventID = '';

  //  Image Variables
  File? _proofOfPayment;
  ImagePicker imagePicker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getEventPayables();
  }

  //  INITIALIZATION
  //============================================================================
  void getEventPayables() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final userData =
          await getThisUserData(FirebaseAuth.instance.currentUser!.uid);
      currentEventID = userData['currentEventID'];
      final eventData = await getThisEvent(currentEventID);
      await addPayableAmount(eventData['catering']);
      await addPayableAmount(eventData['cosmetologist']);
      await addPayableAmount(eventData['guestPlace']);
      await addPayableAmount(eventData['host']);
      await addPayableAmount(eventData['photographer']);
      await addPayableAmount(eventData['technician']);

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error getting total payable amount: $error')));
      navigator.pop();
    }
  }

  Future addPayableAmount(Map<dynamic, dynamic> supplierMap) async {
    print('Supplier Map: $supplierMap');
    bool isConfirmed = supplierMap['confirmed'];
    String status = supplierMap['status'];
    if (!isConfirmed ||
        status == 'PROCESSING DOWN PAYMENT' ||
        status == 'PROCESSING COMPLETION PAYMENT' ||
        status == 'TO RATE') {
      return;
    }
    final supplierData = await getThisUserData(supplierMap['supplier']);
    double payableAmount = supplierData['fixedRate'] / 2;
    totalPayableAmount += payableAmount;
    eligibleSuppliers.add(supplierMap['supplier']);
  }

  //  IMAGE SELECTION
  //============================================================================
  Future<void> _pickImage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _proofOfPayment = File(pickedFile.path);
      });
    }
  }

  //  PAYMENT SUBMISSION
  //============================================================================
  void submitPayment() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      setState(() {
        _isLoading = true;
      });

      String transactionID = DateTime.now().millisecondsSinceEpoch.toString();

      //  Handle Upload Membership Image
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('transactions')
          .child('payment')
          .child(transactionID);
      final uploadTask = storageRef.putFile(_proofOfPayment!);
      final taskSnapshot = await uploadTask.whenComplete(() {});
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();

      //  Create new entry in transactions collection
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transactionID)
          .set({
        'transactionType': 'MULTIPLE PAYMENT',
        'user': FirebaseAuth.instance.currentUser!.uid,
        'event': currentEventID,
        'verified': false,
        'amount': totalPayableAmount,
        'proofOfPayment': downloadURL,
        'dateCreated': DateTime.now(),
        'dateSettled': DateTime(1970),
        'receivers': eligibleSuppliers
      });

      final eventData = await getThisEvent(currentEventID);
      for (var supplier in eligibleSuppliers) {
        final supplierData = await getThisUserData(supplier);
        String serviceOffered =
            getServiceParameter(supplierData['offeredService']);

        //  Change the local values of the current supplier map.
        Map<dynamic, dynamic> currentSupplierMap = eventData[serviceOffered];
        String currentSupplierStatus = currentSupplierMap['status'];
        //  Attach transaction ID to the event document
        String affectedTransaction = '';
        if (currentSupplierStatus == 'PENDING DOWN PAYMENT') {
          affectedTransaction = 'downPaymentTransaction';
        } else if (currentSupplierStatus == 'PENDING COMPLETION PAYMENT') {
          affectedTransaction = 'completionPaymentTransaction';
        }
        currentSupplierMap[affectedTransaction] = transactionID;
        if (currentSupplierStatus == 'PENDING DOWN PAYMENT') {
          currentSupplierMap['status'] = 'PROCESSING DOWN PAYMENT';
        } else if (currentSupplierStatus == 'PENDING COMPLETION PAYMENT') {
          currentSupplierMap['status'] = 'PROCESSING COMPLETION PAYMENT';
        }

        //  Update the current supplier map with new values in the event document.
        await FirebaseFirestore.instance
            .collection('events')
            .doc(currentEventID)
            .update({serviceOffered: currentSupplierMap});
      }

      //  Indicate success and return to the currentEvent screen.
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully submitted proof of payment.')));
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.currentEvent);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error submitting payment: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isLoading)
          return false;
        else
          return true;
      },
      child: Scaffold(
          appBar: emptyWhiteAppBar(context),
          body: stackedLoadingContainer(
              context,
              _isLoading,
              SingleChildScrollView(
                child: Column(
                  children: [
                    midnightBGHeaderText(context, label: 'Settle All Payments'),
                    all20Pix(
                      child: Column(
                        children: [
                          _totalAmount(),
                          paymentOptions(),
                          Gap(20),
                          _proofOfPaymentWidgets()
                        ],
                      ),
                    ),
                  ],
                ),
              ))),
    );
  }

  Widget _totalAmount() {
    return vertical10Pix(
      child: comicNeueText(
          label: 'Total Amount: PHP ${formatPrice(totalPayableAmount)}',
          fontWeight: FontWeight.bold,
          fontSize: 25),
    );
  }

  Widget _proofOfPaymentWidgets() {
    return all20Pix(
        child: Column(children: [
      if (_proofOfPayment != null)
        Column(children: [
          GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          backgroundColor: Colors.black,
                          content: Image.file(_proofOfPayment!),
                        ));
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration:
                      BoxDecoration(border: Border.all(), color: Colors.black),
                  child: Image.file(_proofOfPayment!),
                ),
              )),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _proofOfPayment = null;
                });
              },
              child: const Icon(Icons.delete, color: Colors.white)),
          Gap(30)
        ]),
      SizedBox(
        width: MediaQuery.of(context).size.width * 0.65,
        child: ElevatedButton(
            onPressed: () {
              _proofOfPayment != null ? submitPayment() : _pickImage();
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: vertical10Pix(
              child: Text(
                _proofOfPayment != null
                    ? 'SUBMIT PROOF OF PAYMENT'
                    : 'SELECT PROOF OF PAYMENT',
                textAlign: TextAlign.center,
                style: buttonSweetCornStyle(),
              ),
            )),
      )
    ]));
  }
}
