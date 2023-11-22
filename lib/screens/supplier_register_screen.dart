import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/custom_string_util.dart';
import '../widgets/custom_button_widgets.dart';
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
  final _businessNameController = TextEditingController();
  final List<File?> _portfolioImageFiles = [];
  ImagePicker imagePicker = ImagePicker();
  final _introductionController = TextEditingController();
  final _fixedRateController = TextEditingController();
  final _maxCapacityController = TextEditingController();

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
        'portfolio': [],
        'email': _emailController.text,
        'password': _passwordController.text,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'currentClients': [],
        'currentEvents': [],
        'businessName': _businessNameController.text,
        'feedback': [],
        'profileImageURL': '',
        'introduction': _introductionController.text,
        'fixedRate': double.parse(_fixedRateController.text),
        'maxCapacity': int.parse(_maxCapacityController.text)
      });

      //  Handle Portfolio Entries
      List<Map<String, String>> portfolioEntries = [];
      for (var portfolioImage in _portfolioImageFiles) {
        String hex = '${generateRandomHexString(6)}.png';
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('portfolios')
            .child(FirebaseAuth.instance.currentUser!.uid)
            .child(hex);
        final uploadTask = storageRef.putFile(portfolioImage!);
        final taskSnapshot = await uploadTask.whenComplete(() {});
        final String downloadURL = await taskSnapshot.ref.getDownloadURL();
        portfolioEntries.add({'name': hex, 'imageURL': downloadURL});
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'portfolio': portfolioEntries});

      //  Handle Profile Image
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profilePics')
          .child(FirebaseAuth.instance.currentUser!.uid);
      final uploadTask = storageRef.putFile(_profileImageFile!);
      final taskSnapshot = await uploadTask.whenComplete(() {});
      final String downloadURL = await taskSnapshot.ref.getDownloadURL();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'profileImageURL': downloadURL});
      setState(() {
        _isLoading = false;
      });
      navigator.pushReplacementNamed(NavigatorRoutes.supplierLogin);
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error registering new supplier: $error')));
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
      setState(() {
        _isLoading = true;
      });
      final sameEmail = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _emailController.text.trim())
          .get();
      if (sameEmail.docs.isNotEmpty) {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('This email is already in use.')));
        setState(() {
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _isLoading = false;
        currentRegisterState = RegisterStates.service;
      });
    } else if (currentRegisterState == RegisterStates.service) {
      setState(() {
        currentRegisterState = RegisterStates.profile;
      });
    } else if (currentRegisterState == RegisterStates.profile) {
      if (_businessNameController.text.isEmpty) {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Please provide a business name.')));
        return;
      }
      if (_profileImageFile == null) {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Please upload a profile image.')));
        return;
      }
      if (_portfolioImageFiles.isEmpty) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text('Please upload at least one portfolio image.')));
        return;
      }
      if (_introductionController.text.isEmpty) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content:
                Text('Please provide and introduction to your business.')));
        return;
      }

      if (double.tryParse(_fixedRateController.text) == null ||
          double.parse(_fixedRateController.text) <= 0) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content:
                Text('Please input a valid amount for your fixed price.')));
        return;
      }
      if (int.tryParse(_maxCapacityController.text) == null ||
          int.parse(_maxCapacityController.text) <= 0) {
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text(
                'Please input a valid count for your max guest capacity.')));
        return;
      }
      registerNewUser();
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImageFile = File(pickedFile.path);
      });
    }
  }

  Future _pickPortfolioImages() async {
    final pickedFiles = await imagePicker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        for (var file in pickedFiles) {
          _portfolioImageFiles.add(File(file.path));
        }
      });
    }
  }

  void _removePortfolioImage(int index) {
    setState(() {
      _portfolioImageFiles.removeAt(index);
    });
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
              serviceButton(
                  'CATERING',
                  () => setState(() {
                        _selectedService = 'CATERING';
                        handleNextButton();
                      })),
              serviceButton(
                  'COSMETOLOGIST',
                  () => setState(() {
                        _selectedService = 'COSMETOLOGIST';
                        handleNextButton();
                      })),
              serviceButton(
                  'GUEST\'S PLACE',
                  () => setState(() {
                        _selectedService = 'GUEST\'S PLACE';
                        handleNextButton();
                      })),
              serviceButton(
                  'HOST',
                  () => setState(() {
                        _selectedService = 'HOST';
                        handleNextButton();
                      })),
              serviceButton(
                  'LIGHT AND SOUND TECHNICIAN',
                  () => setState(() {
                        _selectedService = 'LIGHT AND SOUND TECHNICIAN';
                        handleNextButton();
                      })),
              serviceButton(
                  'PHOTOGRAPHER AND VIDEOGRAPHER',
                  () => setState(() {
                        _selectedService = 'PHOTOGRAPHER AND VIDEOGRAPHER';
                        handleNextButton();
                      }))
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
      _selectedServiceWidget(),
      _buildProfileImageWidget(),
      labelledTextField(context,
          label: 'Business\nName:', controller: _businessNameController),
      _portfolioSelection(),
      multiLineField(context,
          label: 'Introduction:', controller: _introductionController),
      numericalTextField(context,
          label: 'Fixed Rate',
          controller: _fixedRateController,
          hasDecimals: true),
      numericalTextField(context,
          label: 'Max Guest\nCapacity:',
          controller: _maxCapacityController,
          hasDecimals: false),
      submitButton(context,
          label: 'FINISH REGISTRATION', onPress: handleNextButton)
    ]);
  }

  Widget _selectedServiceWidget() {
    return all20Pix(
        child: comicNeueText(
            label: 'Applying as:\n$_selectedService', fontSize: 20));
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
              onPressed: () => setState(() {
                    _profileImageFile == null;
                  }),
              child: Text('Remove Selected Image',
                  textAlign: TextAlign.center, style: buttonSweetCornStyle()))
          : ElevatedButton(
              onPressed: _pickImage,
              child: Text('Select Profile Image',
                  textAlign: TextAlign.center, style: buttonSweetCornStyle()))
    ]);
  }

  Widget _portfolioSelection() {
    return all20Pix(
      child: Column(children: [
        Row(children: [
          comicNeueText(
              label: 'Portfolio:',
              color: CustomColors.midnightExtress,
              fontWeight: FontWeight.bold,
              fontSize: 28)
        ]),
        if (_portfolioImageFiles.isNotEmpty)
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: 250,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: _portfolioImageFiles.length,
                itemBuilder: (context, index) => _portfolioImageWidget(index)),
          ),
        ElevatedButton(
            onPressed: _pickPortfolioImages,
            child: Text('Select Images', style: buttonSweetCornStyle()))
      ]),
    );
  }

  Widget _portfolioImageWidget(int index) {
    return Column(children: [
      GestureDetector(
          onTap: () {
            showDialog(
                context: context,
                builder: (context) => AlertDialog(
                      content: Image.file(_portfolioImageFiles[index]!),
                    ));
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              width: 150,
              height: 150,
              decoration:
                  BoxDecoration(border: Border.all(), color: Colors.black),
              child: Image.file(_portfolioImageFiles[index]!),
            ),
          )),
      ElevatedButton(
          onPressed: () => _removePortfolioImage(index),
          child: const Icon(Icons.delete, color: Colors.white))
    ]);
  }
}
