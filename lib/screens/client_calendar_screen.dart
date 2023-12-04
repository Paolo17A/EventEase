import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../utils/colors_util.dart';
import '../utils/firebase_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_styling_widgets.dart';

class ClientCalendarScreen extends StatefulWidget {
  const ClientCalendarScreen({super.key});

  @override
  State<ClientCalendarScreen> createState() => _ClientCalendarScreenState();
}

class _ClientCalendarScreenState extends State<ClientCalendarScreen> {
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();
  DateTime _downPaymentDeadline = DateTime.now();
  DateTime _completionPaymentDeadline = DateTime.now();
  DateTime _eventDate = DateTime.now();
  String eventType = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getClientEvent();
  }

  void getClientEvent() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final userData = await getCurrentUserData();
      String currentEventID = userData['currentEventID'];
      final eventData = await getThisEvent(currentEventID);
      _eventDate = (eventData['eventDate'] as Timestamp).toDate();
      _downPaymentDeadline = _eventDate.subtract(Duration(days: 30));
      _completionPaymentDeadline = _eventDate.subtract(Duration(days: 7));
      eventType = eventData['eventType'];
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting your event: $error')));
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
          )),
    );
  }

  Widget _calendarContainer() {
    return all20Pix(
        child: CalendarCarousel(
            height: MediaQuery.of(context).size.height * 0.55,
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
                          : isEventDate(dateTime)
                              ? CustomColors.midnightExtress
                              : isDownPaymentDate(dateTime) ||
                                      isCompletionPaymentDate(dateTime)
                                  ? CustomColors.midnightExtress
                                      .withOpacity(0.75)
                                  : Colors.transparent),
                  child: Center(
                    child: Text(
                      dateTime.day.toString(),
                      style: GoogleFonts.comicNeue(
                          textStyle: TextStyle(
                              decoration: TextDecoration.none,
                              color: isSelectedDay
                                  ? CustomColors.midnightExtress
                                  : isEventDate(dateTime) ||
                                          isDownPaymentDate(dateTime) ||
                                          isCompletionPaymentDate(dateTime)
                                      ? Colors.white
                                      : CustomColors.midnightExtress)),
                    ),
                  ));
            }));
  }

  Widget _eventEntryContainer() {
    return all20Pix(
        child: Row(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              comicNeueText(
                  label: DateFormat('MMM dd, yyyy').format(_selectedDate),
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
              Gap(24),
              if (isEventDate(_selectedDate))
                comicNeueText(label: 'YOUR EVENT:\n$eventType', fontSize: 20)
              else if (isDownPaymentDate(_selectedDate))
                comicNeueText(
                    label: 'DEADLINE FOR SETTLING DOWN PAYMENTS', fontSize: 20)
              else if (isCompletionPaymentDate(_selectedDate))
                comicNeueText(
                    label: 'DEADLINE FOR SETTLING COMPLETION PAYMENTS',
                    fontSize: 20)
              else
                comicNeueText(
                    label: 'NO ASSIGNED PAYMENT DEADLINE FOR THIS DATE')
            ],
          ),
        )
      ],
    ));
  }

  bool isEventDate(DateTime givenDate) {
    if (_eventDate.year == givenDate.year &&
        _eventDate.month == givenDate.month &&
        _eventDate.day == givenDate.day) {
      return true; // Date coincides with an event
    }
    return false; // No matching date found in eventDocs
  }

  bool isDownPaymentDate(DateTime givenDate) {
    if (_downPaymentDeadline.year == givenDate.year &&
        _downPaymentDeadline.month == givenDate.month &&
        _downPaymentDeadline.day == givenDate.day) {
      return true; // Date coincides with an event
    }
    return false; // No matching date found in eventDocs
  }

  bool isCompletionPaymentDate(DateTime givenDate) {
    if (_completionPaymentDeadline.year == givenDate.year &&
        _completionPaymentDeadline.month == givenDate.month &&
        _completionPaymentDeadline.day == givenDate.day) {
      return true; // Date coincides with an event
    }
    return false; // No matching date found in eventDocs
  }
}
