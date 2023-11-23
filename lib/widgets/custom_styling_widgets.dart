import 'package:event_ease/utils/colors_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle buttonSweetCornStyle() {
  return GoogleFonts.comicNeue(
      textStyle: const TextStyle(
          color: CustomColors.sweetCorn,
          fontWeight: FontWeight.bold,
          fontSize: 20));
}

Text comicNeueText(
    {required String label,
    TextOverflow? overflow,
    Color? color,
    FontWeight? fontWeight,
    double? fontSize,
    TextAlign? textAlign}) {
  return Text(label,
      textAlign: textAlign,
      style: GoogleFonts.comicNeue(
          textStyle: TextStyle(
              overflow: overflow,
              color: color,
              fontWeight: fontWeight,
              fontSize: fontSize)));
}
