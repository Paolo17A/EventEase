import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:flutter/material.dart';

Widget userAuthenticationButton(BuildContext context,
    {required String label, required Function onPress}) {
  return SizedBox(
      width: MediaQuery.of(context).size.width * 0.6,
      child: ElevatedButton(
          onPressed: () => onPress(),
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40))),
          child: comicNeueText(
              label: label,
              textAlign: TextAlign.center,
              color: CustomColors.sweetCorn,
              fontSize: 15,
              fontWeight: FontWeight.bold)));
}

Widget settlePaymentButton(BuildContext context, {required Function onPress}) {
  return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: ElevatedButton(
          onPressed: () => onPress(),
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40))),
          child: comicNeueText(
              label: 'UPLOAD PROOF OF PAYMENT',
              textAlign: TextAlign.center,
              color: CustomColors.sweetCorn,
              fontSize: 20,
              fontWeight: FontWeight.bold)));
}

Widget roundedImageButton(BuildContext context,
    {required String label,
    required String imagePath,
    required Function onPress}) {
  return Column(children: [
    SizedBox(
        width: 100,
        height: 100,
        child: ElevatedButton(
            onPressed: () => onPress(),
            style: ElevatedButton.styleFrom(shape: const CircleBorder()),
            child: Image.asset(imagePath))),
    comicNeueText(
        label: label,
        color: CustomColors.midnightExtress,
        fontSize: 20,
        fontWeight: FontWeight.bold)
  ]);
}
