import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class RateSelectedUserScreen extends StatefulWidget {
  final bool isClient;
  final DocumentSnapshot feedbackDoc;
  final DocumentSnapshot userDoc;
  final bool isLastToRate;
  const RateSelectedUserScreen(
      {super.key,
      required this.isClient,
      required this.feedbackDoc,
      required this.userDoc,
      required this.isLastToRate});

  @override
  State<RateSelectedUserScreen> createState() => _RateSelectedUserScreenState();
}

class _RateSelectedUserScreenState extends State<RateSelectedUserScreen> {
  bool _isLoading = false;
  double givenRating = 5;
  final feedbackController = TextEditingController();

  void submitFeedback() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('feedbacks')
          .doc(widget.feedbackDoc.id)
          .update({
        'rated': true,
        'rating': givenRating,
        'feedback': feedbackController.text.trim()
      });
      setState(() {
        _isLoading = false;
      });
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully rated this user!')));
      navigator.pop();
      if (widget.isLastToRate) {
        print('LAST TO RATE');
        navigator.pushReplacementNamed(NavigatorRoutes.feedbackHistory);
      } else {
        print('WILL RATE MORE');
        navigator.pushReplacementNamed(NavigatorRoutes.pendingRatings);
      }
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error submitting feedback: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: emptyWhiteAppBar(context),
        body: stackedLoadingContainer(
            context,
            _isLoading,
            SingleChildScrollView(
              child: Column(children: [
                midnightBGHeaderText(context,
                    label:
                        'RATE THIS ${widget.isClient ? 'SUPPLIER' : 'CLIENT'}'),
                ratingFields()
              ]),
            )),
      ),
    );
  }

  Widget ratingFields() {
    return all20Pix(
        child: Column(children: [
      starRating(
          onPress: (newVal) {
            givenRating = newVal;
            print('NEW RATING: $givenRating');
          },
          starSize: 50),
      multiLineField(context,
          label: 'GIVE YOUR FEEDBACK (Optional)',
          controller: feedbackController),
      Gap(40),
      ElevatedButton(
          onPressed: submitFeedback,
          child: all20Pix(
              child: Text('SUBMIT FEEDBACK', style: buttonSweetCornStyle())))
    ]));
  }
}
