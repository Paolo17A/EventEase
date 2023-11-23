import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:flutter/material.dart';

import '../utils/colors_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_styling_widgets.dart';

class SelectServiceScreen extends StatelessWidget {
  final String eventType;
  final DateTime eventDate;
  const SelectServiceScreen(
      {super.key, required this.eventType, required this.eventDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: emptyWhiteAppBar(context, label: eventType),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.1,
              color: CustomColors.midnightExtress,
              child: Center(
                child: comicNeueText(
                    label: 'What service are you looking for?',
                    color: CustomColors.sweetCorn,
                    textAlign: TextAlign.center,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
            ),
            all20Pix(
                child: Column(
              children: [
                serviceButton(
                    'CATERING',
                    () => NavigatorRoutes.viewAvailableSuppliers(context,
                        requiredService: 'CATERING', eventDate: eventDate)),
                serviceButton(
                    'COSMETOLOGIST',
                    () => NavigatorRoutes.viewAvailableSuppliers(context,
                        requiredService: 'COSMETOLOGIST',
                        eventDate: eventDate)),
                serviceButton(
                    'GUEST\'S PLACE',
                    () => NavigatorRoutes.viewAvailableSuppliers(context,
                        requiredService: 'GUEST\'S PLACE',
                        eventDate: eventDate)),
                serviceButton(
                    'HOST',
                    () => NavigatorRoutes.viewAvailableSuppliers(context,
                        requiredService: 'HOST', eventDate: eventDate)),
                serviceButton(
                    'LIGHT AND SOUND TECHNICIAN',
                    () => NavigatorRoutes.viewAvailableSuppliers(context,
                        requiredService: 'LIGHT AND SOUND TECHNICIAN',
                        eventDate: eventDate)),
                serviceButton(
                    'PHOTOGRAPHER AND VIDEOGRAPHER',
                    () => NavigatorRoutes.viewAvailableSuppliers(context,
                        requiredService: 'PHOTOGRAPHER AND VIDEOGRAPHER',
                        eventDate: eventDate))
              ],
            )),
          ],
        ),
      ),
    );
  }
}
