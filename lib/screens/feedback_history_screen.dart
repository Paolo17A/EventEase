import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:flutter/material.dart';

import '../utils/navigator_util.dart';
import '../widgets/custom_styling_widgets.dart';

class FeedBackHistoryScreen extends StatefulWidget {
  const FeedBackHistoryScreen({super.key});

  @override
  State<FeedBackHistoryScreen> createState() => _FeedBackHistoryScreenState();
}

class _FeedBackHistoryScreenState extends State<FeedBackHistoryScreen> {
  bool _isLoading = false;
  bool isClient = false;
  List<dynamic> feedbackHistory = [];

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
        appBar: emptyWhiteAppBar(context),
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
        child: feedbackHistory.isNotEmpty
            ? SingleChildScrollView(
                child: ListView.builder(
                    shrinkWrap: false,
                    itemCount: feedbackHistory.length,
                    itemBuilder: (context, index) {
                      return Container();
                    }),
              )
            : comicNeueText(
                label: 'NO FEEDBACK AVAILABLE',
                fontSize: 35,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center));
  }
}
