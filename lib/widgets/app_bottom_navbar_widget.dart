import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:flutter/material.dart';

Color bottomNavButtonColor = CustomColors.midnightExtress;

void _processPress(int selectedIndex, int currentIndex, BuildContext context) {
  //  Do nothing if we are selecting the same bottom bar
  if (selectedIndex == currentIndex) {
    return;
  }
  switch (selectedIndex) {
    case 0:
      Navigator.pushNamed(context, '/assessment');
      break;
    case 1:
      Navigator.popUntil(context, ModalRoute.withName('/home'));
      break;
    case 2:
      Navigator.pushNamed(context, '/organization');
      break;
    case 3:
      Navigator.pushNamed(context, '/profile');
      break;
  }
}

Widget bottomNavigationBar(BuildContext context, int index, bool isClient) {
  return BottomNavigationBar(
    currentIndex: index,
    selectedFontSize: 0,
    items: [
      //  Self-Assessment
      BottomNavigationBarItem(
          icon: _buildIcon('assets/images/Plan an Event.png', 'Plan An Event'),
          backgroundColor: bottomNavButtonColor,
          label: 'Plan An Event'),
      BottomNavigationBarItem(
          icon: _buildIcon('assets/images/Chats.png', 'Chats'),
          backgroundColor: bottomNavButtonColor,
          label: 'Chats'),
      //  Organizations
      BottomNavigationBarItem(
          icon: _buildIcon('assets/images/My Account.png', 'My Account'),
          backgroundColor: bottomNavButtonColor,
          label: 'My Account'),
    ],
    onTap: (int tappedIndex) {
      //_processPress(tappedIndex, index, context);
    },
  );
}

Widget _buildIcon(String imagePath, String label) {
  return Column(
    children: [
      Image.asset(
        imagePath,
        scale: 30,
      ),
      comicNeueText(label: label, color: CustomColors.sweetCorn)
    ],
  );
}
