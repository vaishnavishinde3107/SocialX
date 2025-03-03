import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialx/features/profile/domain/entities/profile_user.dart';
import 'package:socialx/features/profile/domain/repos/profile_user.dart';

class FirebaseProfileRepo implements ProfileRepo{
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<ProfileUser?> fetchUserProfile(String uid) async{
    try {
      //get the user document from firestore
      final userDoc = await firebaseFirestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();

        if (userData != null) {
          return ProfileUser(
            uid: uid, 
            email: userData['email'] ?? '', 
            name: userData['name'] ?? '', 
            bio: userData['bio']  ?? '', 
            profileImageUrl: userData['profileImageUrl'].toString());
        }
      }

      return null;
    } catch (e) {
      print("Error fetching user profile $e");
      return null;
    }
  }

  @override
  Future<void> updateProfile(ProfileUser updateProfile) async{
    try {
      //convert updated profile to json to store in firestore
      await firebaseFirestore.collection('users').doc(updateProfile.uid)
      .update({
        'bio': updateProfile.bio,
        'profileImageUrl': updateProfile.profileImageUrl,
      }
      );
    } catch (e) {
      print("Error updating profile: $e"); 
      throw Exception(e);
    }
  }

}