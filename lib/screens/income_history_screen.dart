import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/navigator_util.dart';
import '../widgets/custom_styling_widgets.dart';

class IncomeHistoryScreen extends StatefulWidget {
  const IncomeHistoryScreen({super.key});

  @override
  State<IncomeHistoryScreen> createState() => _IncomeHistoryScreenState();
}

class _IncomeHistoryScreenState extends State<IncomeHistoryScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> incomeDocs = [];
  List<DocumentSnapshot> senderDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getSupplierIncomeHistory();
  }

  void getSupplierIncomeHistory() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final incomes = await FirebaseFirestore.instance
          .collection('incomes')
          .where('receiver', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();
      incomeDocs = incomes.docs;
      if (incomeDocs.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      List<String> senderUIDs = [];
      for (var income in incomeDocs) {
        final incomeData = income.data() as Map<dynamic, dynamic>;
        senderUIDs.add(incomeData['sender']);
      }
      final senders = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: senderUIDs)
          .get();
      senderDocs = senders.docs;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error getting supplier income history: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        Navigator.of(context)
            .pushReplacementNamed(NavigatorRoutes.supplierHome);
        return false;
      },
      child: Scaffold(
        appBar: emptyWhiteAppBar(context),
        body: switchedLoadingContainer(
            _isLoading,
            Column(
              children: [
                midnightBGHeaderText(context, label: 'My Income History'),
                _incomeHistoryContainer()
              ],
            )),
      ),
    );
  }

  Widget _incomeHistoryContainer() {
    return all20Pix(
        child: incomeDocs.isNotEmpty
            ? SingleChildScrollView(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: incomeDocs.length,
                    itemBuilder: (context, index) {
                      final incomeData =
                          incomeDocs[index].data() as Map<dynamic, dynamic>;
                      String senderUID = incomeData['sender'];

                      return _incomeEntrywidget(
                          incomeDocs[index],
                          senderDocs
                              .where((sender) => sender.id == senderUID)
                              .first);
                    }),
              )
            : comicNeueText(
                label: 'NO AVAILABLE INCOME REPORTS',
                fontSize: 35,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center));
  }

  Widget _incomeEntrywidget(
      DocumentSnapshot incomeDoc, DocumentSnapshot senderDoc) {
    final senderData = senderDoc.data() as Map<dynamic, dynamic>;
    final profileImageURL = senderData['profileImageURL'];
    final senderFormattedName =
        '${senderData['firstName']} ${senderData['lastName']}';
    final incomeData = incomeDoc.data() as Map<dynamic, dynamic>;
    double receivedAmount = incomeData['receivedAmount'];
    double commission = incomeData['commission'];
    return vertical10Pix(
        child: Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          border: Border.all(color: CustomColors.midnightExtress, width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildProfileImageWidget(
                profileImageURL: profileImageURL, radius: 30),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.55,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  comicNeueText(
                      label: 'Sender: $senderFormattedName',
                      color: CustomColors.midnightExtress,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                  comicNeueText(
                      label:
                          'Receivable Amount: ${receivedAmount.toStringAsFixed(2)}',
                      color: CustomColors.midnightExtress,
                      fontSize: 13),
                  comicNeueText(
                      label:
                          'Platform Commission: ${commission.toStringAsFixed(2)}',
                      color: CustomColors.midnightExtress,
                      fontSize: 13),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}
