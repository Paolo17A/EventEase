import 'package:event_ease/utils/custom_containers_widget.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/utils/navigator_util.dart';
import 'package:event_ease/widgets/custom_padding_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../widgets/custom_miscellaneous_widgets.dart';

class ClientLoginScreen extends StatefulWidget {
  const ClientLoginScreen({super.key});

  @override
  State<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends State<ClientLoginScreen> {
  bool _isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
  }

  void loginClient() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      setState(() {
        _isLoading = true;
      });

      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

      final userData = await getCurrentUserData();
      if (userData['userType'] != 'CLIENT') {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('This log-in is for clients only.')));
        return;
      }
      bool hasPaidMembership = userData['hasPaidMembership'];

      if (hasPaidMembership) {
        navigator.pushNamed(NavigatorRoutes.clientHome);
      } else {
        navigator.pushNamed(NavigatorRoutes.settleMembershipFee);
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
                    loginHeaderWidgets(label: 'Sign in to your client account'),
                    emailAddress(context, controller: emailController),
                    password(context, controller: passwordController),
                    forgotPassword(onPress: () {}),
                    submitButton(context,
                        label: 'SIGN IN', onPress: () => loginClient()),
                    dontHaveAccount(
                        onPress: () => Navigator.of(context)
                            .pushNamed(NavigatorRoutes.clientRegister)),
                  ],
                )),
              ),
            )),
      ),
    );
  }
}
