import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/colors_util.dart';
import '../widgets/custom_button_widgets.dart';
import '../widgets/custom_styling_widgets.dart';

class EditServiceScreen extends StatefulWidget {
  const EditServiceScreen({super.key});

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
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

  void cancelThisEvent() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      //  Close the alert dialog.
      navigator.pop();
      setState(() {
        _isLoading = true;
      });
      final userData = await getCurrentUserData();
      String currentEventID = userData['currentEventID'];
      final eventData = await getThisEvent(currentEventID);
      String catering = eventData['catering']['supplier'];
      bool cateringConfirmed = eventData['catering']['confirmed'];
      String cosmetologist = eventData['cosmetologist']['supplier'];
      bool cosmetologistConfirmed = eventData['cosmetologist']['confirmed'];
      String guestPlace = eventData['guestPlace']['supplier'];
      bool guestPlaceConfirmed = eventData['guestPlace']['confirmed'];
      String host = eventData['host']['supplier'];
      bool hostConfirmed = eventData['host']['confirmed'];
      String photographer = eventData['photographer']['supplier'];
      bool photographerConfirmed = eventData['photographer']['confirmed'];
      String technician = eventData['technician']['supplier'];
      bool technicianConfirmed = eventData['technician']['confirmed'];

      //  1.  Set the event's isCancelled parameter to true
      await FirebaseFirestore.instance
          .collection('events')
          .doc(currentEventID)
          .update({'isCancelled': true});

      //  2. Set the client's currentEventID parameter to ''
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'currentEventID': ''});

      //  3. remove the client from all associated supplier's currentClients list
      if (catering.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(catering)
            .update({
          cateringConfirmed ? 'currentClients' : 'serviceRequests':
              FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
      }
      if (cosmetologist.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(cosmetologist)
            .update({
          cosmetologistConfirmed ? 'currentClients' : 'serviceRequests':
              FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
      }
      if (guestPlace.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(guestPlace)
            .update({
          guestPlaceConfirmed ? 'currentClients' : 'serviceRequests':
              FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
      }
      if (host.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(host).update({
          hostConfirmed ? 'currentClients' : 'serviceRequests':
              FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
      }
      if (photographer.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(photographer)
            .update({
          photographerConfirmed ? 'currentClients' : 'serviceRequests':
              FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
      }
      if (technician.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(technician)
            .update({
          technicianConfirmed ? 'currentClients' : 'serviceRequests':
              FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
        });
      }

      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully cancelled this event.')));
      //  Return to current event screen
      navigator.pop();
      //  return to home screen.
      navigator.pop();
      //refresh the home screen
      navigator.pushNamed(NavigatorRoutes.clientHome);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error cancelling this event: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        Navigator.of(context)
            .pushReplacementNamed(NavigatorRoutes.currentEvent);
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
                    .pushReplacementNamed(NavigatorRoutes.currentEvent);
              },
              icon:
                  Icon(Icons.arrow_back, color: CustomColors.midnightExtress)),
          actions: [
            TextButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          content: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: comicNeueText(
                                  label:
                                      'Are you sure you want to delete this event? All payments made will not be refunded.',
                                  fontSize: 18)),
                          actions: [
                            ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: comicNeueText(label: 'Go Back')),
                            ElevatedButton(
                                onPressed: cancelThisEvent,
                                child: comicNeueText(label: 'Cancel Event'))
                          ],
                        )),
                child: comicNeueText(
                    label: 'Cancel Event',
                    fontSize: 14,
                    textAlign: TextAlign.center))
          ],
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
