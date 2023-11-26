import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class CurrentEventScreen extends StatefulWidget {
  const CurrentEventScreen({super.key});

  @override
  State<CurrentEventScreen> createState() => _CurrentEventScreenState();
}

class _CurrentEventScreenState extends State<CurrentEventScreen> {
  bool _isLoading = true;
  String eventType = '';
  DateTime eventDate = DateTime(1970);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCurrentEvent();
  }

  void getCurrentEvent() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final userData = await getCurrentUserData();
      final eventData = await getThisEvent(userData['currentEventID']);
      eventType = eventData['eventType'];
      eventDate = (eventData['eventDate'] as Timestamp).toDate();
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error getting current event details: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: emptyWhiteAppBar(context),
      body: switchedLoadingContainer(
          _isLoading,
          Column(
            children: [
              midnightBGHeaderText(context, label: 'Current Event Details'),
              _eventDetailsContainer(),
              Divider(thickness: 2, color: CustomColors.midnightExtress),
              ElevatedButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(NavigatorRoutes.addService),
                  child: comicNeueText(
                      label: 'Edit Event',
                      fontSize: 21,
                      color: CustomColors.sweetCorn,
                      fontWeight: FontWeight.bold))
            ],
          )),
    );
  }

  Widget _eventDetailsContainer() {
    return all20Pix(
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              comicNeueText(
                  label: 'Event: $eventType',
                  color: CustomColors.midnightExtress,
                  fontWeight: FontWeight.bold,
                  fontSize: 26),
              Gap(7),
              comicNeueText(
                  label:
                      'Date: ${DateFormat('MMM dd, yyyy').format(eventDate)}',
                  color: CustomColors.midnightExtress,
                  fontWeight: FontWeight.bold,
                  fontSize: 26),
            ],
          ),
        ],
      ),
    );
  }
}
