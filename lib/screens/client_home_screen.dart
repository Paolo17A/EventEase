import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/widgets/app_bottom_navbar_widget.dart';
import 'package:event_ease/widgets/custom_button_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../utils/log_out_util.dart';
import '../utils/navigator_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  bool _isLoading = true;
  String profileImageURL = '';
  String formattedName = '';
  bool hasCurrentEvent = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getClientData();
  }

  void getClientData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final userData = await getCurrentUserData();
      profileImageURL = userData['profileImageURL'];
      formattedName = '${userData['firstName']} ${userData['lastName']}';
      hasCurrentEvent = userData['currentEventID'].toString().isNotEmpty;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting client data: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  //  BUILD WIDGET
  //============================================================================
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showLogOutModal(context);
        return false;
      },
      child: Scaffold(
          appBar: profileAppBar(context,
              profileImageURL: profileImageURL, formattedName: formattedName),
          bottomNavigationBar: bottomNavigationBar(context,
              index: 0,
              isClient: true,
              isHomeScreen: true,
              hasEvent: hasCurrentEvent),
          body: switchedLoadingContainer(
              _isLoading,
              SingleChildScrollView(
                child: Column(
                  children: [
                    whiteBGHeaderText(context, label: 'My Account'),
                    const Gap(50),
                    _actionButtons()
                  ],
                ),
              ))),
    );
  }

  //  COMPONENT WIDGETS
  //============================================================================
  Widget _actionButtons() {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        roundedImageButton(context,
            label: 'Transactions',
            imagePath: 'assets/images/Transactions.png',
            onPress: () => Navigator.of(context)
                .pushNamed(NavigatorRoutes.transactionHistory)),
        roundedImageButton(context,
            label: 'Feedbacks',
            imagePath: 'assets/images/Feedback.png',
            onPress: () => Navigator.of(context)
                .pushNamed(NavigatorRoutes.feedbackHistory))
      ]),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          roundedImageButton(context,
              label: 'Calendar',
              imagePath: 'assets/images/Calendar.png',
              onPress: () {}),
          roundedImageButton(context,
              label: 'Event History',
              imagePath: 'assets/images/Event History.png',
              onPress: () =>
                  Navigator.of(context).pushNamed(NavigatorRoutes.eventHistory))
        ]),
      ),
      roundedImageButton(context,
          label: 'Help Center',
          imagePath: 'assets/images/Help Center.png',
          onPress: () {})
    ]);
  }
}
