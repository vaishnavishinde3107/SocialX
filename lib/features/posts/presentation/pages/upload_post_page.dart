import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:socialx/features/auth/domain/entities/app_users.dart';
import 'package:socialx/features/auth/presentation/components/my_textfield.dart';
import 'package:socialx/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialx/features/posts/domain/entities/post.dart';
import 'package:socialx/features/posts/presentation/cubits/post_cubit.dart';
import 'package:socialx/features/posts/presentation/cubits/post_states.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {

  //mobile image pick
  PlatformFile? imagePickedFile;

  //web image pick
  Uint8List? webImage;

  //text controller -> caption
  final textEditingController = TextEditingController();

  //current user
  AppUsers? currentUser;

  //get current user
  void getCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentuser;
  }

  //select image
  Future<void> pickImage() async{
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,  // `withData` is `true` when using web
    );

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;

        // For web, store the image bytes
        if (kIsWeb) {
          webImage = imagePickedFile?.bytes;
        }
      });

      // Debugging logs to verify if the image was selected
      print("Picked image: ${imagePickedFile?.path}");  // For mobile
      print("Web image bytes: ${webImage}");  // For web
    }
  }

  //compress image
  // Future<void> compressImage() async {
  //   final result = await FlutterImageCompress.compressWithFile(
  //     imagePickedFile!.path!,
  //     minWidth: 800,
  //     minHeight: 800,
  //     quality: 80,
  //   );
  //
  //   setState(() {
  //     webImage = result;
  //   });
  // }

  //create & upload post
  void uploadPost(){
    //check if both image and caption are provided
    if(imagePickedFile == null || textEditingController.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Both the image and caption are required'))
      );
      return ;
    }

    //create a new post object
    final newPost = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: currentUser!.uid,
        userName: currentUser!.name,
        text: textEditingController.text,
        imageUrl: '',
        timestamp: DateTime.now(),
        likes: []
    );

    //post cubit
    final postCubit = context.read<PostCubit>();

    //web upload
    if(kIsWeb){
      postCubit.createPost(newPost, imageBytes: imagePickedFile?.bytes);
    }

    //mobile upload
    else{
      postCubit.createPost(newPost, imagePath: imagePickedFile?.path);
    }

    @override
    void dispose()  {
      textEditingController.dispose();
      super.dispose();
    }

  }

  @override
  void initState(){
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    
    //BLOC CONSUMER -> builder + Listener
    return BlocConsumer<PostCubit, PostState>(
        builder: (context, state) {
          print(state);
          // loading or uploading...
          if(state is PostsLoading || state is PostsUploading){
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          //build upload page
          return buildUploadPage();
        },
      //go to previous page when upload is done & post are loaded
        listener: (context, state) {
          if(state is PostsLoaded){
            Navigator.pop(context);
          }
        },
    );
  }

  Widget buildUploadPage(){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          //upload button
          IconButton(
              onPressed: uploadPost,
              icon: const Icon(Icons.upload)),
        ],
      ),

      body: Center(
        child: Column(
          children: [
            //image preview for web
            if(kIsWeb && webImage != null)
              Image.memory(webImage!),
            //image preview for mobile
            if(!kIsWeb && imagePickedFile != null)
              Image.file(File(imagePickedFile!.path!)),
            
            //pick image button
            MaterialButton(
              onPressed: pickImage,
              color: Colors.blue,
              child: const Text("Pick Image"),
            ),

            //caption text box
            MyTextfield(
                controller: textEditingController,
                hintText: 'Enter Caption',
                obscuretext: false)
          ],
        ),
      ),
    );
  }
}
