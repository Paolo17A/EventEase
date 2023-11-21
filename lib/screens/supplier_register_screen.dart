import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/custom_miscellaneous_widgets.dart';

class SupplierRegisterScreen extends StatefulWidget {
  const SupplierRegisterScreen({super.key});

  @override
  State<SupplierRegisterScreen> createState() => _SupplierRegisterScreenState();
}

enum RegisterStates { registration, service, profile }

class _SupplierRegisterScreenState extends State<SupplierRegisterScreen> {
  bool _isLoading = false;
  RegisterStates currentRegisterState = RegisterStates.registration;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String _selectedService = '';
  File? _profileImageFile;
  late ImagePicker imagePicker;
  final _businessNameController = TextEditingController();
  final _portfolioController = TextEditingController();
  final _feebackController = TextEditingController();

  void registerNewUser() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'hasPaidMembership': false,
        'proofOfPayment': '',
        'isPremiumSupplier': false,
        'proofOfPremiumPayments': [],
        'userType': 'SUPPLIER',
        'offeredService': _selectedService,
        'portfolioLink': '',
        'email': _emailController.text,
        'password': _passwordController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'currentEvents': [],
        'businessName': _businessNameController.text,
        'profileImageURL': ''
      });

      navigator.pushReplacementNamed(NavigatorRoutes.supplierLogin);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error registering new user: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  void handleNextButton() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (currentRegisterState == RegisterStates.registration) {
      if (_emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _confirmPasswordController.text.isEmpty ||
          _firstNameController.text.isEmpty ||
          _lastNameController.text.isEmpty) {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: (Text('Please fill up all fields'))));
        return;
      }
      if (!_emailController.text.contains('@') ||
          !_emailController.text.contains('.com')) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: (Text('Please enter a valid email address'))));
        return;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: (Text('The passwords do not match.'))));
        return;
      }
      if (_passwordController.text.length < 6) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content:
                (Text('The password must be at least six characters long.'))));
        return;
      }
      final sameEmail = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim())
          .get();
      if (sameEmail.docs.isNotEmpty) {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('This email is already in use.')));
        return;
      }
      setState(() {
        currentRegisterState = RegisterStates.service;
      });
    } else if (currentRegisterState == RegisterStates.service) {
      setState(() {
        currentRegisterState = RegisterStates.profile;
      });
    } else if (currentRegisterState == RegisterStates.profile) {
      registerNewUser();
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentRegisterState == RegisterStates.registration) {
          return true;
        } else {
          setState(() {
            if (currentRegisterState == RegisterStates.service) {
              _selectedService = '';
              currentRegisterState = RegisterStates.registration;
            } else if (currentRegisterState == RegisterStates.profile) {
              currentRegisterState = RegisterStates.service;
            }
          });
          return false;
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
            body: stackedLoadingContainer(
                context,
                _isLoading,
                SingleChildScrollView(
                    child: SafeArea(
                        child:
                            currentRegisterState == RegisterStates.registration
                                ? _registrationWidgets()
                                : currentRegisterState == RegisterStates.service
                                    ? _serviceWidgets()
                                    : _profileWidget())))),
      ),
    );
  }

  Widget _registrationWidgets() {
    return all20Pix(
        child: Column(
      children: [
        loginHeaderWidgets(label: 'Create your supplier account'),
        emailAddress(context, controller: _emailController),
        password(context, controller: _passwordController),
        confirmPassword(context, controller: _confirmPasswordController),
        const Gap(60),
        labelledTextField(context,
            label: 'First\nName: ', controller: _firstNameController),
        labelledTextField(context,
            label: 'Last\nName: ', controller: _lastNameController),
        submitButton(context, label: 'NEXT', onPress: () => handleNextButton()),
      ],
    ));
  }

  Widget _serviceWidgets() {
    return Column(children: [
      Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.1,
        color: CustomColors.midnightExtress,
        child: Center(
          child: comicNeueText(
              label: 'What are you applying for?',
              color: CustomColors.sweetCorn,
              textAlign: TextAlign.center,
              fontSize: 30,
              fontWeight: FontWeight.bold),
        ),
      ),
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              _serviceButton('CATERING'),
              _serviceButton('COSMETOLOGIST'),
              _serviceButton('GUEST\'S PLACE'),
              _serviceButton('HOST'),
              _serviceButton('LIGHT AND SOUND TECHNICIAN'),
              _serviceButton('PHOTOGRAPHER AND VIDEOGRAPHER')
            ],
          ),
        ),
      ),
      comicNeueText(label: 'Please specify upon application', fontSize: 25)
    ]);
  }

  Widget _profileWidget() {
    return Column(children: [
      Container(
        width: double.infinity,
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
      ),
      _buildProfileImageWidget(),
      labelledTextField(context,
          label: 'Business\nName:', controller: _businessNameController),
      portfolioField(context, controller: _portfolioController),
      multiLineField(context, controller: _feebackController)
    ]);
  }

  Widget _serviceButton(String label) {
    return vertical10Pix(
      child: SizedBox(
        width: double.maxFinite,
        height: 80,
        child: ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedService = label;
                handleNextButton();
              });
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(
                    color: CustomColors.midnightExtress, width: 2)),
            child: comicNeueText(
                label: '* $label',
                color: CustomColors.midnightExtress,
                fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _buildProfileImageWidget() {
    return Column(children: [
      _profileImageFile != null
          ? CircleAvatar(
              radius: 70, backgroundImage: FileImage(_profileImageFile!))
          : const CircleAvatar(
              radius: 70,
              backgroundColor: CustomColors.midnightExtress,
              child: Icon(
                Icons.person,
                size: 100,
                color: Colors.white,
              )),
      _profileImageFile != null
          ? ElevatedButton(
              onPressed: () {
                setState(() {
                  _profileImageFile == null;
                });
              },
              child:
                  Text('Remove Selected Image', style: buttonSweetCornStyle()))
          : ElevatedButton(
              onPressed: _pickImage,
              child:
                  Text('Select Business Image', style: buttonSweetCornStyle()))
    ]);
  }
}
