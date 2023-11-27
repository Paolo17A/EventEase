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

class SettlePaymentScreen extends StatefulWidget {
  final String eventID;
  final String paymentType;
  final double paymentAmount;
  final String serviceOffered;
  final String supplierID;
  const SettlePaymentScreen(
      {super.key,
      required this.eventID,
      required this.paymentType,
      required this.paymentAmount,
      required this.serviceOffered,
      required this.supplierID});

  @override
  State<SettlePaymentScreen> createState() => _SettlePaymentScreenState();
}

class _SettlePaymentScreenState extends State<SettlePaymentScreen> {
  bool _isLoading = false;
  File? _proofOfPayment;
  ImagePicker imagePicker = ImagePicker();
  String serviceParameter = '';

  @override
  void initState() {
    super.initState();
    serviceParameter = getServiceParameter(widget.serviceOffered);
    print('offered service: ${widget.serviceOffered}');
    print('service parameter: $serviceParameter');
  }

  Future<void> _pickImage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _proofOfPayment = File(pickedFile.path);
      });
    }
  }

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
        'transactionType': widget.paymentType,
        'user': FirebaseAuth.instance.currentUser!.uid,
        'verified': false,
        'amount': widget.paymentAmount,
        'proofOfPayment': downloadURL,
        'dateCreated': DateTime.now(),
        'dateSettled': DateTime(1970),
        'receiver': widget.supplierID
      });

      //  Attach transaction ID to the event document
      String affectedTransaction = '';
      if (widget.paymentType == 'DOWN PAYMENT') {
        affectedTransaction = 'downPaymentTransaction';
      } else if (widget.paymentAmount == 'COMPLETION PAYMENT') {
        affectedTransaction = 'completionPaymentTransaction';
      }

      //  Get the current supplier map from the event
      final eventData = await getThisEvent(widget.eventID);
      String serviceOffered = getServiceParameter(widget.serviceOffered);

      //  Change the local values of the current supplier map.
      Map<dynamic, dynamic> currentSupplierMap = eventData[serviceOffered];
      currentSupplierMap[affectedTransaction] = transactionID;
      currentSupplierMap['status'] = 'PROCESSING ${widget.paymentType}';

      //  Update the current supplier map with new values in the event document.
      await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventID)
          .update({serviceOffered: currentSupplierMap});

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
          appBar: emptyWhiteAppBar(context, label: widget.serviceOffered),
          body: stackedLoadingContainer(
              context,
              _isLoading,
              SingleChildScrollView(
                child: Column(
                  children: [
                    midnightBGHeaderText(context, label: 'Settle Payment'),
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
          label:
              '${widget.paymentType}: ${widget.paymentAmount.toStringAsFixed(2)}',
          fontWeight: FontWeight.bold,
          fontSize: 28),
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
                    ? 'SUBMIT PROOF OF ${widget.paymentType}'
                    : 'SELECT PROOF OF ${widget.paymentType}',
                textAlign: TextAlign.center,
                style: buttonSweetCornStyle(),
              ),
            )),
      )
    ]));
  }
}
