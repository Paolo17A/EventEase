import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/app_bottom_navbar_widget.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../utils/firebase_util.dart';

class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key});

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  bool _isLoading = true;
  bool hasEvent = false;
  String profileImageURL = '';
  String formattedName = '';
  String email = '';

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
      email = userData['email'];
      hasEvent = userData['currentEventID'].toString().isNotEmpty;
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed(NavigatorRoutes.clientHome);
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context)
                        .pushReplacementNamed(NavigatorRoutes.clientHome);
                  },
                  icon: Icon(Icons.arrow_back,
                      color: CustomColors.midnightExtress)),
              actions: [
                IconButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamed(NavigatorRoutes.editClientProfile),
                    icon: Icon(Icons.edit, color: CustomColors.midnightExtress))
              ]),
          bottomNavigationBar: bottomNavigationBar(context,
              index: 2, isClient: true, hasEvent: hasEvent),
          body: switchedLoadingContainer(
            _isLoading,
            SafeArea(
                child: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _profileWidgets(),
                    submitButton(context, label: 'LOG-OUT', onPress: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    })
                  ],
                ),
              ),
            )),
          )),
    );
  }

  Widget _profileWidgets() {
    return Column(
      children: [
        midnightBGHeaderText(context, label: 'Client\'s Profile'),
        all20Pix(
            child: Column(children: [
          _profileImageWidget(),
          Gap(30),
          _nameRowWidget(),
          _emailRowWidget(),
        ])),
      ],
    );
  }

  Widget _profileImageWidget() {
    return Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: CustomColors.midnightExtress)),
        child: buildProfileImageWidget(
            profileImageURL: profileImageURL, radius: 70));
  }

  Widget _nameRowWidget() {
    return Row(
      children: [
        comicNeueText(
            label: 'Name: ',
            color: CustomColors.midnightExtress,
            fontWeight: FontWeight.bold,
            fontSize: 18),
        comicNeueText(
            label: formattedName,
            color: CustomColors.midnightExtress,
            fontSize: 18)
      ],
    );
  }

  Widget _emailRowWidget() {
    return Row(
      children: [
        comicNeueText(
            label: 'Email: ',
            color: CustomColors.midnightExtress,
            fontWeight: FontWeight.bold,
            fontSize: 18),
        comicNeueText(
            label: email, color: CustomColors.midnightExtress, fontSize: 18)
      ],
    );
  }
}
