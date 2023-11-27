import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../widgets/custom_styling_widgets.dart';

class EventHistoryScreen extends StatefulWidget {
  const EventHistoryScreen({super.key});

  @override
  State<EventHistoryScreen> createState() => _EventHistoryScreenState();
}

class _EventHistoryScreenState extends State<EventHistoryScreen> {
  bool _isLoading = true;
  bool _isClient = false;
  List<DocumentSnapshot> associatedEvents = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAssociatedEvents();
  }

  void getAssociatedEvents() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final userData = await getCurrentUserData();
      _isClient = userData['userType'] == 'CLIENT';

      //  Current user is a client
      if (_isClient) {
        final currentEvents = await FirebaseFirestore.instance
            .collection('events')
            .where('clientUID',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get();
        associatedEvents = currentEvents.docs;
      }
      //  Current user is a supplier
      else {
        List<dynamic> currentEvents = userData['currentEvents'];
        final events = await FirebaseFirestore.instance
            .collection('events')
            .where(FieldPath.documentId, whereIn: currentEvents)
            .get();
        associatedEvents = events.docs;
      }
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting associated events: $error')));
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
              midnightBGHeaderText(context, label: 'My Event History'),
              allEventsContainer()
            ],
          )),
    );
  }

  Widget allEventsContainer() {
    return all20Pix(
        child: associatedEvents.isNotEmpty
            ? SingleChildScrollView(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: associatedEvents.length,
                    itemBuilder: (context, index) =>
                        eventEntry(associatedEvents[index])),
              )
            : comicNeueText(
                label: 'NO EVENTS AVAILABLE',
                fontSize: 35,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center));
  }

  Widget eventEntry(DocumentSnapshot eventDoc) {
    final eventData = eventDoc.data() as Map<dynamic, dynamic>;
    String eventType = eventData['eventType'];
    bool isCancelled = eventData['isCancelled'];
    bool isFinished = eventData['isFinished'];
    Timestamp eventTimeStamp = eventData['eventDate'];
    DateTime eventDate = eventTimeStamp.toDate();
    return vertical10Pix(
        child: Container(
      decoration: BoxDecoration(
          border: Border.all(color: CustomColors.midnightExtress, width: 2)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                comicNeueText(
                    label: eventType,
                    fontWeight: FontWeight.bold,
                    fontSize: 27),
                Gap(15),
                comicNeueText(
                    label:
                        'Status: ${isCancelled ? 'CANCELLED' : isFinished ? 'DONE' : 'ONGOING'}',
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
                comicNeueText(
                    label:
                        'Event Date: ${DateFormat('MMM dd, yyyy').format(eventDate)}',
                    fontWeight: FontWeight.bold,
                    fontSize: 22)
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
