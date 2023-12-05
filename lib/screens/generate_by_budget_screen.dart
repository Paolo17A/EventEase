import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../utils/custom_string_util.dart';
import '../widgets/custom_styling_widgets.dart';

class GenerateByBudgetScreen extends StatefulWidget {
  final DateTime eventDate;
  final double budget;
  final String eventType;
  final bool hasCatering;
  final bool hasCosmetologist;
  final bool hasGuestPlace;
  final bool hasHost;
  final bool hasPhotographer;
  final bool hasTechnician;
  const GenerateByBudgetScreen({
    super.key,
    required this.eventDate,
    required this.budget,
    required this.eventType,
    required this.hasCatering,
    required this.hasCosmetologist,
    required this.hasGuestPlace,
    required this.hasHost,
    required this.hasPhotographer,
    required this.hasTechnician,
  });

  @override
  State<GenerateByBudgetScreen> createState() => _GenerateByBudgetScreenState();
}

class _GenerateByBudgetScreenState extends State<GenerateByBudgetScreen> {
  bool _isLoading = true;
  List<DocumentSnapshot> eligibleSuppliers = [];
  List<DocumentSnapshot> availableCaterers = [];
  List<DocumentSnapshot> availableCosmetologists = [];
  List<DocumentSnapshot> availableGuestPlaces = [];
  List<DocumentSnapshot> availableHosts = [];
  List<DocumentSnapshot> availableTechnicians = [];
  List<DocumentSnapshot> availablePhotographers = [];
  DocumentSnapshot? randomCaterer;
  DocumentSnapshot? randomCosmetologist;
  DocumentSnapshot? randomGuestPlace;
  DocumentSnapshot? randomHost;
  DocumentSnapshot? randomTechnician;
  DocumentSnapshot? randomPhotographer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getEligibleSuppliers();
  }

  void getEligibleSuppliers() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final suppliers = await FirebaseFirestore.instance
          .collection('users')
          .where('userType', isEqualTo: 'SUPPLIER')
          .get();
      eligibleSuppliers = suppliers.docs;
      print('Eligible suppliers found: ${eligibleSuppliers.length}');
      if (eligibleSuppliers.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (widget.hasCatering)
        availableCaterers = await getAvailableSuppliers('CATERING');
      if (widget.hasCosmetologist)
        availableCosmetologists = await getAvailableSuppliers('COSMETOLOGIST');
      if (widget.hasGuestPlace)
        availableGuestPlaces = await getAvailableSuppliers('GUEST\'S PLACE');
      if (widget.hasHost) availableHosts = await getAvailableSuppliers('HOST');
      if (widget.hasTechnician)
        availableTechnicians =
            await getAvailableSuppliers('LIGHT AND SOUND TECHNICIAN');
      if (widget.hasPhotographer)
        availablePhotographers =
            await getAvailableSuppliers('PHOTOGRAPHER AND VIDEOGRAPHER');

      //  Calculated the allocated budget for each supplier based on which service type is available.
      int splitFactor = 6;
      if (availableCaterers.isEmpty) splitFactor--;
      if (availableCosmetologists.isEmpty) splitFactor--;
      if (availableGuestPlaces.isEmpty) splitFactor;
      if (availableHosts.isEmpty) splitFactor--;
      if (availableTechnicians.isEmpty) splitFactor--;
      if (availablePhotographers.isEmpty) splitFactor--;
      if (splitFactor == 0) splitFactor = 1;
      double allocatedBudget = widget.budget / splitFactor;
      print('ALLOCATED BUDGET: $allocatedBudget');

      availableCaterers = availableCaterers.where((supplier) {
        final supplierData = supplier.data() as Map<dynamic, dynamic>;
        double fixedRate = supplierData['fixedRate'];
        return allocatedBudget >= fixedRate;
      }).toList();
      randomCaterer = availableCaterers.isNotEmpty
          ? availableCaterers[Random().nextInt(availableCaterers.length)]
          : null;
      availableCosmetologists = availableCosmetologists.where((supplier) {
        final supplierData = supplier.data() as Map<dynamic, dynamic>;
        double fixedRate = supplierData['fixedRate'];
        return allocatedBudget >= fixedRate;
      }).toList();
      randomCosmetologist = availableCosmetologists.isNotEmpty
          ? availableCosmetologists[
              Random().nextInt(availableCosmetologists.length)]
          : null;
      availableGuestPlaces = availableGuestPlaces.where((supplier) {
        final supplierData = supplier.data() as Map<dynamic, dynamic>;
        double fixedRate = supplierData['fixedRate'];
        return allocatedBudget >= fixedRate;
      }).toList();
      randomGuestPlace = availableGuestPlaces.isNotEmpty
          ? availableGuestPlaces[Random().nextInt(availableGuestPlaces.length)]
          : null;
      availableHosts = availableHosts.where((supplier) {
        final supplierData = supplier.data() as Map<dynamic, dynamic>;
        double fixedRate = supplierData['fixedRate'];
        return allocatedBudget >= fixedRate;
      }).toList();
      randomHost = availableHosts.isNotEmpty
          ? availableHosts[Random().nextInt(availableHosts.length)]
          : null;
      availableTechnicians = availableTechnicians.where((supplier) {
        final supplierData = supplier.data() as Map<dynamic, dynamic>;
        double fixedRate = supplierData['fixedRate'];
        return allocatedBudget >= fixedRate;
      }).toList();
      randomTechnician = availableTechnicians.isNotEmpty
          ? availableTechnicians[Random().nextInt(availableTechnicians.length)]
          : null;
      availablePhotographers = availablePhotographers.where((supplier) {
        final supplierData = supplier.data() as Map<dynamic, dynamic>;
        double fixedRate = supplierData['fixedRate'];
        return allocatedBudget >= fixedRate;
      }).toList();
      randomPhotographer = availablePhotographers.isNotEmpty
          ? availablePhotographers[
              Random().nextInt(availablePhotographers.length)]
          : null;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting eligible users: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<DocumentSnapshot>> getAvailableSuppliers(
      String requiredService) async {
    try {
      List<DocumentSnapshot> allSuppliers = eligibleSuppliers.where((supplier) {
        final supplierData = supplier.data() as Map<dynamic, dynamic>;
        String offeredService = supplierData['offeredService'];
        return requiredService == offeredService;
      }).toList();
      if (allSuppliers.isEmpty) {
        return List<DocumentSnapshot>.empty();
      }

      List<DocumentSnapshot> availableSuppliers = [];
      for (var supplier in allSuppliers) {
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

        //  The supplier has no service requests, and is therefore available.
        if (serviceRequests.isEmpty) {
          availableSuppliers.add(supplier);
        }
      }
      return availableSuppliers;
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting available caterers: $error')));
      return List<DocumentSnapshot>.empty();
    }
  }

  void generateEventByBudget() async {
    final navigator = Navigator.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      String eventID = DateTime.now().millisecondsSinceEpoch.toString();
      await FirebaseFirestore.instance.collection('events').doc(eventID).set({
        'eventType': widget.eventType,
        'eventDate': widget.eventDate,
        'clientUID': FirebaseAuth.instance.currentUser!.uid,
        'isFinished': false,
        'isCancelled': false,
        'catering': {
          'supplier': randomCaterer != null ? randomCaterer!.id : '',
          'confirmed': false,
          'status': '',
          'downPaymentTransaction': '',
          'completionPaymentTransaction': ''
        },
        'cosmetologist': {
          'supplier':
              randomCosmetologist != null ? randomCosmetologist!.id : '',
          'confirmed': false,
          'status': '',
          'downPaymentTransaction': '',
          'completionPaymentTransaction': ''
        },
        'guestPlace': {
          'supplier': randomGuestPlace != null ? randomGuestPlace!.id : '',
          'confirmed': false,
          'status': '',
          'downPaymentTransaction': '',
          'completionPaymentTransaction': ''
        },
        'host': {
          'supplier': randomHost != null ? randomHost!.id : '',
          'confirmed': false,
          'status': '',
          'downPaymentTransaction': '',
          'completionPaymentTransaction': ''
        },
        'technician': {
          'supplier': randomTechnician != null ? randomTechnician!.id : '',
          'confirmed': false,
          'status': '',
          'downPaymentTransaction': '',
          'completionPaymentTransaction': ''
        },
        'photographer': {
          'supplier': randomPhotographer != null ? randomPhotographer!.id : '',
          'confirmed': false,
          'status': '',
          'downPaymentTransaction': '',
          'completionPaymentTransaction': ''
        }
      });

      //  Set this event as the client's current event
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'currentEventID': eventID});

      //  Send service requests to all associated suppliers
      if (randomCaterer != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(randomCaterer!.id)
            .update({
          'serviceRequests': FieldValue.arrayUnion([
            {
              'dateSent': DateTime.now(),
              'requestingClient': FirebaseAuth.instance.currentUser!.uid
            }
          ])
        });
      }

      if (randomCosmetologist != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(randomCosmetologist!.id)
            .update({
          'serviceRequests': FieldValue.arrayUnion([
            {
              'dateSent': DateTime.now(),
              'requestingClient': FirebaseAuth.instance.currentUser!.uid
            }
          ])
        });
      }

      if (randomGuestPlace != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(randomGuestPlace!.id)
            .update({
          'serviceRequests': FieldValue.arrayUnion([
            {
              'dateSent': DateTime.now(),
              'requestingClient': FirebaseAuth.instance.currentUser!.uid
            }
          ])
        });
      }

      if (randomHost != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(randomHost!.id)
            .update({
          'serviceRequests': FieldValue.arrayUnion([
            {
              'dateSent': DateTime.now(),
              'requestingClient': FirebaseAuth.instance.currentUser!.uid
            }
          ])
        });
      }

      if (randomPhotographer != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(randomPhotographer!.id)
            .update({
          'serviceRequests': FieldValue.arrayUnion([
            {
              'dateSent': DateTime.now(),
              'requestingClient': FirebaseAuth.instance.currentUser!.uid
            }
          ])
        });
      }

      if (randomTechnician != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(randomPhotographer!.id)
            .update({
          'serviceRequests': FieldValue.arrayUnion([
            {
              'dateSent': DateTime.now(),
              'requestingClient': FirebaseAuth.instance.currentUser!.uid
            }
          ])
        });
      }
      //  Go back to event generation screen
      navigator.pop();
      //  Go back to client home screen
      navigator.pop();
      //  Refresh client home screen
      navigator.pushReplacementNamed(NavigatorRoutes.clientHome);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating event: $error')));
      setState(() {
        _isLoading = false;
      });
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

  bool _mayGenerateEvent() {
    bool mayCater = widget.hasCatering && availableCaterers.isNotEmpty;
    bool mayCosmetics =
        widget.hasCosmetologist && availableCosmetologists.isNotEmpty;
    bool mayGuestPlace =
        widget.hasGuestPlace && availableCosmetologists.isNotEmpty;
    bool mayHost = widget.hasHost && availableHosts.isNotEmpty;
    bool mayPhotographer =
        widget.hasPhotographer && availablePhotographers.isNotEmpty;
    bool mayTechnician =
        widget.hasTechnician && availableTechnicians.isNotEmpty;
    return mayCater ||
        mayCosmetics ||
        mayGuestPlace ||
        mayHost ||
        mayPhotographer ||
        mayTechnician;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: emptyWhiteAppBar(context),
      body: switchedLoadingContainer(
          _isLoading,
          Column(
            children: [
              midnightBGHeaderText(context,
                  label: 'Budget: PHP ${formatPrice(widget.budget)}'),
              _generatedSuppliersContainer()
            ],
          )),
    );
  }

  Widget _generatedSuppliersContainer() {
    return vertical10Pix(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: eligibleSuppliers.isNotEmpty
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    if (widget.hasCatering)
                      randomSupplierWidget(context,
                          randomSupplier: randomCaterer,
                          offeredService: 'CATERING'),
                    if (widget.hasCosmetologist)
                      randomSupplierWidget(context,
                          randomSupplier: randomCosmetologist,
                          offeredService: 'COSMETOLOGIST'),
                    if (widget.hasGuestPlace)
                      randomSupplierWidget(context,
                          randomSupplier: randomGuestPlace,
                          offeredService: 'GUEST\'S PLACE'),
                    if (widget.hasHost)
                      randomSupplierWidget(context,
                          randomSupplier: randomTechnician,
                          offeredService: 'HOST'),
                    if (widget.hasPhotographer)
                      randomSupplierWidget(context,
                          randomSupplier: randomPhotographer,
                          offeredService: 'PHOTOGRAPHER AND VIDEOGRAPHER'),
                    if (widget.hasTechnician)
                      randomSupplierWidget(context,
                          randomSupplier: randomHost,
                          offeredService: 'LIGHT AND SOUND TECHNICIAN'),
                    Gap(30),
                    if (_mayGenerateEvent())
                      ElevatedButton(
                          onPressed: generateEventByBudget,
                          child: Text('Generate This Event',
                              style: buttonSweetCornStyle()))
                  ],
                ),
              )
            : comicNeueText(
                label: 'NO ELIGIBLE SUPPLIERS AVAILABLE.',
                fontWeight: FontWeight.bold,
                fontSize: 45,
                textAlign: TextAlign.center),
      ),
    );
  }
}
