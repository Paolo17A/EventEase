import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/colors_util.dart';
import '../utils/firebase_util.dart';
import '../widgets/custom_styling_widgets.dart';

class PendingRatingsScreen extends StatefulWidget {
  const PendingRatingsScreen({super.key});

  @override
  State<PendingRatingsScreen> createState() => _PendingUserRatingsScreenState();
}

class _PendingUserRatingsScreenState extends State<PendingRatingsScreen> {
  bool _isLoading = false;
  bool isClient = false;
  List<DocumentSnapshot> pendingFeedbackDocs = [];
  List<DocumentSnapshot> associatedUserDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getPendingSuppliers();
  }

  void getPendingSuppliers() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final userData = await getCurrentUserData();
      isClient = userData['userType'] == 'CLIENT';
      final pendingFeedback = await FirebaseFirestore.instance
          .collection('feedbacks')
          .where('rater', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('rated', isEqualTo: false)
          .get();
      pendingFeedbackDocs = pendingFeedback.docs;
      if (pendingFeedbackDocs.isEmpty) {
        navigator.pop();
        navigator.pushReplacementNamed(NavigatorRoutes.feedbackHistory);
        return;
      }

      List<dynamic> userIDs = [];
      for (var feedback in pendingFeedbackDocs) {
        final feedbackData = feedback.data() as Map<dynamic, dynamic>;
        String receiver = feedbackData['receiver'];
        userIDs.add(receiver);
      }

      final users = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: userIDs)
          .get();
      associatedUserDocs = users.docs;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting pending suppliers: $error')));
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
                midnightBGHeaderText(context,
                    label:
                        'PENDING ${isClient ? 'SUPPLIERS' : 'CLIENTS'} TO RATE',
                    fontSize: 23),
                _pendingUsersContainer()
              ],
            ),
          )),
    );
  }

  Widget _pendingUsersContainer() {
    return all20Pix(
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: pendingFeedbackDocs.length,
          itemBuilder: (context, index) {
            final feedbackData =
                pendingFeedbackDocs[index].data() as Map<dynamic, dynamic>;
            String receiver = feedbackData['receiver'];
            DocumentSnapshot userDoc =
                associatedUserDocs.where((user) => user.id == receiver).first;
            return _currentUser(userDoc, pendingFeedbackDocs[index]);
          }),
    );
  }

  Widget _currentUser(DocumentSnapshot userDoc, DocumentSnapshot feedbackDoc) {
    final userData = userDoc.data() as Map<dynamic, dynamic>;
    String formattedName = '${userData['firstName']} ${userData['lastName']}';
    return vertical10Pix(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 120,
        child: ElevatedButton(
            onPressed: () => NavigatorRoutes.rateSelectedUser(context, isClient,
                feedbackDoc: feedbackDoc,
                userDoc: userDoc,
                isLastToRate: pendingFeedbackDocs.length == 1),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(
                    color: CustomColors.midnightExtress, width: 2)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildProfileImageWidget(
                          profileImageURL: userData['profileImageURL']),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      comicNeueText(
                          label: formattedName,
                          color: CustomColors.midnightExtress,
                          fontSize: 23,
                          fontWeight: FontWeight.bold),
                      if (isClient)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            comicNeueText(
                                label: 'SERVICE PROVIDED: ',
                                color: CustomColors.midnightExtress,
                                fontSize: 17),
                            comicNeueText(
                                label: userData['offeredService'],
                                color: CustomColors.midnightExtress,
                                fontSize: 17),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
