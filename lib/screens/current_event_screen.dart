import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:flutter/material.dart';

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
  }

  void getCurrentEvent() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final userData = await getCurrentUserData();
      final eventData = await getThisEvent(userData['currentEventID']);
      eventType = eventData['eventType'];
      eventDate = eventData['eventDate'];
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
              ElevatedButton(
                  onPressed: () {
                    NavigatorRoutes.selectService(context,
                        eventType: eventType, eventDate: eventDate);
                  },
                  child: comicNeueText(label: 'Edit Event'))
            ],
          )),
    );
  }
}
