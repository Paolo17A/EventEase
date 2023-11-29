import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:flutter/material.dart';

import '../utils/colors_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_styling_widgets.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({super.key});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  bool _isLoading = true;
  String eventType = '';
  DateTime eventDate = DateTime.now();
  String catering = '';
  String cosmetologist = '';
  String guestPlace = '';
  String host = '';
  String technician = '';
  String photographer = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getCurrentEventData();
  }

  void getCurrentEventData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final userData = await getCurrentUserData();
      final eventData = await getThisEvent(userData['currentEventID']);
      eventType = eventData['eventType'];
      eventDate = (eventData['eventDate'] as Timestamp).toDate();
      catering = eventData['catering']['supplier'];
      cosmetologist = eventData['cosmetologist']['supplier'];
      guestPlace = eventData['guestPlace']['supplier'];
      host = eventData['host']['supplier'];
      technician = eventData['technician']['supplier'];
      photographer = eventData['photographer']['supplier'];
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting current event data: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        Navigator.of(context).pushReplacementNamed(NavigatorRoutes.clientHome);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: comicNeueText(
              label: eventType, color: CustomColors.midnightExtress),
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pushReplacementNamed(NavigatorRoutes.clientHome);
              },
              icon:
                  Icon(Icons.arrow_back, color: CustomColors.midnightExtress)),
        ),
        body: switchedLoadingContainer(
          _isLoading,
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.1,
                  color: CustomColors.midnightExtress,
                  child: Center(
                    child: comicNeueText(
                        label: 'What service would you like to avail?',
                        color: CustomColors.sweetCorn,
                        textAlign: TextAlign.center,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                all20Pix(
                    child: Column(
                  children: [
                    if (catering.isEmpty)
                      serviceButton(
                          'CATERING',
                          () => NavigatorRoutes.viewAvailableSuppliers(context,
                              requiredService: 'CATERING',
                              eventDate: eventDate)),
                    if (cosmetologist.isEmpty)
                      serviceButton(
                          'COSMETOLOGIST',
                          () => NavigatorRoutes.viewAvailableSuppliers(context,
                              requiredService: 'COSMETOLOGIST',
                              eventDate: eventDate)),
                    if (guestPlace.isEmpty)
                      serviceButton(
                          'GUEST\'S PLACE',
                          () => NavigatorRoutes.viewAvailableSuppliers(context,
                              requiredService: 'GUEST\'S PLACE',
                              eventDate: eventDate)),
                    if (host.isEmpty)
                      serviceButton(
                          'HOST',
                          () => NavigatorRoutes.viewAvailableSuppliers(context,
                              requiredService: 'HOST', eventDate: eventDate)),
                    if (technician.isEmpty)
                      serviceButton(
                          'LIGHT AND SOUND TECHNICIAN',
                          () => NavigatorRoutes.viewAvailableSuppliers(context,
                              requiredService: 'LIGHT AND SOUND TECHNICIAN',
                              eventDate: eventDate)),
                    if (photographer.isEmpty)
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
        ),
      ),
    );
  }
}
