import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_string_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../utils/custom_containers_widget.dart';
import '../utils/firebase_util.dart';
import '../utils/log_out_util.dart';
import '../utils/navigator_util.dart';
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
    super.didChangeDependencies();
    getClientData();
  }

  void getClientData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final userData = await getCurrentUserData();
      profileImageURL = userData['profileImageURL'];
      formattedName = '${userData['firstName']} ${userData['lastName']}';
      List<dynamic> serviceRequests = userData['serviceRequests'];

      //  Handle unresponded customer requests.
      List<dynamic> serviceRequestsCopy = List.from(serviceRequests);
      for (int i = 0; i < serviceRequestsCopy.length; i++) {
        DateTime dateSent =
            (serviceRequestsCopy[i]['dateSent'] as Timestamp).toDate();
        if (DateTime.now().difference(dateSent).inDays >= 3) {
          String requestingClient = serviceRequestsCopy[i]['requestingClient'];
          final clientData = await getThisUserData(requestingClient);
          String currentEventID = clientData['currentEventID'];
          final eventData = await getThisEvent(currentEventID);
          String serviceOffered = userData['offeredService'];
          final serviceParameter = getServiceParameter(serviceOffered);
          Map<dynamic, dynamic> currentSupplierMap =
              eventData[serviceParameter];
          currentSupplierMap['status'] = '';
          currentSupplierMap['supplier'] = '';
          await FirebaseFirestore.instance
              .collection('events')
              .doc(currentEventID)
              .update({serviceParameter: currentSupplierMap});
          serviceRequests.remove(serviceRequestsCopy[i]);
        }
      }
      if (serviceRequestsCopy.length != serviceRequests.length) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'serviceRequests': serviceRequests});
      }

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
              index: 0, isClient: false, isHomeScreen: true),
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
            onPress: () =>
                Navigator.of(context).pushNamed(NavigatorRoutes.incomeHistory)),
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
              label: 'Customers',
              imagePath: 'assets/images/Customer.png',
              onPress: () => Navigator.of(context)
                  .pushNamed(NavigatorRoutes.currentCustomers)),
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
          onPress: () =>
              Navigator.of(context).pushNamed(NavigatorRoutes.viewFAQs))
    ]);
  }
}
