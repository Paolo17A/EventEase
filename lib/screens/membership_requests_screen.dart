import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_styling_widgets.dart';

class MembershipRequestsScreen extends StatefulWidget {
  const MembershipRequestsScreen({super.key});

  @override
  State<MembershipRequestsScreen> createState() =>
      _MembershipRequestsScreenState();
}

class _MembershipRequestsScreenState extends State<MembershipRequestsScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> pendingMembershipRequests =
      []; //  From Transactions Collection
  List<DocumentSnapshot> associatedMemberDocs = []; //  From Users Collection

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getMembershipRequests();
  }

  void getMembershipRequests() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final membershipRequests = await FirebaseFirestore.instance
          .collection('transactions')
          .where('transactionType', isEqualTo: 'MEMBERSHIP')
          .where('verified', isEqualTo: false)
          .get();
      pendingMembershipRequests = membershipRequests.docs;
      for (var transactionDoc in pendingMembershipRequests) {
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

  void updateTransactionRequest(
      String transactionID, bool verifiedValue, String userID) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      if (verifiedValue) {
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc(transactionID)
            .update({'verified': verifiedValue, 'dateSettled': DateTime.now()});
      } else {
        //  Reset membership payment value in user's account
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userID)
            .update({'membershipPayment': ''});

        //  Delete the transaction document
        await FirebaseFirestore.instance
            .collection('transactions')
            .doc(transactionID)
            .delete();

        //  Delete the proof of payment
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('transactions')
            .child('membership')
            .child(userID);
        await storageRef.delete();
      }
      getMembershipRequests();
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error updating membership requests: $error')));
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
          SafeArea(
              child: Column(
            children: [
              whiteBGHeaderText(context, label: 'Membership Requests'),
              membershipRequestsContainer()
            ],
          ))),
    );
  }

  Widget membershipRequestsContainer() {
    return all20Pix(
        child: pendingMembershipRequests.isNotEmpty
            ? SingleChildScrollView(
                child: Column(
                children: pendingMembershipRequests.map((request) {
                  final requestData = request.data() as Map<dynamic, dynamic>;
                  DocumentSnapshot memberDoc = associatedMemberDocs
                      .where((member) => member.id == requestData['user'])
                      .first;
                  return _membershipRequestEntry(memberDoc, request);
                }).toList(),
              ))
            : comicNeueText(
                label: 'NO PENDING MEMBERSHIP REQUESTS',
                fontSize: 35,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center));
  }

  Widget _membershipRequestEntry(
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
                                onPressed: () => updateTransactionRequest(
                                    transactionDoc.id, true, memberDoc.id),
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
                                onPressed: () => updateTransactionRequest(
                                    transactionDoc.id, false, memberDoc.id),
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
