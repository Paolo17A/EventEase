import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:flutter/material.dart';

import 'custom_padding_widgets.dart';

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

Widget offeredServiceButton(BuildContext context,
    {required String label,
    required String imagePath,
    required Function onPress}) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.3,
    //height: MediaQuery.of(context).size.height * 0.25,
    child: Column(children: [
      ElevatedButton(
          onPressed: () => onPress(),
          style: ElevatedButton.styleFrom(shape: const CircleBorder()),
          child: Image.asset(imagePath)),
      comicNeueText(
          label: label,
          textAlign: TextAlign.center,
          color: CustomColors.midnightExtress,
          fontSize: 16,
          fontWeight: FontWeight.bold)
    ]),
  );
}

Widget serviceButton(String label, Function onPress) {
  return vertical10Pix(
    child: SizedBox(
      width: 325,
      height: 80,
      child: ElevatedButton(
          onPressed: () => onPress(),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(
                  color: CustomColors.midnightExtress, width: 2)),
          child: comicNeueText(
              label: '* $label',
              color: CustomColors.midnightExtress,
              fontWeight: FontWeight.w900)),
    ),
  );
}

Widget eventGenerationButton(BuildContext context,
    {required String label, required Function onPress}) {
  return SizedBox(
    width: MediaQuery.of(context).size.width * 0.8,
    height: MediaQuery.of(context).size.height * 0.2,
    child: ElevatedButton(
        onPressed: () => onPress(),
        child: comicNeueText(
            label: label,
            textAlign: TextAlign.center,
            color: CustomColors.sweetCorn,
            fontWeight: FontWeight.bold,
            fontSize: 40)),
  );
}
