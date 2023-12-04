import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../utils/colors_util.dart';
import '../utils/custom_string_util.dart';
import '../widgets/custom_styling_widgets.dart';

class HandlePaymentScreen extends StatefulWidget {
  const HandlePaymentScreen({super.key});

  @override
  State<HandlePaymentScreen> createState() => _HandlePaymentScreenState();
}

class _HandlePaymentScreenState extends State<HandlePaymentScreen> {
  bool _isLoading = true;
  //  From Transaction Collection
  List<DocumentSnapshot> submittedPayments = [];

  //  From Users Collection
  List<DocumentSnapshot> associatedUserDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getPendingPayments();
  }

  void getPendingPayments() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final payments = await FirebaseFirestore.instance
          .collection('transactions')
          .where('verified', isEqualTo: false)
          .where('transactionType',
              whereIn: ['DOWN PAYMENT', 'COMPLETION PAYMENT']).get();
      submittedPayments = payments.docs;

      if (submittedPayments.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      //  Get all associated user IDs
      List<String> associatedUIDs = [];
      for (var paymentRequest in submittedPayments) {
        final paymentData = paymentRequest.data() as Map<dynamic, dynamic>;
        String clientID = paymentData['user'];
        String supplierID = paymentData['receiver'];
        if (!associatedUIDs.contains(clientID)) {
          associatedUIDs.add(clientID);
        }
        if (!associatedUserDocs.contains(supplierID)) {
          associatedUIDs.add(supplierID);
        }
      }

      //  Get all associated user docs.
      final users = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: associatedUIDs)
          .get();
      associatedUserDocs = users.docs;

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting submitted payments: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void handlePaymentSubmission(
      DocumentSnapshot clientDoc,
      DocumentSnapshot supplierDoc,
      DocumentSnapshot transactionDoc,
      bool isAccepted) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });

      //  Get the current event's data
      final clientData = clientDoc.data() as Map<dynamic, dynamic>;
      String currentEventID = clientData['currentEventID'];
      Map<dynamic, dynamic> eventData = await getThisEvent(currentEventID);
      Map<dynamic, dynamic> supplierData =
          supplierDoc.data() as Map<dynamic, dynamic>;
      String serviceOffered = supplierData['offeredService'];
      String serviceParameter = getServiceParameter(serviceOffered);
      Map<dynamic, dynamic> currentSupplierMap = eventData[serviceParameter];
      String status = currentSupplierMap['status'];
      final transactionData = transactionDoc.data() as Map<dynamic, dynamic>;
      String transactionType = transactionData['transactionType'];

      //  The submitted payment is accepted.
      if (isAccepted) {
        //  Set the transaction's verified status to true
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc(transactionDoc.id)
            .update({'verified': isAccepted, 'dateSettled': DateTime.now()});

        //  Update the event's document
        currentSupplierMap['confirmed'] = true;
        if (status == 'PROCESSING DOWN PAYMENT')
          currentSupplierMap['status'] = 'PENDING COMPLETION PAYMENT';
        else if (status == 'PROCESSING COMPLETION PAYMENT')
          currentSupplierMap['status'] = 'TO RATE';
        await FirebaseFirestore.instance
            .collection('events')
            .doc(currentEventID)
            .update({serviceParameter: currentSupplierMap});

        //  Create an entry in the income collection
        String incomeID = DateTime.now().millisecondsSinceEpoch.toString();
        double receivedAmount =
            transactionData['amount'] - (transactionData['amount'] * 0.05);
        String incomeType = transactionData['transactionType'];
        await FirebaseFirestore.instance
            .collection('incomes')
            .doc(incomeID)
            .set({
          'commission': transactionData['amount'] * 0.05,
          'receivedAmount': receivedAmount,
          'receiver': supplierDoc.id,
          'sender': clientDoc.id,
          'incomeType': incomeType,
          'transactionID': transactionDoc.id
        });
      }
      //  The submitted payment is rejected
      else {
        //  Delete the transaction document
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc(transactionDoc.id)
            .delete();

        //  Select the affected transaction and make it empty
        String affectedTransaction = '';
        if (transactionType == 'DOWN PAYMENT') {
          affectedTransaction = 'downPaymentTransaction';
        } else if (transactionType == 'COMPLETION PAYMENT') {
          affectedTransaction = 'completionPaymentTransaction';
        }
        currentSupplierMap[affectedTransaction] = '';

        //  Change the local values of the current supplier map.
        if (status == 'PROCESSING DOWN PAYMENT')
          currentSupplierMap['status'] = 'PENDING DOWN PAYMENT';
        else if (status == 'PROCESSING COMPLETION PAYMENT')
          currentSupplierMap['status'] = 'PENDING COMPLETION PAYMENT';
        await FirebaseFirestore.instance
            .collection('events')
            .doc(currentEventID)
            .update({serviceParameter: currentSupplierMap});

        //  Delete the proof of payment
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('transactions')
            .child('payment')
            .child(transactionDoc.id);
        await storageRef.delete();
      }

      //  Time to refresh the page
      getPendingPayments();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error handling payment submission: $error')));
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
          body: switchedLoadingContainer(
              _isLoading,
              Column(
                children: [
                  midnightBGHeaderText(context, label: 'Submitted Payments'),
                  _submittedPaymentsContainer()
                ],
              )),
        ));
  }

  Widget _submittedPaymentsContainer() {
    return all20Pix(
        child: submittedPayments.isNotEmpty
            ? SingleChildScrollView(
                child: Column(
                children: submittedPayments.map((request) {
                  final requestData = request.data() as Map<dynamic, dynamic>;
                  DocumentSnapshot clientDoc = associatedUserDocs
                      .where((member) => member.id == requestData['user'])
                      .first;
                  DocumentSnapshot supplierDoc = associatedUserDocs
                      .where((member) => member.id == requestData['receiver'])
                      .first;
                  return _paymentRequestEntry(clientDoc, supplierDoc, request);
                }).toList(),
              ))
            : comicNeueText(
                label: 'NO SUBMITTED PAYMENTS AVAILABLE',
                fontSize: 35,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center));
  }

  Widget _paymentRequestEntry(DocumentSnapshot clientDoc,
      DocumentSnapshot supplierDoc, DocumentSnapshot transactionDoc) {
    final clientData = clientDoc.data() as Map<dynamic, dynamic>;
    String formattedClientName =
        '${clientData['firstName']} ${clientData['lastName']}';
    final supplierData = supplierDoc.data() as Map<dynamic, dynamic>;
    String formattedSupplierName =
        '${supplierData['firstName']} ${supplierData['lastName']}';
    final transactionData = transactionDoc.data() as Map<dynamic, dynamic>;
    String transactionType = transactionData['transactionType'];
    String proofOfPayment = transactionData['proofOfPayment'];
    double amount = transactionData['amount'];
    return Padding(
      padding: EdgeInsets.all(5),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(color: CustomColors.midnightExtress),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              comicNeueText(
                  label: 'TRANSACTION TYPE: ',
                  textAlign: TextAlign.center,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
              comicNeueText(
                  label: transactionType,
                  textAlign: TextAlign.center,
                  color: Colors.white,
                  fontSize: 25),
              Gap(20),
              comicNeueText(
                  label: 'SENDER: $formattedClientName',
                  textAlign: TextAlign.center,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
              comicNeueText(
                  label: 'RECEIVER: $formattedSupplierName',
                  textAlign: TextAlign.center,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
              vertical10Pix(
                child: comicNeueText(
                    label: 'PAID AMOUNT: PHP ${formatPrice(amount)}',
                    textAlign: TextAlign.center,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                SizedBox(
                  width: 80,
                  child: ElevatedButton(
                      onPressed: () => handlePaymentSubmission(
                          clientDoc, supplierDoc, transactionDoc, true),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColors.sweetCorn),
                      child: comicNeueText(
                          label: 'ACCEPT',
                          color: CustomColors.midnightExtress,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  width: 80,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColors.sweetCorn),
                      onPressed: () => handlePaymentSubmission(
                          clientDoc, supplierDoc, transactionDoc, false),
                      child: comicNeueText(
                          label: 'REJECT',
                          color: CustomColors.midnightExtress,
                          fontWeight: FontWeight.bold)),
                )
              ]),
              SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ElevatedButton(
                    onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                            backgroundColor: Colors.black,
                            content: Image.network(proofOfPayment))),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: comicNeueText(
                        label: 'VIEW PROOF OF PAYMENT',
                        color: CustomColors.midnightExtress,
                        fontWeight: FontWeight.w800),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
