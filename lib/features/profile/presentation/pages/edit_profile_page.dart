import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialx/features/auth/presentation/components/my_textfield.dart';
import 'package:socialx/features/profile/domain/entities/profile_user.dart';
import 'package:socialx/features/profile/presentation/cubits/profile_cubits.dart';
import 'package:socialx/features/profile/presentation/cubits/profile_states.dart';


class EditProfilePage extends StatefulWidget {
  final ProfileUser user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  final bioTextController = TextEditingController();

  //update profile button pressed
  void updateProfile() async{
    //profile cubit
    final profileCubit = context.read<ProfileCubit>();

    if(bioTextController.text.isNotEmpty){
      profileCubit.updateProfile(
        uid: widget.user.uid, 
        newBio: bioTextController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileStates>(
      builder: (context, state){
        //profile loading...
        if (state is ProfileLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  Text('Uploading...')
                ],
              ),
            ),
          );
        }

        //profile error
        else{
          //edit form
        return buildEditPage();
        }
      }, 
      listener: (context, state){
        if (state is ProfileLoaded) {
          Navigator.pop(context);
        }
      });
  }

  Widget buildEditPage({double uploadProgress =0.0}){
    return Scaffold(
      appBar: AppBar(
        title: 
        const Text('Edit Profile'),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          //save button
          IconButton(
            onPressed: updateProfile, 
            icon: const Icon(Icons.upload))
        ],
      ),
      body:Column(
        children: [
          //profile pic

          //bio
          const Text('Bio'),

          const SizedBox(height: 10,),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: MyTextfield(
              controller: bioTextController, 
              hintText: widget.user.bio, 
              obscuretext: false),
          )
        ],
      ) ,
    );
  }
}