import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/custom_string_util.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

class SupplierCalendarScreen extends StatefulWidget {
  const SupplierCalendarScreen({super.key});

  @override
  State<SupplierCalendarScreen> createState() => _SupplierCalendarScreenState();
}

class _SupplierCalendarScreenState extends State<SupplierCalendarScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> eventDocs = [];
  List<DocumentSnapshot> clientDocs = [];
  DateTime _selectedDate = DateTime.now();
  String offeredServiceParam = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCurrentEvents();
  }

  void getCurrentEvents() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final userData = await getCurrentUserData();
      offeredServiceParam = getServiceParameter(userData['offeredService']);
      List<dynamic> currentEvents = userData['currentEvents'];
      final events = await FirebaseFirestore.instance
          .collection('events')
          .where(FieldPath.documentId, whereIn: currentEvents)
          .get();
      eventDocs = events.docs;
      if (eventDocs.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      eventDocs = eventDocs.where((event) {
        final eventData = event.data() as Map<dynamic, dynamic>;
        bool isCancelled = eventData['isCancelled'];
        return !isCancelled;
      }).toList();

      List<String> associatedClients = [];
      for (var event in eventDocs) {
        final eventData = event.data() as Map<dynamic, dynamic>;
        print(eventData['clientUID']);
        associatedClients.add(eventData['clientUID']);
      }

      final clients = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: associatedClients)
          .get();
      clientDocs = clients.docs;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting current events: $error')));
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
            SingleChildScrollView(
              child: Column(
                children: [
                  midnightBGHeaderText(context, label: 'My Calendar'),
                  _calendarContainer(),
                  _eventEntryContainer()
                ],
              ),
            )));
  }

  Widget _calendarContainer() {
    return all20Pix(
        child: CalendarCarousel(
            height: MediaQuery.of(context).size.height * 0.46,
            width: MediaQuery.of(context).size.width * 0.9,
            showOnlyCurrentMonthDate: true,
            daysHaveCircularBorder: false,
            weekendTextStyle: GoogleFonts.comicNeue(
                textStyle: TextStyle(color: CustomColors.midnightExtress)),
            weekdayTextStyle: GoogleFonts.comicNeue(
                textStyle: TextStyle(color: CustomColors.midnightExtress)),
            daysTextStyle: GoogleFonts.comicNeue(
                textStyle: TextStyle(color: CustomColors.midnightExtress)),
            headerTextStyle: GoogleFonts.comicNeue(
                textStyle: TextStyle(
                    color: CustomColors.midnightExtress,
                    fontWeight: FontWeight.bold,
                    fontSize: 22)),
            todayTextStyle: GoogleFonts.comicNeue(
                textStyle: TextStyle(color: CustomColors.midnightExtress)),
            selectedDayTextStyle: GoogleFonts.comicNeue(
                textStyle: TextStyle(color: CustomColors.midnightExtress)),
            selectedDateTime: _selectedDate,
            todayButtonColor: Colors.transparent,
            selectedDayButtonColor: CustomColors.sweetCorn,
            todayBorderColor: Colors.transparent,
            selectedDayBorderColor: Colors.transparent,
            isScrollable: false,
            onDayPressed: (selectedDate, _) {
              setState(() {
                _selectedDate = selectedDate;
              });
            },
            customDayBuilder: (isSelectable,
                index,
                isSelectedDay,
                isToday,
                isPrevMonthDay,
                textStyle,
                isNextMonthDay,
                isThisMonthDay,
                dateTime) {
              return Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: CustomColors.midnightExtress),
                      color: isSelectedDay
                          ? CustomColors.sweetCorn
                          : doesDateCoincide(dateTime)
                              ? CustomColors.midnightExtress
                              : Colors.transparent),
                  child: Center(
                    child: Text(
                      dateTime.day.toString(),
                      style: GoogleFonts.comicNeue(
                          textStyle: TextStyle(
                              decoration: TextDecoration.none,
                              color: isSelectedDay
                                  ? CustomColors.midnightExtress
                                  : doesDateCoincide(dateTime)
                                      ? Colors.white
                                      : CustomColors.midnightExtress)),
                    ),
                  ));
            }));
  }

  Widget _eventEntryContainer() {
    return doesDateCoincide(_selectedDate)
        ? selectedDateEvent()
        : comicNeueText(label: 'NO ASSIGNED EVENT FOR THIS DATE');
  }

  Widget selectedDateEvent() {
    DocumentSnapshot correspondingEvent = getEventByDate(_selectedDate)!;
    final eventData = correspondingEvent.data() as Map<dynamic, dynamic>;
    String clientID = eventData['clientUID'];
    DocumentSnapshot correspondingClientDoc =
        clientDocs.where((element) => element.id == clientID).first;
    final clientData = correspondingClientDoc.data() as Map<dynamic, dynamic>;
    String formattedName =
        '${clientData['firstName']} ${clientData['lastName']}';
    String status = eventData[offeredServiceParam]['status'];
    return all20Pix(
        child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            comicNeueText(
                label: 'EVENT TYPE:\n${eventData['eventType']}',
                fontSize: 25,
                fontWeight: FontWeight.bold),
            Gap(15),
            comicNeueText(
                label: 'CLIENT: $formattedName',
                fontSize: 20,
                fontWeight: FontWeight.bold),
            Gap(15),
            comicNeueText(
                label: 'STATUS:\n$status',
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ],
        ),
      ],
    ));
  }

  bool doesDateCoincide(DateTime givenDate) {
    for (DocumentSnapshot eventDoc in eventDocs) {
      Timestamp eventDateTimestamp =
          eventDoc['eventDate']; // Assuming 'eventDate' is the field name
      DateTime eventDate = eventDateTimestamp.toDate();

      // Check if the given date matches the eventDate
      if (eventDate.year == givenDate.year &&
          eventDate.month == givenDate.month &&
          eventDate.day == givenDate.day) {
        return true; // Date coincides with an event
      }
    }

    return false; // No matching date found in eventDocs
  }

  DocumentSnapshot? getEventByDate(DateTime targetDate) {
    for (DocumentSnapshot eventDoc in eventDocs) {
      Timestamp eventDateTimestamp =
          eventDoc['eventDate']; // Assuming 'eventDate' is the field name
      DateTime eventDate = eventDateTimestamp.toDate();

      // Check if the given date matches the eventDate
      if (eventDate.year == targetDate.year &&
          eventDate.month == targetDate.month &&
          eventDate.day == targetDate.day) {
        return eventDoc; // Return the corresponding DocumentSnapshot
      }
    }

    return null; // No matching date found in eventDocs
  }
}
