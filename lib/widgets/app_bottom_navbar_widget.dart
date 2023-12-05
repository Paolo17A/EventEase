import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:flutter/material.dart';

Color bottomNavButtonColor = CustomColors.midnightExtress;

void _processPress(BuildContext context, selectedIndex, int currentIndex,
    bool isClient, bool hasEvent, bool isHomeScreen) {
  //  Do nothing if we are selecting the same bottom bar
  if (!isHomeScreen && selectedIndex == currentIndex) {
    return;
  }
  switch (selectedIndex) {
    case 0:
      //  Current user is client
      if (isClient) {
        if (hasEvent) {
          Navigator.of(context).pushNamed(NavigatorRoutes.currentEvent);
        } else {
          Navigator.of(context).pushNamed(NavigatorRoutes.servicesOffered);
        }
      }
      //  Current user is supplier
      else {
        Navigator.of(context).pushNamed(NavigatorRoutes.supplierCalendar);
      }
      break;
    case 1:
      Navigator.of(context).pushNamed(NavigatorRoutes.chatThreads);
      break;
    case 2:
      Navigator.pushNamed(
          context,
          isClient
              ? NavigatorRoutes.clientProfile
              : NavigatorRoutes.supplierProfile);
      break;
  }
}

Widget bottomNavigationBar(BuildContext context,
    {required int index,
    required bool isClient,
    bool isHomeScreen = false,
    bool hasEvent = false}) {
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
      _processPress(
          context, tappedIndex, index, isClient, hasEvent, isHomeScreen);
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
