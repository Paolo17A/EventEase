import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../utils/colors_util.dart';
import 'custom_miscellaneous_widgets.dart';

PreferredSizeWidget profileAppBar(BuildContext context,
    {required String profileImageURL,
    required String formattedName,
    required Function onTap}) {
  return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: CustomColors.midnightExtress,
      toolbarHeight: MediaQuery.of(context).size.height * 0.1,
      title: GestureDetector(
        onTap: () => onTap(),
        child: Row(children: [
          buildProfileImageWidget(profileImageURL: profileImageURL, radius: 30),
          const Gap(20),
          comicNeueText(
              label: formattedName,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 25)
        ]),
      ));
}
