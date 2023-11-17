import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../widgets/custom_styling_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
                child: all20Pix(
      child: Column(children: [
        Image.asset('assets/images/Logo First Page.png'),
        const Gap(30),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          color: CustomColors.midnightExtress,
          child: Image.asset('assets/images/Customer(1).png'),
        ),
        _welcomeLoginButton(context,
            label: 'Client',
            onPress: () =>
                Navigator.of(context).pushNamed(NavigatorRoutes.clientLogin)),
        const Gap(20),
        Container(
          width: MediaQuery.of(context).size.width * 0.8,
          color: CustomColors.midnightExtress,
          child: Image.asset('assets/images/Customer(1).png'),
        ),
        _welcomeLoginButton(context,
            label: 'Event Service Provider',
            onPress: () =>
                Navigator.of(context).pushNamed(NavigatorRoutes.supplierLogin))
      ]),
    ))));
  }

  Widget _welcomeLoginButton(BuildContext context,
      {required String label, required Function onPress}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 50,
        child: ElevatedButton(
            onPressed: () => onPress(),
            child: Text(label, style: buttonSweetCornStyle())),
      ),
    );
  }
}
