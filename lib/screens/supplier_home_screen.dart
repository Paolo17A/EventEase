import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../utils/custom_containers_widget.dart';
import '../utils/firebase_util.dart';
import '../utils/log_out_util.dart';
import '../widgets/app_bottom_navbar_widget.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/profile_app_bar_widget.dart';

class SupplierHomeScreen extends StatefulWidget {
  const SupplierHomeScreen({super.key});

  @override
  State<SupplierHomeScreen> createState() => _SupplierHomeScreenState();
}

class _SupplierHomeScreenState extends State<SupplierHomeScreen> {
  bool _isLoading = true;
  String profileImageURL = '';
  String formattedName = '';

  @override
  void didChangeDependencies() {
    print('chaning');
    super.didChangeDependencies();
    getClientData();
  }

  void getClientData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final userData = await getCurrentUserData();
      profileImageURL = userData['profileImageURL'];
      formattedName = '${userData['firstName']} ${userData['lastName']}';
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
          bottomNavigationBar:
              bottomNavigationBar(context, index: 0, isClient: false),
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
            label: 'Income',
            imagePath: 'assets/images/Transactions.png',
            onPress: () {}),
        roundedImageButton(context,
            label: 'Feedbacks',
            imagePath: 'assets/images/Feedback.png',
            onPress: () {})
      ]),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          roundedImageButton(context,
              label: 'Customers',
              imagePath: 'assets/images/Calendar.png',
              onPress: () {}),
          roundedImageButton(context,
              label: 'Event History',
              imagePath: 'assets/images/Event History.png',
              onPress: () {})
        ]),
      ),
      roundedImageButton(context,
          label: 'Help Center',
          imagePath: 'assets/images/Help Center.png',
          onPress: () {})
    ]);
  }
}
