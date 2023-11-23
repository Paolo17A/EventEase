import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/profile_app_bar_widget.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: emptyWhiteAppBar(context, label: widget.requiredService),
      body: switchedLoadingContainer(
          _isLoading,
          Column(
            children: [
              _availableSuppliersHeader(),
              _eligibleSuppliersContainer()
            ],
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
        child: eligibleSuppliers.isNotEmpty
            ? Wrap(
                alignment: WrapAlignment.center,
                runAlignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: eligibleSuppliers
                    .map((supplier) => _availableSupplierEntry(supplier))
                    .toList())
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
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      child: ElevatedButton(
          onPressed: () {},
          child: Column(
            children: [
              buildProfileImageWidget(profileImageURL: profileImageURL),
              comicNeueText(
                  label: formattedName,
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
              comicNeueText(
                  label: intro,
                  overflow: TextOverflow.ellipsis,
                  color: Colors.white)
            ],
          )),
    );
  }
}
