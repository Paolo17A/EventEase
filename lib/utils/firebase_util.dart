import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<Map<dynamic, dynamic>> getCurrentUserData() async {
  return await getThisUserData(FirebaseAuth.instance.currentUser!.uid);
}

Future<Map<dynamic, dynamic>> getThisUserData(String userID) async {
  final user =
      await FirebaseFirestore.instance.collection('users').doc(userID).get();
  return user.data() as Map<dynamic, dynamic>;
}
