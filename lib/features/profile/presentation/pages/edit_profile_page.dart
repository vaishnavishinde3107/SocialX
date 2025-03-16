import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
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
  //mobile image pick
  PlatformFile? imagePickedFile;

  //web picked images
  Uint8List? webImage;

  //bio text controller
  final bioTextController = TextEditingController();

  //pick images
  Future<void> pickImage() async{
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if(result != null) {
      setState(() {
        imagePickedFile = result.files.first;

        if(kIsWeb){
          webImage = imagePickedFile?.bytes;
        }
      });
    }
  }

  //update profile button pressed
  void updateProfile() async{
    //profile cubit
    final profileCubit = context.read<ProfileCubit>();

    //prepare images & data
    final String uid = widget.user.uid;
    final imageMobilePath = kIsWeb ? null : imagePickedFile?.path;
    final imagesWebBytes = kIsWeb ? imagePickedFile?.bytes : null;
    final String? newBio = bioTextController.text.isNotEmpty ? bioTextController.text : null;

    //only update profile of there is something to update
    if(imagePickedFile != null || newBio != null){
      profileCubit.updateProfile(
        uid: widget.user.uid, 
        newBio: bioTextController.text,
      imageMobilePath: imageMobilePath,
        imageWebBytes: imagesWebBytes,
      );
    }
    //nothing to update -> go to previous page
    else {
      Navigator.pop(context);
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

  Widget buildEditPage(){
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
          Center(
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),

              child:
              //display selected image for mobile
              (!kIsWeb && imagePickedFile != null) 
                  ?
                  Image.file(File(imagePickedFile!.path!),)
                  :
              //display selected image for web
              (kIsWeb && webImage != null)
              ?
                  Image.memory(webImage!)
                  :
              //No image selected -> display existing profile pic
              CachedNetworkImage(imageUrl: widget.user.profileImageUrl,
                //loading...
                placeholder: (context, url)=> const CircularProgressIndicator(),

                //error -> failed to load
                errorWidget: (context, url, error)=> Icon(
                  Icons.person,
                  size: 72,
                  color: Theme.of(context).colorScheme.primary,),
                //loaded
                imageBuilder: (context, imageProvider)=> Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(image: imageProvider,
                        fit: BoxFit.cover),
                  ),),),
            ),
          ),

          const SizedBox(height: 25,),

          //pick image button
          Center(child: MaterialButton(
              onPressed: pickImage,
          color: Colors.blue,
          child: Text("Pick Image"),),
          ),

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