import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/navigator_util.dart';
import '../widgets/custom_styling_widgets.dart';

class FeedBackHistoryScreen extends StatefulWidget {
  const FeedBackHistoryScreen({super.key});

  @override
  State<FeedBackHistoryScreen> createState() => _FeedBackHistoryScreenState();
}

class _FeedBackHistoryScreenState extends State<FeedBackHistoryScreen> {
  bool _isLoading = true;
  bool isClient = false;
  List<DocumentSnapshot> ownFeedbackDocs = [];
  List<DocumentSnapshot> pendingFeedbackDocs = [];
  List<DocumentSnapshot> associatedUserDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getFeedbackHistory();
  }

  void getFeedbackHistory() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final userData = await getCurrentUserData();
      isClient = userData['userType'] == 'CLIENT';

      final ownFeedback = await FirebaseFirestore.instance
          .collection('feedbacks')
          .where('receiver', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('rated', isEqualTo: true)
          .get();
      ownFeedbackDocs = ownFeedback.docs;
      ownFeedbackDocs = ownFeedbackDocs.reversed.toList();

      final pendingFeedback = await FirebaseFirestore.instance
          .collection('feedbacks')
          .where('rater', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .where('rated', isEqualTo: false)
          .get();
      pendingFeedbackDocs = pendingFeedback.docs;

      if (ownFeedbackDocs.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      List<dynamic> userIDs = [];
      for (var feedback in ownFeedbackDocs) {
        final feedbackData = feedback.data() as Map<dynamic, dynamic>;
        String rater = feedbackData['rater'];
        userIDs.add(rater);
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
          SnackBar(content: Text('Error getting feedback history: $error')));
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
        Navigator.of(context).pushReplacementNamed(isClient
            ? NavigatorRoutes.clientHome
            : NavigatorRoutes.supplierHome);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          actions: [
            if (pendingFeedbackDocs.isNotEmpty)
              TextButton(
                  onPressed: () => Navigator.of(context)
                      .pushNamed(NavigatorRoutes.pendingRatings),
                  child: comicNeueText(
                      label: 'RATE MY\n${isClient ? 'SUPPLIERS' : 'CLIENTS'}',
                      fontSize: 10,
                      textAlign: TextAlign.center))
          ],
        ),
        body: switchedLoadingContainer(
            _isLoading,
            SafeArea(
                child: Column(
              children: [
                midnightBGHeaderText(context, label: 'Feedback History'),
                _feedbackHistoryContainer(),
              ],
            ))),
      ),
    );
  }

  Widget _feedbackHistoryContainer() {
    return all20Pix(
        child: ownFeedbackDocs.isNotEmpty
            ? SingleChildScrollView(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: ownFeedbackDocs.length,
                    itemBuilder: (context, index) {
                      final feedbackData = ownFeedbackDocs[index].data()
                          as Map<dynamic, dynamic>;
                      String rater = feedbackData['rater'];
                      DocumentSnapshot thisUser = associatedUserDocs
                          .where((user) => user.id == rater)
                          .first;
                      return _feedbackEntry(thisUser, ownFeedbackDocs[index]);
                    }),
              )
            : comicNeueText(
                label: 'NO FEEDBACK AVAILABLE',
                fontSize: 35,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center));
  }

  Widget _feedbackEntry(
      DocumentSnapshot userDoc, DocumentSnapshot feedbackDoc) {
    final userData = userDoc.data() as Map<dynamic, dynamic>;
    String formattedName = '${userData['firstName']} ${userData['lastName']}';
    final feedbackData = feedbackDoc.data() as Map<dynamic, dynamic>;
    double rating = double.parse(feedbackData['rating'].toString());
    String feedback = feedbackData['feedback'];
    return vertical10Pix(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 120,
        child: Container(
          decoration: BoxDecoration(
              border:
                  Border.all(color: CustomColors.midnightExtress, width: 2)),
          child: Padding(
            padding: const EdgeInsets.all(10),
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
                      staticStarRating(rating: double.parse(rating.toString())),
                      if (feedback.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            comicNeueText(
                                label: 'Feedback: ',
                                color: CustomColors.midnightExtress,
                                fontSize: 17),
                            comicNeueText(
                                label: feedback,
                                color: CustomColors.midnightExtress,
                                fontSize: 14),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
