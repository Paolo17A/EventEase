import 'package:event_ease/utils/colors_util.dart';
import 'package:event_ease/utils/firebase_util.dart';
import 'package:event_ease/widgets/custom_styling_widgets.dart';

import 'package:flutter/material.dart';
import '../utils/custom_containers_widget.dart';
import '../widgets/chat_messages.dart';
import '../widgets/new_message_widget.dart';

class ChatScreen extends StatefulWidget {
  final String otherPersonUID;
  ChatScreen({super.key, required this.otherPersonUID});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isLoading = true;
  bool _isClient = false;
  String _otherUserFirstName = '';
  String _otherUserLastName = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getOtherUser();
  }

  void _getOtherUser() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      //  If the current user is a client, we will get the trainer's data and check if their account has been deleted by the admin
      final currentUserData = await getCurrentUserData();
      _isClient = currentUserData['userType'] == 'CLIENT';
      final otherUserData = await getThisUserData(widget.otherPersonUID);

      _otherUserFirstName = otherUserData['firstName'] as String;
      _otherUserLastName = otherUserData['lastName'] as String;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      scaffoldMessenger
          .showSnackBar(SnackBar(content: Text('Error getting users: $error')));
      navigator.pop();
    }
  }
//==============================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: comicNeueText(
              label: '$_otherUserFirstName $_otherUserLastName',
              color: CustomColors.midnightExtress),
        ),
        body: stackedLoadingContainer(
            context,
            _isLoading,
            Column(children: [
              Expanded(child: ChatMessages(otherUID: widget.otherPersonUID)),
              NewMessage(
                otherName: '$_otherUserFirstName $_otherUserLastName',
                otherUID: widget.otherPersonUID,
                isClient: _isClient,
              )
            ])));
  }
}
