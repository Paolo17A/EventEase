import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/widgets/app_bottom_navbar_widget.dart';
import 'package:event_ease/widgets/custom_button_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:event_ease/widgets/event_ease_textfield_widget.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../utils/navigator_util.dart';

class EventGenerationScreen extends StatefulWidget {
  final String eventType;
  const EventGenerationScreen({super.key, required this.eventType});

  @override
  State<EventGenerationScreen> createState() => _EventGenerationScreenState();
}

class _EventGenerationScreenState extends State<EventGenerationScreen> {
  bool _isLoading = false;
  DateTime? _selectedDate;
  final budgetController = TextEditingController();
  final guestController = TextEditingController();

  void selectDateTime() async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
        builder: (context, child) => Theme(
            data: ThemeData().copyWith(
                colorScheme: ColorScheme.fromSeed(
                    seedColor: CustomColors.midnightExtress)),
            child: child!));
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void generateEvent() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      final userData = await getCurrentUserData();
      if (userData['currentEventID'].toString().isEmpty) {
        String eventID = DateTime.now().millisecondsSinceEpoch.toString();
        Map<dynamic, dynamic> emptyServiceMap = {
          'supplier': '',
          'confirmed': false,
          'status': '',
          'downPaymentTransaction': '',
          'completionPaymentTransaction': ''
        };
        await FirebaseFirestore.instance.collection('events').doc(eventID).set({
          'eventType': widget.eventType,
          'eventDate': _selectedDate,
          'clientUID': FirebaseAuth.instance.currentUser!.uid,
          'isFinished': false,
          'isCancelled': false,
          'catering': emptyServiceMap,
          'cosmetologist': emptyServiceMap,
          'guestPlace': emptyServiceMap,
          'host': emptyServiceMap,
          'technician': emptyServiceMap,
          'photographer': emptyServiceMap
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'currentEventID': eventID});
        setState(() {
          _isLoading = false;
        });
      }
      Navigator.of(context).pushReplacementNamed(NavigatorRoutes.addService);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error generating event: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: emptyWhiteAppBar(context, label: widget.eventType),
        bottomNavigationBar: bottomNavigationBar(context,
            index: 0, isClient: true, isHomeScreen: false),
        body: stackedLoadingContainer(
          context,
          _isLoading,
          SingleChildScrollView(
            child: Column(
              children: [_dateSelectionContainer(), _generationModeButtons()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dateSelectionContainer() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.1,
      child: ElevatedButton(
        onPressed: selectDateTime,
        child: comicNeueText(
            label: _selectedDate != null
                ? DateFormat('dd MMM yyyy').format(_selectedDate!)
                : 'Select Date of Event',
            color: CustomColors.sweetCorn,
            fontWeight: FontWeight.bold,
            fontSize: 30),
      ),
    );
  }

  Widget _generationModeButtons() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: all20Pix(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          eventGenerationButton(context, label: 'Generate My Own Event',
              onPress: () {
            if (_selectedDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Please select a date for your event.')));
              return;
            }
            generateEvent();
          }),
          eventGenerationButton(context, label: 'Generate a package based on: ',
              onPress: () {
            if (_selectedDate == null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Please select a date for your event.')));
              return;
            }
            showAutoGenerationModal();
          })
        ],
      )),
    );
  }

  void showAutoGenerationModal() {
    showModalBottomSheet(
        context: context,
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        backgroundColor: Colors.transparent,
        builder: (context) => Wrap(
              children: [
                ListTile(
                    tileColor: CustomColors.midnightExtress,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30))),
                    title: Center(
                      child: comicNeueText(
                          label: 'BUDGET',
                          fontSize: 25,
                          color: CustomColors.sweetCorn,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      showInputBudgetDialog();
                    }),
                ListTile(
                    tileColor: CustomColors.midnightExtress,
                    shape: RoundedRectangleBorder(),
                    title: Center(
                      child: comicNeueText(
                          label: 'NUMBER OF ATTENDEES',
                          textAlign: TextAlign.center,
                          fontSize: 25,
                          color: CustomColors.sweetCorn,
                          fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      showInputGuestsDialog();
                    }),
              ],
            ));
  }

  void showInputBudgetDialog() {
    budgetController.clear();
    showDialog(
        context: context,
        builder: (context) => GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: CustomColors.midnightExtress, width: 2),
                    borderRadius: BorderRadius.circular(10)),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.75,
                        child: comicNeueText(
                            label: 'INPUT YOUR MAX BUDGET',
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      vertical10Pix(
                        child: EventEaseTextField(
                            text: '',
                            controller: budgetController,
                            textInputType:
                                TextInputType.numberWithOptions(decimal: true)),
                      ),
                      Gap(50),
                      ElevatedButton(
                          onPressed: () {
                            if (double.tryParse(budgetController.text) ==
                                    null ||
                                double.parse(budgetController.text) <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      'Please enter a valid amount higher than 0.00')));
                              return;
                            }
                            Navigator.of(context).pop();
                            NavigatorRoutes.generateByBudget(context,
                                eventDate: _selectedDate!,
                                budget: double.parse(budgetController.text),
                                eventType: widget.eventType);
                          },
                          child: all20Pix(
                            child: Text('GENERATE EVENT',
                                style: buttonSweetCornStyle()),
                          ))
                    ],
                  ),
                ),
              ),
            ));
  }

  void showInputGuestsDialog() {
    budgetController.clear();
    showDialog(
        context: context,
        builder: (context) => GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    side: BorderSide(
                        color: CustomColors.midnightExtress, width: 2),
                    borderRadius: BorderRadius.circular(10)),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.3,
                  child: Column(
                    children: [
                      comicNeueText(
                          label: 'INPUT YOUR GUEST COUNT',
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                      vertical10Pix(
                        child: EventEaseTextField(
                            text: '',
                            controller: guestController,
                            textInputType: TextInputType.numberWithOptions(
                                decimal: false)),
                      ),
                      Gap(50),
                      ElevatedButton(
                          onPressed: () {
                            if (int.tryParse(guestController.text) == null ||
                                int.parse(guestController.text) <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                      'Please enter a valid guest count higher than 0')));
                              return;
                            }
                            Navigator.of(context).pop();
                            NavigatorRoutes.generateByGuestCount(context,
                                eventDate: _selectedDate!,
                                guestCount: int.parse(guestController.text),
                                eventType: widget.eventType);
                          },
                          child: all20Pix(
                            child: Text('GENERATE EVENT',
                                style: buttonSweetCornStyle()),
                          ))
                    ],
                  ),
                ),
              ),
            ));
  }
}
