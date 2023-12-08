import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../utils/custom_string_util.dart';
import '../widgets/custom_styling_widgets.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> clientTransactions = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getClientTransactions();
  }

  void getClientTransactions() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final transactions = await FirebaseFirestore.instance
          .collection('transactions')
          .where('user', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      clientTransactions = transactions.docs;
      clientTransactions = clientTransactions.reversed.toList();
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting client transactions: $error')));
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
                midnightBGHeaderText(context, label: 'My Transaction History'),
                _transactionContainer()
              ],
            ),
          )),
    );
  }

  Widget _transactionContainer() {
    return all20Pix(
        child: clientTransactions.isNotEmpty
            ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: clientTransactions.length,
                itemBuilder: (context, index) {
                  return _transactionEntry(clientTransactions[index]);
                })
            : comicNeueText(
                label: 'NO AVAILABLE TRANSACTIONS',
                fontSize: 35,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center));
  }

  Widget _transactionEntry(DocumentSnapshot transactionDoc) {
    final transactionData = transactionDoc.data() as Map<dynamic, dynamic>;
    String transactionType = transactionData['transactionType'];
    double amount = transactionData['amount'];
    DateTime dateCreated =
        (transactionData['dateCreated'] as Timestamp).toDate();
    DateTime dateSettled =
        (transactionData['dateSettled'] as Timestamp).toDate();

    return vertical10Pix(
        child: Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          border: Border.all(color: CustomColors.midnightExtress, width: 2)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          comicNeueText(
              label: 'Transaction Type: $transactionType',
              fontWeight: FontWeight.bold,
              fontSize: 20),
          Gap(5),
          comicNeueText(
              label: 'Paid Amount: PHP ${formatPrice(amount)}',
              fontWeight: FontWeight.bold,
              fontSize: 20),
          Gap(15),
          comicNeueText(
              label:
                  'Date Payment Sent: ${DateFormat('MMM dd, yyyy').format(dateCreated)}',
              fontSize: 16),
          if (dateSettled.year == 1970)
            comicNeueText(
                label: 'Payment is still being verified.', fontSize: 18)
          else
            comicNeueText(
                label:
                    'Date Payment Verified: ${DateFormat('MMM dd, yyyy').format(dateSettled)}',
                fontSize: 16),
        ],
      ),
    ));
  }
}
