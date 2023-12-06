import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../utils/colors_util.dart';
import '../utils/custom_string_util.dart';
import '../utils/navigator_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_styling_widgets.dart';

class HandleCashoutsScreen extends StatefulWidget {
  const HandleCashoutsScreen({super.key});

  @override
  State<HandleCashoutsScreen> createState() => _HandleCashoutsScreenState();
}

class _HandleCashoutsScreenState extends State<HandleCashoutsScreen> {
  bool _isLoading = true;
  //  From Transaction Collection
  List<DocumentSnapshot> submittedCashoutDocs = [];

  //  From Users Collection
  List<DocumentSnapshot> associatedUserDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getPendingCashouts();
  }

  void getPendingCashouts() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final cashouts = await FirebaseFirestore.instance
          .collection('cashouts')
          .where('verified', isEqualTo: false)
          .get();
      submittedCashoutDocs = cashouts.docs;

      if (submittedCashoutDocs.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      //  Get all associated user IDs
      List<String> associatedUIDs = [];
      for (var cashoutRequest in submittedCashoutDocs) {
        final cashoutData = cashoutRequest.data() as Map<dynamic, dynamic>;
        String supplierID = cashoutData['receiver'];
        if (!associatedUIDs.contains(supplierID)) {
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

  void denyCashoutRequest(DocumentSnapshot cashoutDoc) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('cashouts')
          .doc(cashoutDoc.id)
          .update({'verified': true, 'status': 'DENIED'});
      getPendingCashouts();
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error denying this cashout request: $error')));
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
          SingleChildScrollView(
              child: Column(
            children: [
              midnightBGHeaderText(context, label: 'Submitted Cashouts'),
              _submittedPaymentsContainer()
            ],
          ))),
    );
  }

  Widget _submittedPaymentsContainer() {
    return all20Pix(
        child: submittedCashoutDocs.isNotEmpty
            ? SingleChildScrollView(
                child: Column(
                children: submittedCashoutDocs.map((cashoutDoc) {
                  final requestData =
                      cashoutDoc.data() as Map<dynamic, dynamic>;
                  DocumentSnapshot supplierDoc = associatedUserDocs
                      .where((member) => member.id == requestData['receiver'])
                      .first;
                  return _cashoutRequestEntry(supplierDoc, cashoutDoc);
                }).toList(),
              ))
            : comicNeueText(
                label: 'NO WITHDRAWAL REQUESTS AVAILABLE',
                fontSize: 35,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center));
  }

  Widget _cashoutRequestEntry(
      DocumentSnapshot supplierDoc, DocumentSnapshot cashOutDoc) {
    final supplierData = supplierDoc.data() as Map<dynamic, dynamic>;
    String formattedSupplierName =
        '${supplierData['firstName']} ${supplierData['lastName']}';
    final cashOutData = cashOutDoc.data() as Map<dynamic, dynamic>;
    double amount = cashOutData['requestedAmount'];
    DateTime dateRequested =
        (cashOutData['dateRequested'] as Timestamp).toDate();
    return Padding(
      padding: EdgeInsets.all(5),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(color: CustomColors.midnightExtress),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              comicNeueText(
                  label: 'REQUESTING SUPPLIER:',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
              comicNeueText(
                  label: formattedSupplierName,
                  color: Colors.white,
                  fontSize: 20),
              Gap(15),
              comicNeueText(
                  label: 'REQUESTED AMOUNT:',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
              comicNeueText(
                  label: 'PHP ${formatPrice(amount)}',
                  color: Colors.white,
                  fontSize: 20),
              Gap(15),
              comicNeueText(
                  label:
                      'Date Requested: ${DateFormat('MMM dd, yyyy').format(dateRequested)}',
                  color: Colors.white,
                  fontSize: 20),
              Gap(20),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                      onPressed: () => NavigatorRoutes.approveCashout(context,
                          cashoutDoc: cashOutDoc, supplierDoc: supplierDoc),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColors.sweetCorn),
                      child: comicNeueText(
                          label: 'APPROVE',
                          color: CustomColors.midnightExtress,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  width: 100,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: CustomColors.sweetCorn),
                      onPressed: () => denyCashoutRequest(cashOutDoc),
                      child: comicNeueText(
                          label: 'DENY',
                          color: CustomColors.midnightExtress,
                          fontWeight: FontWeight.bold)),
                )
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
