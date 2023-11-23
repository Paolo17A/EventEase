import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/app_bottom_navbar_widget.dart';
import 'package:event_ease/widgets/custom_button_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../widgets/custom_styling_widgets.dart';

class ServicesOfferedScreen extends StatefulWidget {
  const ServicesOfferedScreen({super.key});

  @override
  State<ServicesOfferedScreen> createState() => _ServicesOfferedScreenState();
}

class _ServicesOfferedScreenState extends State<ServicesOfferedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: emptyWhiteAppBar(context),
        bottomNavigationBar: bottomNavigationBar(context,
            index: 0, isClient: true, isHomeScreen: false),
        body: SafeArea(
            child: Column(
          children: [
            _eventsOfferedWidget(context),
            Gap(40),
            SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Wrap(
                  alignment: WrapAlignment.center,
                  runAlignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.start,
                  runSpacing: 40,
                  children: [
                    offeredServiceButton(context,
                        label: 'Birthday/Debut',
                        imagePath: 'assets/images/Birthday.png',
                        onPress: () => NavigatorRoutes.eventGeneration(context,
                            eventType: 'Birthday/Debut')),
                    offeredServiceButton(context,
                        label: 'Wedding/Anniversary',
                        imagePath: 'assets/images/Wedding.png',
                        onPress: () => NavigatorRoutes.eventGeneration(context,
                            eventType: 'Wedding/Anniversary')),
                    offeredServiceButton(context,
                        label: 'Family Event',
                        imagePath: 'assets/images/Family Gathering.png',
                        onPress: () => NavigatorRoutes.eventGeneration(context,
                            eventType: 'Family Event')),
                    offeredServiceButton(context,
                        label: 'Baptism/Shower',
                        imagePath: 'assets/images/Baptism.png',
                        onPress: () => NavigatorRoutes.eventGeneration(context,
                            eventType: 'Baptism/Shower')),
                    offeredServiceButton(context,
                        label: 'Seminar/Meeting',
                        imagePath: 'assets/images/Meetings.png',
                        onPress: () => NavigatorRoutes.eventGeneration(context,
                            eventType: 'Seminar/Meeting')),
                    offeredServiceButton(context,
                        label: 'Prom',
                        imagePath: 'assets/images/Prom.png',
                        onPress: () => NavigatorRoutes.eventGeneration(context,
                            eventType: 'Prom')),
                    offeredServiceButton(context,
                        label: 'Christmas/\nNew Year\'s Party',
                        imagePath: 'assets/images/Christmas Party.png',
                        onPress: () => NavigatorRoutes.eventGeneration(context,
                            eventType: 'Christmas/\nNew Year\'s Party')),
                    offeredServiceButton(context,
                        label: 'Dedication',
                        imagePath: 'assets/images/House Blessing.png',
                        onPress: () => NavigatorRoutes.eventGeneration(context,
                            eventType: 'Dedication')),
                    offeredServiceButton(context,
                        label: 'Others',
                        imagePath: 'assets/images/Others.png',
                        onPress: () => NavigatorRoutes.eventGeneration(context,
                            eventType: 'Others')),
                  ],
                )),
          ],
        )));
  }

  Widget _eventsOfferedWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.1,
      color: CustomColors.midnightExtress,
      child: Row(children: [
        all20Pix(
            child: comicNeueText(
                label: 'Events Offered',
                color: CustomColors.sweetCorn,
                textAlign: TextAlign.center,
                fontSize: 30,
                fontWeight: FontWeight.bold))
      ]),
    );
  }
}
