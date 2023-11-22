import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/colors_util.dart';
import '../utils/firebase_util.dart';
import '../widgets/app_bottom_navbar_widget.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_styling_widgets.dart';

class SupplierProfileScreen extends StatefulWidget {
  const SupplierProfileScreen({super.key});

  @override
  State<SupplierProfileScreen> createState() => _SupplierProfileScreenState();
}

class _SupplierProfileScreenState extends State<SupplierProfileScreen> {
  bool _isLoading = true;
  String profileImageURL = '';
  String formattedName = '';
  String _businessName = '';
  List<dynamic> _portfolioImages = [];
  String _introduction = '';
  double _fixedRate = 0.0;
  int _maxCapacity = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getSupplierData();
  }

  void getSupplierData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final userData = await getCurrentUserData();
      profileImageURL = userData['profileImageURL'];
      formattedName = '${userData['firstName']} ${userData['lastName']}';
      _businessName = userData['businessName'];
      _portfolioImages = userData['portfolio'];
      _introduction = userData['introduction'];
      _fixedRate = userData['fixedRate'];
      _maxCapacity = userData['maxCapacity'];
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting client data: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon:
                  Icon(Icons.arrow_back, color: CustomColors.midnightExtress)),
          actions: [IconButton(onPressed: () {}, icon: Icon(Icons.edit))],
        ),
        bottomNavigationBar:
            bottomNavigationBar(context, index: 2, isClient: false),
        body: switchedLoadingContainer(
          _isLoading,
          SafeArea(
              child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _profileWidgets(),
                submitButton(context, label: 'LOG-OUT', onPress: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                })
              ],
            ),
          )),
        ));
  }

  Widget _profileWidgets() {
    return Column(children: [
      _supplierProfileHeaderContainer(),
      all20Pix(
          child: Column(
        children: [
          buildProfileImageWidget(profileImageURL: profileImageURL, radius: 70),
          _formattedNameWidget(),
          _businessNameWidget(),
          _portfolioSelection(),
          _introductionWidget(),
          _fixedRateWidget(),
          _maxCapacityWidget()
        ],
      ))
    ]);
  }

  Widget _supplierProfileHeaderContainer() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.1,
      color: CustomColors.midnightExtress,
      child: Center(
        child: comicNeueText(
            label: 'Supplier\'s Profile',
            color: CustomColors.sweetCorn,
            textAlign: TextAlign.center,
            fontSize: 30,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _formattedNameWidget() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              comicNeueText(
                  label: 'Supplier Name:',
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              comicNeueText(label: formattedName, fontSize: 18)
            ],
          ),
        ),
      ],
    );
  }

  Widget _businessNameWidget() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              comicNeueText(
                  label: 'Business Name:',
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              comicNeueText(label: _businessName, fontSize: 18)
            ],
          ),
        ),
      ],
    );
  }

  Widget _introductionWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          comicNeueText(
              label: 'Introduction:',
              fontSize: 18,
              fontWeight: FontWeight.bold),
          SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: comicNeueText(label: _introduction, fontSize: 18))
        ],
      ),
    );
  }

  Widget _fixedRateWidget() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              comicNeueText(
                  label: 'Fixed Rate:',
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              comicNeueText(label: _fixedRate.toStringAsFixed(2), fontSize: 18)
            ],
          ),
        ),
      ],
    );
  }

  Widget _maxCapacityWidget() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              comicNeueText(
                  label: 'Max Capacity:',
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              comicNeueText(
                  label: '${_maxCapacity.toString()} Guests', fontSize: 18)
            ],
          ),
        ),
      ],
    );
  }

  Widget _portfolioSelection() {
    return Column(children: [
      Row(children: [
        comicNeueText(
            label: 'Portfolio:',
            color: CustomColors.midnightExtress,
            fontWeight: FontWeight.bold,
            fontSize: 18)
      ]),
      if (_portfolioImages.isNotEmpty)
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: 200,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: false,
              itemCount: _portfolioImages.length,
              itemBuilder: (context, index) => _portfolioImageWidget(index)),
        ),
    ]);
  }

  Widget _portfolioImageWidget(int index) {
    return Column(children: [
      GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      backgroundColor: Colors.black,
                      content:
                          Image.network(_portfolioImages[index]!['imageURL']),
                    ));
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              width: 150,
              height: 150,
              decoration:
                  BoxDecoration(border: Border.all(), color: Colors.black),
              child: Image.network(_portfolioImages[index]!['imageURL']),
            ),
          )),
    ]);
  }
}
