import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/log_out_util.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

import '../widgets/custom_miscellaneous_widgets.dart';

class SettleMembershipFeeScreen extends StatefulWidget {
  const SettleMembershipFeeScreen({super.key});

  @override
  State<SettleMembershipFeeScreen> createState() =>
      _SettleMembershipFeeScreenState();
}

class _SettleMembershipFeeScreenState extends State<SettleMembershipFeeScreen> {
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
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('proofOfPayment')
          .child(FirebaseAuth.instance.currentUser!.uid);
      final uploadTask = storageRef.putFile(_proofOfPayment!);
      final taskSnapshot = await uploadTask.whenComplete(() {});
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'proofOfPayment': downloadURL});
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully uploaded proof of payment!')));
      setState(() {
        _isLoading = false;
      });
      navigator.pop();
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
    return WillPopScope(
      onWillPop: () async {
        showLogOutModal(context);
        return false;
      },
      child: Scaffold(
          body: stackedLoadingContainer(
              context,
              _isLoading,
              SingleChildScrollView(
                child: all20Pix(
                    child: Column(
                  children: [
                    loginHeaderWidgets(
                        label: 'Please settle the PHP 150.00 membership fee.'),
                    _paymentOptions(),
                    Gap(20),
                    _proofOfPaymentWidgets()
                  ],
                )),
              ))),
    );
  }

  Widget _paymentOptions() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          border: Border.all(color: CustomColors.midnightExtress)),
      child: all20Pix(
          child: Column(
        children: [
          comicNeueText(
              label:
                  'You may settle the membership fee via any of the following channels:',
              fontWeight: FontWeight.bold,
              fontSize: 20),
          Gap(20),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  comicNeueText(
                      label: 'GCash: 1234567890',
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                  comicNeueText(
                      label: 'PayMaya: 1234567890',
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                  comicNeueText(
                      label: 'BDO: 1234567890',
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ],
              ),
            ],
          )
        ],
      )),
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
      ElevatedButton(
          onPressed: () {
            _proofOfPayment != null ? _uploadProofOfPayment() : _pickImage();
          },
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30))),
          child: Text(
            _proofOfPayment != null
                ? 'SUBMIT PROOF OF PAYMENT'
                : 'SELECT PROOF OF PAYMENT',
            style: buttonSweetCornStyle(),
          ))
    ]));
  }
}
