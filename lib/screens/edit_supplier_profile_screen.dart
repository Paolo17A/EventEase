import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/colors_util.dart';
import '../utils/custom_string_util.dart';
import '../utils/firebase_util.dart';
import '../widgets/custom_styling_widgets.dart';

class EditSupplierProfileScreen extends StatefulWidget {
  const EditSupplierProfileScreen({super.key});

  @override
  State<EditSupplierProfileScreen> createState() =>
      _EditSupplierProfileScreenState();
}

class _EditSupplierProfileScreenState extends State<EditSupplierProfileScreen> {
  bool _isLoading = true;
  bool _isInitialized = false;
  String profileImageURL = '';
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final businessNameController = TextEditingController();
  List<dynamic> networkPortfolioImages = [];
  final introductionController = TextEditingController();
  final fixedRateController = TextEditingController();
  final maxCapacityController = TextEditingController();
  ImagePicker imagePicker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) getSupplierData();
  }

  void getSupplierData() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final userData = await getCurrentUserData();
      profileImageURL = userData['profileImageURL'];
      firstNameController.text = userData['firstName'];
      lastNameController.text = userData['lastName'];
      businessNameController.text = userData['businessName'];
      networkPortfolioImages = userData['portfolio'];
      introductionController.text = userData['introduction'];
      fixedRateController.text = userData['fixedRate'].toString();
      maxCapacityController.text = userData['maxCapacity'].toString();
      setState(() {
        _isLoading = false;
        _isInitialized = true;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error getting client data: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) {
        return;
      }
      setState(() {
        _isLoading = true;
      });
      //  Handle Profile Image
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profilePics')
          .child(FirebaseAuth.instance.currentUser!.uid);
      final uploadTask = storageRef.putFile(File(pickedFile.path));
      final taskSnapshot = await uploadTask.whenComplete(() {});
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'profileImageURL': downloadURL});
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully changed profile picture.')));
      setState(() {
        profileImageURL = downloadURL;
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error changing profile picture: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future _pickPortfolioImages() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      final pickedFiles = await imagePicker.pickMultiImage();
      if (pickedFiles.isEmpty) {
        return;
      }
      setState(() {
        _isLoading = true;
      });

      //  Handle Portfolio Entries
      List<Map<String, String>> portfolioEntries = [];
      for (var portfolioImage in pickedFiles) {
        String hex = '${generateRandomHexString(6)}.png';
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('portfolios')
            .child(FirebaseAuth.instance.currentUser!.uid)
            .child(hex);
        final uploadTask = storageRef.putFile(File(portfolioImage.path));
        final taskSnapshot = await uploadTask.whenComplete(() {});
        final String downloadURL = await taskSnapshot.ref.getDownloadURL();
        portfolioEntries.add({'name': hex, 'imageURL': downloadURL});
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'portfolio': FieldValue.arrayUnion(portfolioEntries)});

      getSupplierData();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error adding images to portfolio: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removePortfolioNetworkImage(int index) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      setState(() {
        _isLoading = true;
      });
      Navigator.of(context).pop();
      Map<dynamic, dynamic> imageToDelete = networkPortfolioImages[index];
      String imageHex = imageToDelete['name'];
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('portfolios')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child(imageHex);
      await storageRef.delete();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'portfolio': FieldValue.arrayRemove([imageToDelete])
      });
      getSupplierData();
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error removing portfolio image: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void updateSupplierProfile() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        businessNameController.text.isEmpty ||
        introductionController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Please fill up all text fields')));
      return;
    }
    if (double.tryParse(fixedRateController.text) == null ||
        double.parse(fixedRateController.text) <= 0) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content: Text('Please input a valid amount for your fixed price.')));
      return;
    }
    if (int.tryParse(maxCapacityController.text) == null ||
        int.parse(maxCapacityController.text) <= 0) {
      scaffoldMessenger.showSnackBar(const SnackBar(
          content:
              Text('Please input a valid count for your max guest capacity.')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'businessName': businessNameController.text,
        'introduction': introductionController.text,
        'fixedRate': double.parse(fixedRateController.text),
        'maxCapacity': int.parse(maxCapacityController.text),
      });

      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully edited supplier profile.')));
      setState(() {
        _isLoading = false;
      });
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.supplierProfile);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error updating supplier profile: $error')));
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
            .pushReplacementNamed(NavigatorRoutes.supplierProfile);
        return false;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: comicNeueText(
                label: 'Edit Supplier Profile',
                color: CustomColors.sweetCorn,
                fontWeight: FontWeight.bold),
          ),
          body: stackedLoadingContainer(
              context,
              _isLoading,
              SafeArea(
                  child: SingleChildScrollView(
                      child: all20Pix(
                          child: Column(children: [
                _buildProfileImageWidget(),
                labelledTextField(context,
                    label: 'First Name', controller: firstNameController),
                labelledTextField(context,
                    label: 'Last Name', controller: lastNameController),
                labelledTextField(context,
                    label: 'Business\nName:',
                    controller: businessNameController),
                _portfolioSelection(),
                multiLineField(context,
                    label: 'Introduction:', controller: introductionController),
                numericalTextField(context,
                    label: 'Fixed Rate',
                    controller: fixedRateController,
                    hasDecimals: true),
                numericalTextField(context,
                    label: 'Max Guest\nCapacity:',
                    controller: maxCapacityController,
                    hasDecimals: false),
                submitButton(context,
                    label: 'SAVE CHANGES',
                    onPress: () => updateSupplierProfile())
              ]))))),
        ),
      ),
    );
  }

  Widget _buildProfileImageWidget() {
    return Column(children: [
      CircleAvatar(radius: 70, backgroundImage: NetworkImage(profileImageURL)),
      ElevatedButton(
          onPressed: _pickProfileImage,
          child: Text('Change Profile Image',
              textAlign: TextAlign.center, style: buttonSweetCornStyle()))
    ]);
  }

  Widget _portfolioSelection() {
    return Column(children: [
      Row(children: [
        comicNeueText(
            label: 'Current Portfolio:',
            color: CustomColors.midnightExtress,
            fontWeight: FontWeight.bold,
            fontSize: 20)
      ]),
      if (networkPortfolioImages.isNotEmpty)
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          height: 250,
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: networkPortfolioImages.length,
              itemBuilder: (context, index) =>
                  _portfolioNetworkImageWidget(index)),
        ),
      ElevatedButton(
          onPressed: _pickPortfolioImages,
          child: Text('Add Images', style: buttonSweetCornStyle()))
    ]);
  }

  Widget _portfolioNetworkImageWidget(int index) {
    return Column(children: [
      GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      backgroundColor: Colors.black,
                      content: Image.network(
                          networkPortfolioImages[index]!['imageURL']),
                    ));
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              width: 150,
              height: 150,
              decoration:
                  BoxDecoration(border: Border.all(), color: Colors.black),
              child: Image.network(networkPortfolioImages[index]!['imageURL']),
            ),
          )),
      ElevatedButton(
          onPressed: () {
            if (networkPortfolioImages.length == 1) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      'You must have at least one image in your portfolio online.')));
              return;
            }
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      content: SingleChildScrollView(
                        child: Column(children: [
                          comicNeueText(
                              label:
                                  'Are you sure you want to delete this image from your portfolio?',
                              fontWeight: FontWeight.bold,
                              fontSize: 25),
                          Gap(20),
                          ElevatedButton(
                              onPressed: () =>
                                  _removePortfolioNetworkImage(index),
                              child: comicNeueText(label: 'Remove Image'))
                        ]),
                      ),
                    ));
          },
          child: const Icon(Icons.delete, color: Colors.white))
    ]);
  }
}
