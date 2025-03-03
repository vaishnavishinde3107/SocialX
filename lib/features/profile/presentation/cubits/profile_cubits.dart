import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialx/features/profile/domain/repos/profile_user.dart';
import 'package:socialx/features/profile/presentation/cubits/profile_states.dart';

class ProfileCubit extends Cubit<ProfileStates>{
    final ProfileRepo profileRepo;

    ProfileCubit({required this.profileRepo}): super(ProfileInitial());

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

          //update new profile
          final updateProfile=
          currentUser.copyWith(newBio: newBio ?? currentUser.bio);

          //update in repo
          await profileRepo.updateProfile(updateProfile);

          //refetch the update profile
          await fetchUserProfile(uid);
        } catch (e) {
          emit(ProfileErrors('Error fetching user profile'));
        }
    }
}