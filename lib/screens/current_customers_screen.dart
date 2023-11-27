import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/custom_string_util.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
      pendingCustomers.clear();
      for (var request in serviceRequests) {
        final customer = await FirebaseFirestore.instance
            .collection('users')
            .doc(request)
            .get();
        pendingCustomers.add(customer);
      }
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
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'serviceRequests': FieldValue.arrayRemove([requestingCustomer.id])
      });

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
                  return _membershipRequestEntry(customer);
                }).toList(),
              ))
            : comicNeueText(
                label: 'NO PENDING CUSTOMERS',
                fontSize: 35,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center));
  }

  Widget _membershipRequestEntry(DocumentSnapshot memberDoc) {
    final memberData = memberDoc.data() as Map<dynamic, dynamic>;
    String profileImageURL = memberData['profileImageURL'];
    String formattedName =
        '${memberData['firstName']} ${memberData['lastName']}';
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
              child: Column(children: [
                comicNeueText(
                    label: formattedName,
                    textAlign: TextAlign.center,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 26),
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
