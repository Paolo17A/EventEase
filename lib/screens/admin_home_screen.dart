import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/log_out_util.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:flutter/material.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showLogOutModal(context);
        return false;
      },
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Center(
                child: comicNeueText(
                    label: 'ADMIN PANEL',
                    color: CustomColors.sweetCorn,
                    fontWeight: FontWeight.bold,
                    fontSize: 35)),
          ),
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: all20Pix(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _adminHomeButton(
                    onPress: () => Navigator.of(context)
                        .pushNamed(NavigatorRoutes.membershipRequests),
                    label: 'MEMBERSHIP REQUESTS'),
                _adminHomeButton(
                    onPress: () {}, label: 'PREMIUM RENEWAL REQUESTS'),
                _adminHomeButton(onPress: () {}, label: 'SERVICE TRANSACTIONS'),
                _adminHomeButton(onPress: () {}, label: 'CASH-OUT REQUESTS'),
              ],
            )),
          )),
    );
  }

  Widget _adminHomeButton({required Function onPress, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.85,
        height: 100,
        child: ElevatedButton(
            onPressed: () => onPress(),
            child: Text(label,
                textAlign: TextAlign.center, style: buttonSweetCornStyle())),
      ),
    );
  }
}
