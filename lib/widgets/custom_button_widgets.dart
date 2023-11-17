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
