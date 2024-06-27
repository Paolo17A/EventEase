import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../utils/colors_util.dart';
import '../widgets/custom_styling_widgets.dart';

class ViewAvailableSuppliersScreen extends StatefulWidget {
  final String requiredService;
  final DateTime eventDate;
  const ViewAvailableSuppliersScreen(
      {super.key, required this.requiredService, required this.eventDate});

  @override
  State<ViewAvailableSuppliersScreen> createState() =>
      _ViewAvailableSuppliersScreenState();
}

class _ViewAvailableSuppliersScreenState
    extends State<ViewAvailableSuppliersScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> eligibleSuppliers = [];
  List<DocumentSnapshot> availableSuppliers = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getEligibleSuppliers();
  }

  void getEligibleSuppliers() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      //  First we must get all the suppliers offering the required service.
      final suppliers = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'SUPPLIER')
          .where('offeredService', isEqualTo: widget.requiredService)
          .get();
      eligibleSuppliers = suppliers.docs;

      if (eligibleSuppliers.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      //  Iterate through every eligible supplier. A supplier is eligible if they are offering ther desired service
      for (var supplier in eligibleSuppliers) {
        print('CURRENT SUPPLIER: ${supplier.id}');
        //  Get all of the current eligible supplier's associated clients from their currentClients list and serviceRequests list.
        final supplierData = supplier.data() as Map<dynamic, dynamic>;

        //  0. Check if the supplier has paid their membership request.
        String membershipPayment = supplierData['membershipPayment'];
        if (membershipPayment.isEmpty) continue;

        final transaction = await FirebaseFirestore.instance
            .collection('transactions')
            .doc(membershipPayment)
            .get();

        final transactionData = transaction.data() as Map<dynamic, dynamic>;
        bool verified = transactionData['verified'];
        if (!verified) continue;

        //  1. Filter all the supplier's current events.
        List<dynamic> currentEvents = supplierData['currentEvents'];
        if (currentEvents.isNotEmpty) {
          final events = await FirebaseFirestore.instance
              .collection('events')
              .where(FieldPath.documentId, whereIn: currentEvents)
              .get();
          final supplierCurrentEventDocs = events.docs;
          //  Iterate through every current event and search for a match.
          bool hasMatchingDate = false;
          for (var event in supplierCurrentEventDocs) {
            final eventData = event.data();
            DateTime eventDate = (eventData['eventDate'] as Timestamp).toDate();
            //  If there is a matching date, set the hasMatchingDate bool to true and BREAK THE LOOP
            if (isSameDate(eventDate)) {
              hasMatchingDate = true;
              break;
            }
          }
          //  The supplier has a matching date and is therefore unavailable. CONTINUE to the next eligible supplier
          if (hasMatchingDate) {
            continue;
          }
        }

        //  2. Filter the supplier's service requests.
        //  We will only filter the supplier's service requests if there are NO current events that match the current date
        List<dynamic> serviceRequests = supplierData['serviceRequests'];
        print('service requests: $serviceRequests');
        //  The supplier has no service requests, and is therefore available.
        if (serviceRequests.isEmpty) {
          availableSuppliers.add(supplier);
        }
        //  There are existing service requests. We must iterate through each customer's current events to look for a match.
        else {
          List<dynamic> requestingClients = serviceRequests
              .map((serviceRequest) => serviceRequest['requestingClient'])
              .toList();
          final customers = await FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId, whereIn: requestingClients)
              .get();
          print('Has serbice requests');

          //  store all the event IDs in a local list to make the query easier.
          List<dynamic> customerCurrentEventIDs = [];
          final customerDocs = customers.docs;
          for (var customer in customerDocs) {
            final customerData = customer.data();
            if (customerData['currentEventID'].toString().isNotEmpty)
              customerCurrentEventIDs.add(customerData['currentEventID']);
          }
          if (customerCurrentEventIDs.isNotEmpty) {
            final customerCurrentEvents = await FirebaseFirestore.instance
                .collection('events')
                .where(FieldPath.documentId, whereIn: customerCurrentEventIDs)
                .get();
            print('current customer events successfully retrieved');
            final customerCurrentEventDocs = customerCurrentEvents.docs;

            //  Iterate through every current event and search for a match.
            bool hasMatchingDate = false;
            for (var eventDoc in customerCurrentEventDocs) {
              final currentEventData = eventDoc.data();
              DateTime currentEventDate =
                  (currentEventData['eventDate'] as Timestamp).toDate();
              if (isSameDate(currentEventDate)) {
                hasMatchingDate = true;
                break;
              }
            }
            //  There are no matching event dates thus this supplier is available.
            if (!hasMatchingDate) {
              availableSuppliers.add(supplier);
            }
          }
        }
      } //  End of eligible suppliers for loop.
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting eligible suppliers: $error')));
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }
  }

  bool isSameDate(DateTime targetDate) {
    if (widget.eventDate.year == targetDate.year &&
        widget.eventDate.month == targetDate.month &&
        widget.eventDate.day == targetDate.day) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: emptyWhiteAppBar(context, label: widget.requiredService),
      body: switchedLoadingContainer(
          _isLoading,
          SingleChildScrollView(
            child: Column(
              children: [
                _availableSuppliersHeader(),
                _eligibleSuppliersContainer()
              ],
            ),
          )),
    );
  }

  Widget _availableSuppliersHeader() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.1,
      color: CustomColors.midnightExtress,
      child: Center(
        child: comicNeueText(
            label:
                'Available suppliers on ${DateFormat('dd MMM yyy').format(widget.eventDate)}:',
            color: CustomColors.sweetCorn,
            textAlign: TextAlign.center,
            fontSize: 24,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _eligibleSuppliersContainer() {
    return all20Pix(
        child: availableSuppliers.isNotEmpty
            ? SingleChildScrollView(
                child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.8,
                        crossAxisCount: 2),
                    itemCount: availableSuppliers.length,
                    itemBuilder: (context, index) {
                      return _availableSupplierEntry(availableSuppliers[index]);
                    }),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 100),
                child: comicNeueText(
                    label: 'NO ${widget.requiredService} SUPPLIERS VAILABLE',
                    fontWeight: FontWeight.bold,
                    fontSize: 45,
                    textAlign: TextAlign.center),
              ));
  }

  Widget _availableSupplierEntry(DocumentSnapshot supplier) {
    final supplierData = supplier.data() as Map<dynamic, dynamic>;
    String profileImageURL = supplierData['profileImageURL'];
    String formattedName =
        '${supplierData['firstName']} ${supplier['lastName']}';
    String intro = supplierData['introduction'];
    String location = supplierData['location'];
    return ElevatedButton(
        onPressed: () =>
            NavigatorRoutes.selectedSupplier(context, supplierUID: supplier.id),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: buildProfileImageWidget(
                  profileImageURL: profileImageURL, radius: 30),
            ),
            comicNeueText(
                label: formattedName,
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold),
            Gap(10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                comicNeueText(
                    label: intro,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis),
                Gap(6),
                comicNeueText(label: 'Location: $location', color: Colors.white)
              ],
            )
          ],
        ));
  }
}
