import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/widgets/custom_miscellaneous_widgets.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/firebase_util.dart';
import '../utils/navigator_util.dart';

class SupplierLoginScreen extends StatefulWidget {
  const SupplierLoginScreen({super.key});

  @override
  State<SupplierLoginScreen> createState() => _SupplierLoginScreenState();
}

class _SupplierLoginScreenState extends State<SupplierLoginScreen> {
  bool _isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  void loginSupplier() async {
    FocusScope.of(context).unfocus();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Please fill up all provided fields.')));
      return;
    }
    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      final userData = await getCurrentUserData();
      if (userData['userType'] != 'SUPPLIER') {
        if (userData['userType'] == 'ADMIN') {
          setState(() {
            _isLoading = false;
          });
          Navigator.of(context).pushNamed(NavigatorRoutes.adminHome);
          return;
        }
        scaffoldMessenger.showSnackBar(const SnackBar(
            content: Text('This log-in is for suppliers only.')));
        setState(() {
          _isLoading = false;
        });
        return;
      }
      String membershipPayment = userData['membershipPayment'];
      if (membershipPayment.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        navigator.pushNamed(NavigatorRoutes.settleMembershipFee);
        return;
      }

      final transaction = await getThisTransaction(membershipPayment);
      bool isVerified = transaction['verified'];
      if (isVerified) {
        navigator.pushNamed(NavigatorRoutes.supplierHome);
      } else {
        await FirebaseAuth.instance.signOut();
        setState(() {
          _isLoading = false;
        });
        scaffoldMessenger.showSnackBar(SnackBar(
            content:
                Text('Your payment has not yet been verified by the admin.')));

        return;
      }
    } catch (error) {
      scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Error logging in client: $error')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: stackedLoadingContainer(
            context,
            _isLoading,
            SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: all20Pix(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    loginHeaderWidgets(
                        label: 'Sign in to your supplier account'),
                    emailAddress(context, controller: emailController),
                    password(context, controller: passwordController),
                    forgotPassword(
                        onPress: () => Navigator.of(context)
                            .pushNamed(NavigatorRoutes.forgotPassword)),
                    submitButton(context,
                        label: 'SIGN IN', onPress: () => loginSupplier()),
                    dontHaveAccount(
                        onPress: () => Navigator.of(context)
                            .pushNamed(NavigatorRoutes.supplierRegister)),
                  ],
                )),
              ),
            )),
      ),
    );
  }
}
