import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../utils/colors_util.dart';
import 'custom_miscellaneous_widgets.dart';

PreferredSizeWidget profileAppBar(BuildContext context,
    {required String profileImageURL, required String formattedName}) {
  return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: CustomColors.midnightExtress,
      toolbarHeight: MediaQuery.of(context).size.height * 0.1,
      title: Row(children: [
        buildProfileImageWidget(profileImageURL: profileImageURL, radius: 30),
        const Gap(20),
        comicNeueText(
            label: formattedName,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25)
      ]));
}

PreferredSizeWidget emptyWhiteAppBar(BuildContext context, {String? label}) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    title: label != null
        ? comicNeueText(label: label, color: CustomColors.midnightExtress)
        : null,
    leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(Icons.arrow_back, color: CustomColors.midnightExtress)),
  );
}
