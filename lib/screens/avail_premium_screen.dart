import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/custom_containers_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_styling_widgets.dart';

class AvailPremiumScreen extends StatefulWidget {
  const AvailPremiumScreen({super.key});

  @override
  State<AvailPremiumScreen> createState() => _AvailPremiumScreenState();
}

class _AvailPremiumScreenState extends State<AvailPremiumScreen> {
  bool _isLoading = false;
  File? _proofOfPayment;
  ImagePicker imagePicker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _proofOfPayment = File(pickedFile.path);
      });
    }
  }

  void _uploadProofOfPayment() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      //  Handle Profile Image
      String transactionID = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('transactions')
          .child('premium')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child(transactionID);
      final uploadTask = storageRef.putFile(_proofOfPayment!);
      final taskSnapshot = await uploadTask.whenComplete(() {});
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transactionID)
          .set({
        'transactionType': 'PREMIUM',
        'user': FirebaseAuth.instance.currentUser!.uid,
        'verified': false,
        'amount': 200.00,
        'proofOfPayment': downloadURL,
        'dateCreated': DateTime.now(),
        'dateSettled': DateTime(1970)
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'latestPremiumSupplierPayment': transactionID});
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully applied for premium service!')));
      setState(() {
        _isLoading = false;
      });
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.supplierProfile);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error uploading proof of payment.')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: stackedLoadingContainer(
            context,
            _isLoading,
            SingleChildScrollView(
              child: all20Pix(
                  child: Column(
                children: [
                  loginHeaderWidgets(
                      label:
                          'Please settle the monthly PHP 200.00 premium supplier free.'),
                  paymentOptions(),
                  Gap(20),
                  _proofOfPaymentWidgets()
                ],
              )),
            )));
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
        width: 200,
        child: ElevatedButton(
            onPressed: () {
              _proofOfPayment != null ? _uploadProofOfPayment() : _pickImage();
            },
            style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: comicNeueText(
                  label: _proofOfPayment != null
                      ? 'SUBMIT PREMIUM APPLICATION'
                      : 'SELECT PROOF OF PAYMENT',
                  textAlign: TextAlign.center,
                  color: CustomColors.sweetCorn,
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
            )),
      )
    ]));
  }
}
