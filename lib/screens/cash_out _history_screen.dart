import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/colors_util.dart';
import '../utils/custom_string_util.dart';
import '../widgets/custom_styling_widgets.dart';

class CashOutHistoryScreen extends StatefulWidget {
  const CashOutHistoryScreen({super.key});

  @override
  State<CashOutHistoryScreen> createState() => _CashOutHistoryScreenState();
}

class _CashOutHistoryScreenState extends State<CashOutHistoryScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> cashoutDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCashOutRequests();
  }

  void getCashOutRequests() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final cashout = await FirebaseFirestore.instance
          .collection('cashouts')
          .where('receiver', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      cashoutDocs = cashout.docs;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting cashout requests: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: CustomColors.midnightExtress,
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context)
                  .pushNamed(NavigatorRoutes.newCashOutRequest),
              child: comicNeueText(
                  label: 'Make New\nWithdrawal',
                  fontSize: 15,
                  textAlign: TextAlign.center))
        ],
      ),
      body: switchedLoadingContainer(
          _isLoading,
          Column(
            children: [
              midnightBGHeaderText(context, label: 'Withdrawal Requests'),
              _cashoutHistoryContainer()
            ],
          )),
    );
  }

  Widget _cashoutHistoryContainer() {
    return all20Pix(
        child: cashoutDocs.isNotEmpty
            ? SingleChildScrollView(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: cashoutDocs.length,
                    itemBuilder: (context, index) {
                      return _cashoutEntrywidget(cashoutDocs[index]);
                    }),
              )
            : comicNeueText(
                label: 'YOU HAVE NOT MADE ANY WITHDRAWAL REQUESTS YET',
                fontSize: 30,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center));
  }

  Widget _cashoutEntrywidget(DocumentSnapshot cashoutDoc) {
    final cashoutData = cashoutDoc.data() as Map<dynamic, dynamic>;
    double requestedAmount = cashoutData['requestedAmount'];
    String status = cashoutData['status'];
    DateTime dateRequested =
        (cashoutData['dateRequested'] as Timestamp).toDate();
    String proofOfPayment = cashoutData['proofOfPayment'];
    return GestureDetector(
      onTap: () {
        if (status != 'APPROVED') return;
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.width * 0.75,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: NetworkImage(proofOfPayment))),
                  ),
                ));
      },
      child: vertical10Pix(
          child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            border: Border.all(color: CustomColors.midnightExtress, width: 2)),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              comicNeueText(
                  label:
                      'Requested Amount: PHP ${formatPrice(requestedAmount)}',
                  color: CustomColors.midnightExtress,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
              comicNeueText(
                  label:
                      'Date Requested: ${DateFormat('MMM dd, yyyy').format(dateRequested)}',
                  color: CustomColors.midnightExtress,
                  fontSize: 16),
              comicNeueText(
                  label: 'Status: $status',
                  color: CustomColors.midnightExtress,
                  fontSize: 16),
            ],
          ),
        ),
      )),
    );
  }
}
