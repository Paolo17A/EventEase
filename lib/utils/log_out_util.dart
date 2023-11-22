import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors_util.dart';

void showLogOutModal(BuildContext context) {
  showModalBottomSheet(
      context: context,
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
      backgroundColor: Colors.transparent,
      builder: (context) => Wrap(
            children: [
              ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30))),
                  title: Center(
                    child: comicNeueText(
                        label: 'LOG-OUT',
                        color: CustomColors.midnightExtress,
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();

                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }),
              ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(),
                  title: Center(
                    child: comicNeueText(
                        label: 'EXIT APPLICATION',
                        color: CustomColors.midnightExtress,
                        fontWeight: FontWeight.bold),
                  ),
                  onTap: () => SystemNavigator.pop()),
            ],
          ));
}
