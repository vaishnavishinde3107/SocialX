import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialx/features/auth/domain/entities/app_users.dart';
import 'package:socialx/features/auth/domain/repos/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
Future<AppUsers?> getCurrentUsers() async {
  final firebaseUser = firebaseAuth.currentUser;

  // If user is not logged in
  if (firebaseUser == null) {
    return null;
  }

  // If user exists
  return AppUsers(
    uid: firebaseUser.uid, 
    email: firebaseUser.email!, 
    name: '');
}


  @override
  Future<AppUsers?> loginWithEmailPassword(String email, String password) async {
    try {
      //attempt sign in
      UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);

      //create user
      AppUsers user = AppUsers(uid: userCredential.user!.uid, email:email, name: '');

      //return user
      return user;

      //catch any errors
    } catch (e) {
      throw Exception('login failed: $e');
    }
  }

  @override
  Future<void> logout() async{
    await FirebaseAuth.instance.signOut();
  }

  @override
  Future<AppUsers?> registerWithEmailPassword(String name, String email, String password) async {
    try {
      //attempt sign in
      UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      //create user
      AppUsers user = AppUsers(uid: userCredential.user!.uid, email:email, name: name);

      //return user
      return user;

      //catch any errors
    } catch (e) {
      throw Exception('Registeration failed: $e');
    }
  }
}