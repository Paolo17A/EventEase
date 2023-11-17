import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<Map<dynamic, dynamic>> getCurrentUserData() async {
  final user = await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();
  return user.data() as Map<dynamic, dynamic>;
}
