import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_string_util.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../utils/colors_util.dart';
import '../utils/custom_containers_widget.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_padding_widgets.dart';
import '../widgets/custom_styling_widgets.dart';

class SelectedSupplierScreen extends StatefulWidget {
  final String supplierUID;
  SelectedSupplierScreen({super.key, required this.supplierUID});

  @override
  State<SelectedSupplierScreen> createState() => _SelectedSupplierScreenState();
}

class _SelectedSupplierScreenState extends State<SelectedSupplierScreen> {
  bool _isLoading = true;
  String profileImageURL = '';
  String formattedName = '';
  String _location = '';
  String _businessName = '';
  List<dynamic> _portfolioImages = [];
  String _introduction = '';
  double _fixedRate = 0.0;
  int _maxCapacity = 0;
  List<DocumentSnapshot> feedbackHistory = [];
  double averageRating = 0;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getSupplierData();
  }

  void getSupplierData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final userData = await getThisUserData(widget.supplierUID);
      profileImageURL = userData['profileImageURL'];
      formattedName = '${userData['firstName']} ${userData['lastName']}';
      _location = userData['location'];
      _businessName = userData['businessName'];
      _portfolioImages = userData['portfolio'];
      _introduction = userData['introduction'];
      _fixedRate = userData['fixedRate'];
      _maxCapacity = userData['maxCapacity'];
      //feedbackHistory = userData['feedbackHistory'];

      final feedback = await FirebaseFirestore.instance
          .collection('feedbacks')
          .where('receiver', isEqualTo: widget.supplierUID)
          .get();
      feedbackHistory = feedback.docs;
      double sum = 0;
      for (var feedback in feedbackHistory) {
        final feedbackData = feedback.data() as Map<dynamic, dynamic>;
        double rating = feedbackData['rating'];
        sum += rating;
      }
      averageRating = sum / feedbackHistory.length;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting supplier data: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void sendServiceRequest() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      //  edit the service request parameter of the supplier
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.supplierUID)
          .update({
        'serviceRequests': FieldValue.arrayUnion([
          {
            'dateSent': DateTime.now(),
            'requestingClient': FirebaseAuth.instance.currentUser!.uid
          }
        ])
      });

      //  Edit the event document
      final userData = await getCurrentUserData();
      String currentEventID = userData['currentEventID'];
      final supplierData = await getThisUserData(widget.supplierUID);
      String offeredService =
          getServiceParameter(supplierData['offeredService']);
      Map<dynamic, dynamic> serviceMap = {
        'supplier': widget.supplierUID,
        'confirmed': false,
        'status': '',
        'downPaymentTransaction': '',
        'completionPaymentTransaction': ''
      };
      await FirebaseFirestore.instance
          .collection('events')
          .doc(currentEventID)
          .update({offeredService: serviceMap});
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully sent service request')));
      setState(() {
        _isLoading = false;
      });
      //  Pop Selected Supplier Screen and return to View All Suppliers Screen
      navigator.pop();
      //  Pop View All Suppliers Screen and return to Add Service Screen
      navigator.pop();
      //  Refresh the Add Service Screen
      navigator.pushReplacementNamed(NavigatorRoutes.addService);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error sending service request: $error')));
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
                icon: Icon(Icons.arrow_back,
                    color: CustomColors.midnightExtress))),
        body: stackedLoadingContainer(
          context,
          _isLoading,
          SafeArea(
              child: SingleChildScrollView(
            child: Column(
              children: [
                midnightBGHeaderText(context,
                    label: '${formattedName}\'s Profile'),
                all20Pix(
                    child: Column(
                  children: [
                    buildProfileImageWidget(
                        profileImageURL: profileImageURL, radius: 70),
                    _businessNameWidget(),
                    _locationWidget(),
                    _portfolioSelection(),
                    _introductionWidget(),
                    _fixedRateWidget(),
                    _maxCapacityWidget(),
                    _feedback(),
                    Gap(60),
                    ElevatedButton(
                        onPressed: sendServiceRequest,
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30))),
                        child: comicNeueText(
                            label: 'Send Service Request',
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                            color: CustomColors.sweetCorn))
                  ],
                ))
              ],
            ),
          )),
        ));
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

  Widget _locationWidget() {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              comicNeueText(
                  label: 'Location:',
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              comicNeueText(label: _location, fontSize: 18)
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
              comicNeueText(
                  label: 'PHP ${formatPrice(_fixedRate)}', fontSize: 18)
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

  Widget _feedback() {
    return Row(
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          comicNeueText(
              label: 'Rating:',
              color: CustomColors.midnightExtress,
              fontWeight: FontWeight.bold,
              fontSize: 18),
          feedbackHistory.isNotEmpty
              ? Row(
                  children: [
                    staticStarRating(rating: averageRating),
                    comicNeueText(
                        label: averageRating.toString(),
                        color: CustomColors.midnightExtress,
                        fontSize: 18),
                  ],
                )
              : comicNeueText(
                  label: 'No Ratings Yet',
                  color: CustomColors.midnightExtress,
                  fontSize: 18)
        ]),
      ],
    );
  }
}
