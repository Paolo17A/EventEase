import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/custom_string_util.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/colors_util.dart';
import '../utils/navigator_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';

class ApproveCashoutScreen extends StatefulWidget {
  final DocumentSnapshot cashoutDoc;
  final DocumentSnapshot supplierDoc;
  ApproveCashoutScreen(
      {super.key, required this.cashoutDoc, required this.supplierDoc});

  @override
  State<ApproveCashoutScreen> createState() => _ApproveCashoutScreenState();
}

class _ApproveCashoutScreenState extends State<ApproveCashoutScreen> {
  bool _isLoading = false;
  double requestedAmount = 0;
  String formattedName = '';
  String paymentChannel = '';
  String accountNumber = '';
  File? _proofOfPayment;
  ImagePicker imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final cashoutData = widget.cashoutDoc.data() as Map<dynamic, dynamic>;
    requestedAmount = cashoutData['requestedAmount'];
    paymentChannel = cashoutData['paymentChannel'];
    accountNumber = cashoutData['accountNumber'];

    final supplierData = widget.supplierDoc.data() as Map<dynamic, dynamic>;
    formattedName = '${supplierData['firstName']} ${supplierData['lastName']}';
  }

  Future<void> _pickImage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _proofOfPayment = File(pickedFile.path);
      });
    }
  }

  void _approveCashoutRequest() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      //  Handle Profile Image
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('cashouts')
          .child(widget.cashoutDoc.id);
      final uploadTask = storageRef.putFile(_proofOfPayment!);
      final taskSnapshot = await uploadTask.whenComplete(() {});
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('cashouts')
          .doc(widget.cashoutDoc.id)
          .update({
        'verified': true,
        'status': 'APPROVED',
        'proofOfPayment': downloadURL,
        'dateSettled': DateTime.now()
      });
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Successfully approved this withdrawal request.')));
      setState(() {
        _isLoading = false;
      });
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.handleCashouts);
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
      appBar: emptyWhiteAppBar(context),
      body: stackedLoadingContainer(
          context,
          _isLoading,
          SingleChildScrollView(
              child: Column(
            children: [
              midnightBGHeaderText(context, label: 'CASHOUT APPROVAL'),
              all20Pix(
                child: Column(
                  children: [
                    comicNeueText(
                        label:
                            'You are about to approve the withdrawal of $formattedName.',
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                    Gap(20),
                    _paymentDetails(),
                    _proofOfPaymentWidgets()
                  ],
                ),
              ),
            ],
          ))),
    );
  }

  Widget _paymentDetails() {
    return Row(
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          comicNeueText(
              label: 'TOTAL AMOUNT:',
              fontSize: 25,
              fontWeight: FontWeight.bold),
          comicNeueText(
              label: 'PHP ${formatPrice(requestedAmount)}', fontSize: 25),
          Gap(12),
          comicNeueText(
              label: 'PAYMENT CHANNEL:',
              fontWeight: FontWeight.bold,
              fontSize: 20),
          comicNeueText(label: paymentChannel, fontSize: 20),
          Gap(12),
          comicNeueText(
              label: 'ACCOUNT NUMBER:',
              fontWeight: FontWeight.bold,
              fontSize: 20),
          comicNeueText(label: accountNumber, fontSize: 20)
        ]),
      ],
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
        width: 400,
        child: ElevatedButton(
            onPressed: () {
              _proofOfPayment != null ? _approveCashoutRequest() : _pickImage();
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
