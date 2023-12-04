import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/colors_util.dart';
import '../utils/firebase_util.dart';
import '../widgets/custom_miscellaneous_widgets.dart';
import '../widgets/custom_styling_widgets.dart';

class EditClientProfileScreen extends StatefulWidget {
  const EditClientProfileScreen({super.key});

  @override
  State<EditClientProfileScreen> createState() =>
      _EditClientProfileScreenState();
}

class _EditClientProfileScreenState extends State<EditClientProfileScreen> {
  bool _isLoading = true;
  bool _isInitialized = false;
  String profileImageURL = '';
  ImagePicker imagePicker = ImagePicker();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final locationController = TextEditingController();

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
      locationController.text = userData['location'];
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

  Future<void> _removeProfileImage() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      setState(() {
        _isLoading = true;
      });
      //  Handle Profile Image
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profilePics')
          .child(FirebaseAuth.instance.currentUser!.uid);
      await storageRef.delete();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'profileImageURL': ''});
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully removed profile picture.')));
      setState(() {
        profileImageURL = '';
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

  void updateProfile() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
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
        'location': locationController.text
      });

      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Successfully edited client profile.')));
      setState(() {
        _isLoading = false;
      });
      navigator.pop();
      navigator.pushReplacementNamed(NavigatorRoutes.clientProfile);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error updating client profile: $error')));
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
            .pushReplacementNamed(NavigatorRoutes.clientProfile);
        return false;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            title: comicNeueText(
                label: 'Edit Client Profile',
                color: CustomColors.sweetCorn,
                fontWeight: FontWeight.bold),
          ),
          body: stackedLoadingContainer(
              context,
              _isLoading,
              SingleChildScrollView(
                  child: all20Pix(
                child: Column(
                  children: [
                    _profileImageWidget(),
                    Gap(30),
                    labelledTextField(context,
                        label: 'First Name', controller: firstNameController),
                    labelledTextField(context,
                        label: 'Last Name', controller: lastNameController),
                    labelledTextField(context,
                        label: 'Location', controller: locationController),
                    Gap(60),
                    submitButton(context,
                        label: 'SAVE CHANGES', onPress: updateProfile)
                  ],
                ),
              ))),
        ),
      ),
    );
  }

  Widget _profileImageWidget() {
    return Column(
      children: [
        Container(
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: CustomColors.midnightExtress)),
            child: buildProfileImageWidget(
                profileImageURL: profileImageURL, radius: 50)),
        if (profileImageURL.isNotEmpty)
          Column(
            children: [
              ElevatedButton(
                  onPressed: _removeProfileImage,
                  child: comicNeueText(
                      label: 'REMOVE PROFILE PICTURE',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: CustomColors.sweetCorn)),
              ElevatedButton(
                  onPressed: _pickProfileImage,
                  child: comicNeueText(
                      label: 'CHANGE PROFILE PICTURE',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: CustomColors.sweetCorn))
            ],
          )
        else
          ElevatedButton(
              onPressed: _pickProfileImage,
              child: comicNeueText(
                  label: 'ADD PROFILE PICTURE',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: CustomColors.sweetCorn))
      ],
    );
  }
}
