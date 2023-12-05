import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/custom_string_util.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/colors_util.dart';
import '../utils/navigator_util.dart';
import '../widgets/custom_styling_widgets.dart';

class CurrentCustomersScreen extends StatefulWidget {
  const CurrentCustomersScreen({super.key});

  @override
  State<CurrentCustomersScreen> createState() => _CurrentCustomersScreenState();
}

class _CurrentCustomersScreenState extends State<CurrentCustomersScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> pendingCustomers = [];
  List<DocumentSnapshot> eventDocuments = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getAllServiceRequests();
  }

  void getAllServiceRequests() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final userData = await getCurrentUserData();
      List<dynamic> serviceRequests = userData['serviceRequests'];
      print(serviceRequests);
      if (serviceRequests.isEmpty) {
        setState(() {
          pendingCustomers.clear();
          _isLoading = false;
        });
        return;
      }

      //  Get all pending customers (if meron)
      List<dynamic> serviceRequesters = [];
      for (var requester in serviceRequests) {
        serviceRequesters.add(requester['requestingClient']);
      }
      final customers = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: serviceRequesters)
          .get();
      pendingCustomers = customers.docs;

      //  Get all associated events
      List<dynamic> eventIDs = [];
      for (var customer in pendingCustomers) {
        final customerData = customer.data() as Map<dynamic, dynamic>;
        String currentEventID = customerData['currentEventID'];
        eventIDs.add(currentEventID);
      }

      final events = await FirebaseFirestore.instance
          .collection('events')
          .where(FieldPath.documentId, whereIn: eventIDs)
          .get();
      eventDocuments = events.docs;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('Error getting all service requests: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void handleServiceRequest(
      DocumentSnapshot requestingCustomer, bool requestGranted) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      //  Get the event ID from the requesting customer
      final customerData = requestingCustomer.data() as Map<dynamic, dynamic>;
      String customerCurrentEventID = customerData['currentEventID'];

      //  Get the supplier's offered service
      final currentSupplierData = await getCurrentUserData();
      String supplierServiceParameter =
          getServiceParameter(currentSupplierData['offeredService']);

      //  The supplier has granted the service request.
      if (requestGranted) {
        Map<dynamic, dynamic> serviceMap = {
          'supplier': FirebaseAuth.instance.currentUser!.uid,
          'confirmed': true,
          'status': 'PENDING DOWN PAYMENT',
          'downPaymentTransaction': '',
          'completionPaymentTransaction': ''
        };
        //  Set the current supplier as whatever they applied to be
        await FirebaseFirestore.instance
            .collection('events')
            .doc(customerCurrentEventID)
            .update({supplierServiceParameter: serviceMap});

        //  Set the customer as a current client
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'currentClients': FieldValue.arrayUnion([requestingCustomer.id]),
          'currentEvents': FieldValue.arrayUnion([customerCurrentEventID])
        });
      }
      //  The supplier has denied the service request.
      else {
        Map<dynamic, dynamic> serviceMap = {
          'supplier': '',
          'confirmed': false,
          'status': '',
          'downPaymentTransaction': '',
          'completionPaymentTransaction': ''
        };
        //  Unset the current supplier as whatever they applied to be
        await FirebaseFirestore.instance
            .collection('events')
            .doc(customerCurrentEventID)
            .update({supplierServiceParameter: serviceMap});
      }
      //  Remove the requesting customer from the supplier's service request list
      List<dynamic> serviceRequests = currentSupplierData['serviceRequests'];
      serviceRequests.removeWhere(
          (request) => request['requestingClient'] == requestingCustomer.id);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'serviceRequests': serviceRequests});

      //  Refresh the screen's current customer requests.
      getAllServiceRequests();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error handling service request: $error')));
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
              .pushReplacementNamed(NavigatorRoutes.supplierHome);
          return false;
        },
        child: Scaffold(
          appBar: emptyWhiteAppBar(context),
          body: switchedLoadingContainer(
              _isLoading,
              SafeArea(
                  child: Column(
                children: [
                  midnightBGHeaderText(context, label: 'Customers'),
                  _customerContainer()
                ],
              ))),
        ));
  }

  Widget _customerContainer() {
    return all20Pix(
        child: pendingCustomers.isNotEmpty
            ? SingleChildScrollView(
                child: Column(
                children: pendingCustomers.map((customer) {
                  final customerData = customer.data() as Map<dynamic, dynamic>;
                  String currentEventID = customerData['currentEventID'];
                  return _membershipRequestEntry(
                      customer,
                      eventDocuments
                          .where((event) => event.id == currentEventID)
                          .first);
                }).toList(),
              ))
            : comicNeueText(
                label: 'NO PENDING CUSTOMERS',
                fontSize: 35,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center));
  }

  Widget _membershipRequestEntry(
      DocumentSnapshot memberDoc, DocumentSnapshot eventDoc) {
    final memberData = memberDoc.data() as Map<dynamic, dynamic>;
    String profileImageURL = memberData['profileImageURL'];
    String formattedName =
        '${memberData['firstName']} ${memberData['lastName']}';
    final eventData = eventDoc.data() as Map<dynamic, dynamic>;
    String eventType = eventData['eventType'];
    DateTime eventDate = (eventData['eventDate'] as Timestamp).toDate();
    return Padding(
      padding: EdgeInsets.all(5),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(color: CustomColors.midnightExtress),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            buildProfileImageWidget(
                profileImageURL: profileImageURL, radius: 30),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.55,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    comicNeueText(
                        label: formattedName,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 26),
                    comicNeueText(
                        label: eventType, color: Colors.white, fontSize: 20),
                    comicNeueText(
                        label:
                            'Date: ${DateFormat('MMM dd, yyyy').format(eventDate)}',
                        color: Colors.white,
                        fontSize: 20),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 80,
                            child: ElevatedButton(
                                onPressed: () =>
                                    handleServiceRequest(memberDoc, true),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: CustomColors.sweetCorn),
                                child: comicNeueText(
                                    label: 'GRANT',
                                    color: CustomColors.midnightExtress,
                                    fontWeight: FontWeight.bold)),
                          ),
                          SizedBox(
                            width: 80,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: CustomColors.sweetCorn),
                                onPressed: () =>
                                    handleServiceRequest(memberDoc, false),
                                child: comicNeueText(
                                    label: 'DENY',
                                    color: CustomColors.midnightExtress,
                                    fontWeight: FontWeight.bold)),
                          )
                        ])
                  ]),
            )
          ]),
        ),
      ),
    );
  }
}
