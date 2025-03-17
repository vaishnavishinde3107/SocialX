import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialx/features/profile/domain/repos/profile_user.dart';
import 'package:socialx/features/profile/presentation/cubits/profile_states.dart';
import 'package:socialx/storage/domain/storage_repo.dart';

class ProfileCubit extends Cubit<ProfileStates>{
    final ProfileRepo profileRepo;
    final StorageRepo storageRepo;

    ProfileCubit({required this.storageRepo ,required this.profileRepo}): super(ProfileInitial());

    //fetch user profile using repo
    Future<void> fetchUserProfile(String uid) async{
        try {
          emit(ProfileLoading());
          final user = await profileRepo.fetchUserProfile(uid);

          if (user != null) {
            emit(ProfileLoaded(user));
          } else{
            emit(ProfileErrors("User not found!"));
          }
        } catch (e) {
          emit(ProfileErrors(e.toString()));
        }
    }

    //update bio or profile picture
    Future<void> updateProfile({
        required String uid,
        String? newBio,
      Uint8List? imageWebBytes,
      String? imageMobilePath,
    }) async{
        emit(ProfileLoading());

        try {
          //fetch current profile first
          final currentUser = await profileRepo.fetchUserProfile(uid);

          if (currentUser == null) {
            emit(ProfileErrors("Failed to fetch user profile update"));
            return;
          }

          //profile picture update
          String? imageDownloadUrl;
          
          if(imageWebBytes != null || imageMobilePath != null){
            //for mobile
            if(imageMobilePath != null){
              //upload
              imageDownloadUrl =
                  await storageRepo.uploadProfileImageMobile(imageMobilePath, uid);
            }
            
            //for web
            else if(imageWebBytes != null){
              //upload
              imageDownloadUrl =
                  await storageRepo.uploadProfileImageWeb(imageWebBytes, uid);
            }

            if(imageDownloadUrl == null){
              emit(ProfileErrors("Failed to upload image"));
              return;
            }
          }

          //update new profile
          final updateProfile=
          currentUser.copyWith(
            newBio: newBio ?? currentUser.bio,
            newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,
          );

          //update in repo
          await profileRepo.updateProfile(updateProfile);

          //refetch the update profile
          await fetchUserProfile(uid);
        } catch (e) {
          emit(ProfileErrors('Error fetching user profile'));
        }
    }
}