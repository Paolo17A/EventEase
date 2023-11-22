import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../utils/colors_util.dart';
import 'custom_button_widgets.dart';
import 'custom_styling_widgets.dart';
import 'event_ease_textfield_widget.dart';

Widget loginHeaderWidgets({required String label}) {
  return Column(children: [
    Image.asset('assets/images/Logo.png'),
    comicNeueText(
        label: label,
        textAlign: TextAlign.center,
        color: CustomColors.midnightExtress,
        fontWeight: FontWeight.bold,
        fontSize: 30),
    const Gap(30),
  ]);
}

Widget emailAddress(BuildContext context,
    {required TextEditingController controller}) {
  return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        comicNeueText(
            label: 'Email:',
            color: CustomColors.midnightExtress,
            fontWeight: FontWeight.bold,
            fontSize: 20),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.65,
          height: 40,
          child: EventEaseTextField(
              text: '',
              controller: controller,
              textInputType: TextInputType.emailAddress),
        )
      ]));
}

Widget password(BuildContext context,
    {required TextEditingController controller}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          comicNeueText(
              label: 'Password:',
              color: CustomColors.midnightExtress,
              fontWeight: FontWeight.bold,
              fontSize: 20),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.65,
            height: 40,
            child: EventEaseTextField(
                text: '',
                controller: controller,
                textInputType: TextInputType.visiblePassword),
          )
        ])),
  );
}

Widget confirmPassword(BuildContext context,
    {required TextEditingController controller}) {
  return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        comicNeueText(
            label: 'Confirm\nPassword:',
            color: CustomColors.midnightExtress,
            fontWeight: FontWeight.bold,
            fontSize: 20),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.65,
          height: 40,
          child: EventEaseTextField(
              text: '',
              controller: controller,
              textInputType: TextInputType.visiblePassword),
        )
      ]));
}

Widget forgotPassword({required Function onPress}) {
  return Row(children: [
    TextButton(
        onPressed: () => onPress(),
        child: comicNeueText(
            label: 'Forgot Password?',
            color: CustomColors.midnightExtress,
            fontSize: 20))
  ]);
}

Widget submitButton(BuildContext context,
    {required String label, required Function onPress}) {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: userAuthenticationButton(context,
        label: label, onPress: () => onPress()),
  );
}

Widget dontHaveAccount({required Function onPress}) {
  return TextButton(
      onPressed: () => onPress(),
      child: comicNeueText(label: 'Don\'t have an account?'));
}

Widget labelledTextField(BuildContext context,
    {required String label, required TextEditingController controller}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          comicNeueText(
              label: label,
              color: CustomColors.midnightExtress,
              fontWeight: FontWeight.bold,
              fontSize: 20),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.65,
            height: 40,
            child: EventEaseTextField(
                text: '',
                controller: controller,
                textInputType: TextInputType.text),
          )
        ])),
  );
}

Widget multiLineField(BuildContext context,
    {required String label, required TextEditingController controller}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          comicNeueText(
              label: label,
              color: CustomColors.midnightExtress,
              fontWeight: FontWeight.bold,
              fontSize: 20),
          Gap(5),
          EventEaseTextField(
              text: '',
              controller: controller,
              textInputType: TextInputType.multiline)
        ])),
  );
}

Widget buildProfileImageWidget(
    {required String profileImageURL, double radius = 40}) {
  return Column(children: [
    profileImageURL.isNotEmpty
        ? CircleAvatar(
            radius: radius, backgroundImage: NetworkImage(profileImageURL))
        : CircleAvatar(
            radius: radius,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              size: radius * 1.5,
              color: CustomColors.midnightExtress,
            )),
  ]);
}

Widget myAccountHeader(BuildContext context) {
  return Container(
    width: double.infinity,
    height: MediaQuery.of(context).size.height * 0.1,
    color: Colors.white,
    child: Row(children: [
      all20Pix(
          child: comicNeueText(
              label: 'My Account',
              color: CustomColors.midnightExtress,
              textAlign: TextAlign.center,
              fontSize: 30,
              fontWeight: FontWeight.bold))
    ]),
  );
}

Widget numericalTextField(BuildContext context,
    {required String label,
    required TextEditingController controller,
    required bool hasDecimals}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          comicNeueText(
              label: label,
              color: CustomColors.midnightExtress,
              fontWeight: FontWeight.bold,
              fontSize: 20),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.65,
            height: 40,
            child: EventEaseTextField(
                text: '',
                controller: controller,
                textInputType: TextInputType.numberWithOptions(
                    signed: false, decimal: hasDecimals)),
          )
        ])),
  );
}
