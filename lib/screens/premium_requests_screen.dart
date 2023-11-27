import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../utils/colors_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_styling_widgets.dart';

class PremiumRequestsScreen extends StatefulWidget {
  const PremiumRequestsScreen({super.key});

  @override
  State<PremiumRequestsScreen> createState() => _PremiumRequestsScreenState();
}

class _PremiumRequestsScreenState extends State<PremiumRequestsScreen> {
  bool _isLoading = true;

  //  From Transactions Collection
  List<DocumentSnapshot> pendingPremiumRequests = [];

  //  From Users Collection
  List<DocumentSnapshot> associatedMemberDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getPremiumRequests();
  }

  void getPremiumRequests() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final premiumRequests = await FirebaseFirestore.instance
          .collection('transactions')
          .where('transactionType', isEqualTo: 'PREMIUM')
          .where('verified', isEqualTo: false)
          .get();
      pendingPremiumRequests = premiumRequests.docs;
      associatedMemberDocs.clear();
      for (var transactionDoc in pendingPremiumRequests) {
        String memberUID = transactionDoc['user'];
        final memberDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(memberUID)
            .get();
        associatedMemberDocs.add(memberDoc);
      }
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting membership requests: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void handlePremiumRequest(DocumentSnapshot transactionDoc,
      DocumentSnapshot supplierDoc, bool isGranted) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      //  The request is granted
      if (isGranted) {
        //  Set the transaction's verified status to true
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc(transactionDoc.id)
            .update({'verified': isGranted, 'dateSettled': DateTime.now()});

        //  Update the supplier's premium status fields
        final supplierData = supplierDoc.data() as Map<dynamic, dynamic>;
        Timestamp currentExpirationDate =
            supplierData['premiumSupplierExpirationDate'];
        DateTime convertedExpirationDate = currentExpirationDate.toDate();
        DateTime newExpirationDate = convertedExpirationDate.year == 1970
            ? DateTime.now().add(Duration(days: 30))
            : convertedExpirationDate.add(Duration(days: 30));
        await FirebaseFirestore.instance
            .collection('users')
            .doc(supplierDoc.id)
            .update({
          'isPremiumSupplier': true,
          'premiumSupplierExpirationDate': newExpirationDate
        });
      }
      //  The request is denied
      else {
        //  Delete the transaction document
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc(transactionDoc.id)
            .delete();

        //  Update the supplier's premium status fields
        await FirebaseFirestore.instance
            .collection('users')
            .doc(supplierDoc.id)
            .update({
          'latestPremiumSupplierPayment': '',
          'premiumSupplierExpirationDate': DateTime(1970)
        });

        //  Delete the proof of payment
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('transactions')
            .child('premium')
            .child(supplierDoc.id);
        await storageRef.delete();
      }

      getPremiumRequests();
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error hanndling premium supplier request: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: emptyWhiteAppBar(context),
      body: switchedLoadingContainer(
          _isLoading,
          SafeArea(
              child: Column(
            children: [
              midnightBGHeaderText(context,
                  label: 'Premium Supplier Requests', fontSize: 28),
              membershipRequestsContainer()
            ],
          ))),
    );
  }

  Widget membershipRequestsContainer() {
    return all20Pix(
        child: pendingPremiumRequests.isNotEmpty
            ? SingleChildScrollView(
                child: Column(
                children: pendingPremiumRequests.map((request) {
                  final requestData = request.data() as Map<dynamic, dynamic>;
                  DocumentSnapshot memberDoc = associatedMemberDocs
                      .where((member) => member.id == requestData['user'])
                      .first;
                  return _premiumRequestEntry(memberDoc, request);
                }).toList(),
              ))
            : comicNeueText(
                label: 'NO PENDING PREMIUM SUPPLIER REQUESTS',
                fontSize: 35,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center));
  }

  Widget _premiumRequestEntry(
      DocumentSnapshot memberDoc, DocumentSnapshot transactionDoc) {
    final memberData = memberDoc.data() as Map<dynamic, dynamic>;
    String profileImageURL = memberData['profileImageURL'];
    String formattedName =
        '${memberData['firstName']} ${memberData['lastName']}';
    final transactionData = transactionDoc.data() as Map<dynamic, dynamic>;
    String proofOfPayment = transactionData['proofOfPayment'];
    return Padding(
      padding: EdgeInsets.all(5),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(color: CustomColors.midnightExtress),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                buildProfileImageWidget(
                    profileImageURL: profileImageURL, radius: 30),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.55,
                  child: Column(children: [
                    comicNeueText(
                        label: formattedName,
                        textAlign: TextAlign.center,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 26),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 80,
                            child: ElevatedButton(
                                onPressed: () => handlePremiumRequest(
                                    transactionDoc, memberDoc, true),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: CustomColors.sweetCorn),
                                child: comicNeueText(
                                    label: 'GRANT',
                                    color: CustomColors.midnightExtress,
                                    fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(
                            width: 80,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: CustomColors.sweetCorn),
                                onPressed: () => handlePremiumRequest(
                                    transactionDoc, memberDoc, false),
                                child: comicNeueText(
                                    label: 'DENY',
                                    color: CustomColors.midnightExtress,
                                    fontWeight: FontWeight.bold)),
                          )
                        ])
                  ]),
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
