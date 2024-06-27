import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/colors_util.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_styling_widgets.dart';

class ChatThreadsScreen extends StatefulWidget {
  const ChatThreadsScreen({super.key});

  @override
  State<ChatThreadsScreen> createState() => _ChatThreadsScreenState();
}

class _ChatThreadsScreenState extends State<ChatThreadsScreen> {
  bool _isLoading = true;
  bool _isClient = true;

  //  Client Variables
  DocumentSnapshot? catering;
  String cateringStatus = '';
  DocumentSnapshot? cosmetologist;
  String cosmetologistStatus = '';
  DocumentSnapshot? guestPlace;
  String guestPlaceStatus = '';
  DocumentSnapshot? host;
  String hostStatus = '';
  DocumentSnapshot? photographer;
  String photographerStatus = '';
  DocumentSnapshot? technician;
  String technicianStatus = '';

  //  Supplier Variables
  List<DocumentSnapshot> clientDocs = [];
  List<DocumentSnapshot> eventDocs = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getRequiredUsers();
  }

  void getRequiredUsers() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final userData = await getCurrentUserData();
      _isClient = userData['userType'] == 'CLIENT';
      if (_isClient) {
        final eventID = userData['currentEventID'];
        if (eventID.toString().isEmpty) {
          scaffoldMessenger.showSnackBar(
              SnackBar(content: Text('You have no current event yet.')));
          navigator.pop();
          return;
        }
        final eventData = await getThisEvent(eventID);

        catering = eventData['catering']['confirmed'] == true &&
                eventData['catering']['supplier'].toString().isNotEmpty
            ? await FirebaseFirestore.instance
                .collection('users')
                .doc(eventData['catering']['supplier'])
                .get()
            : null;
        cateringStatus = eventData['catering']['status'];

        cosmetologist = eventData['cosmetologist']['confirmed'] == true &&
                eventData['cosmetologist']['supplier'].toString().isNotEmpty
            ? await FirebaseFirestore.instance
                .collection('users')
                .doc(eventData['cosmetologist']['supplier'])
                .get()
            : null;
        cosmetologistStatus = eventData['cosmetologist']['status'];

        guestPlace = eventData['guestPlace']['confirmed'] == true &&
                eventData['guestPlace']['supplier'].toString().isNotEmpty
            ? await FirebaseFirestore.instance
                .collection('users')
                .doc(eventData['guestPlace']['supplier'])
                .get()
            : null;
        guestPlaceStatus = eventData['guestPlace']['status'];

        host = eventData['host']['confirmed'] == true &&
                eventData['host']['supplier'].toString().isNotEmpty
            ? await FirebaseFirestore.instance
                .collection('users')
                .doc(eventData['host']['supplier'])
                .get()
            : null;
        hostStatus = eventData['host']['status'];

        photographer = eventData['photographer']['confirmed'] == true &&
                eventData['photographer']['supplier'].toString().isNotEmpty
            ? await FirebaseFirestore.instance
                .collection('users')
                .doc(eventData['photographer']['supplier'])
                .get()
            : null;
        photographerStatus = eventData['photographer']['status'];

        technician = eventData['technician']['confirmed'] == true &&
                eventData['technician']['supplier'].toString().isNotEmpty
            ? await FirebaseFirestore.instance
                .collection('users')
                .doc(eventData['technician']['supplier'])
                .get()
            : null;
        technicianStatus = eventData['technician']['status'];
      } else {
        List<dynamic> currentClients = userData['currentClients'];
        final clients = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: currentClients)
            .get();
        clientDocs = clients.docs;
        /*clientDocs = clientDocs.where((client) {
          final clientData = client.data() as Map<dynamic, dynamic>;
          String currentEventID = clientData['currentEventID'];
          return currentEventID.isNotEmpty;
        }).toList();*/

        if (clientDocs.isNotEmpty) {
          List<dynamic> associatedEvents = [];
          for (var client in clientDocs) {
            final clientData = client.data() as Map<dynamic, dynamic>;
            String currentEventID = clientData['currentEventID'];
            associatedEvents.add(currentEventID);
          }
          final events = await FirebaseFirestore.instance
              .collection('events')
              .where(FieldPath.documentId, whereIn: associatedEvents)
              .get();
          eventDocs = events.docs;
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting chat users: $error')));
      navigator.pop();
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
                  midnightBGHeaderText(context, label: 'MESSAGES'),
                  _isClient
                      ? _currentSuppliersContainer()
                      : _currentClientsContainer()
                ],
              ),
            )));
  }

  Widget _currentSuppliersContainer() {
    if (catering == null &&
        cosmetologist == null &&
        guestPlace == null &&
        host == null &&
        photographer == null &&
        technician == null) {
      return comicNeueText(
          label: 'YOU HAVE NO CONFIRMED SUPPLIERS YET',
          textAlign: TextAlign.center,
          fontWeight: FontWeight.bold,
          fontSize: 38,
          color: CustomColors.midnightExtress);
    } else {
      return Column(children: [
        if (catering != null) _currentSupplier(catering!),
        if (cosmetologist != null) _currentSupplier(cosmetologist!),
        if (guestPlace != null) _currentSupplier(guestPlace!),
        if (host != null) _currentSupplier(host!),
        if (photographer != null) _currentSupplier(photographer!),
        if (technician != null) _currentSupplier(technician!),
      ]);
    }
  }

  Widget _currentClientsContainer() {
    return all20Pix(
        child: clientDocs.isNotEmpty
            ? SingleChildScrollView(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: clientDocs.length,
                    itemBuilder: (context, index) {
                      final clientData =
                          clientDocs[index].data() as Map<dynamic, dynamic>;
                      String currentEventID = clientData['currentEventID'];
                      DocumentSnapshot thisEvent = eventDocs
                          .where((event) => event.id == currentEventID)
                          .first;
                      return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: 120,
                          child: _currentClient(clientDocs[index], thisEvent));
                    }),
              )
            : comicNeueText(
                label: 'YOU HAVE NO CLIENTS YET',
                textAlign: TextAlign.center,
                fontWeight: FontWeight.bold,
                fontSize: 38,
                color: CustomColors.midnightExtress));
  }

  Widget _currentSupplier(DocumentSnapshot supplierDoc) {
    final supplierData = supplierDoc.data() as Map<dynamic, dynamic>;
    String formattedName =
        '${supplierData['firstName']} ${supplierData['lastName']}';
    return vertical10Pix(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 120,
        child: ElevatedButton(
            onPressed: () =>
                NavigatorRoutes.chat(context, otherPersonUID: supplierDoc.id),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(
                    color: CustomColors.midnightExtress, width: 2)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildProfileImageWidget(
                          profileImageURL: supplierData['profileImageURL']),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      comicNeueText(
                          label: formattedName,
                          color: CustomColors.midnightExtress,
                          fontSize: 23,
                          fontWeight: FontWeight.bold),
                      comicNeueText(
                          label: supplierData['offeredService'],
                          color: CustomColors.midnightExtress,
                          fontSize: 18),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }

  Widget _currentClient(DocumentSnapshot clientDoc, DocumentSnapshot eventDoc) {
    final supplierData = clientDoc.data() as Map<dynamic, dynamic>;
    String formattedName =
        '${supplierData['firstName']} ${supplierData['lastName']}';
    final eventData = eventDoc.data() as Map<dynamic, dynamic>;
    DateTime eventDate = (eventData['eventDate'] as Timestamp).toDate();
    String eventType = eventData['eventType'];
    return vertical10Pix(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: 120,
        child: ElevatedButton(
            onPressed: () =>
                NavigatorRoutes.chat(context, otherPersonUID: clientDoc.id),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(
                    color: CustomColors.midnightExtress, width: 2)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      buildProfileImageWidget(
                          profileImageURL: supplierData['profileImageURL']),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        comicNeueText(
                            label: formattedName,
                            color: CustomColors.midnightExtress,
                            fontSize: 23,
                            fontWeight: FontWeight.bold),
                        comicNeueText(
                            label:
                                'Event Date: ${DateFormat('MMM dd, yyyy').format(eventDate)}',
                            color: CustomColors.midnightExtress,
                            fontSize: 15),
                        comicNeueText(
                            label: 'Event Type: $eventType',
                            color: CustomColors.midnightExtress,
                            fontSize: 15),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
