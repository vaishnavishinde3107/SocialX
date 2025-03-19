import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialx/features/posts/domain/repos/post_repo.dart';
import 'package:socialx/features/posts/presentation/cubits/post_states.dart';
import 'package:socialx/storage/domain/storage_repo.dart';

import '../../domain/entities/post.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({required this.postRepo, required this.storageRepo,}) :super(PostsInitial());

  // create a new post
  Future<void> createPost(Post posts, {String? imagePath, Uint8List? imageBytes}) async {
    String? imageUrl;

    try {
      emit(PostsUploading());  // Emit loading state when starting the upload process.

      // Handle image upload for mobile platforms (using file path)
      if (imagePath != null) {
        imageUrl = await storageRepo.uploadPostImageMobile(imagePath, posts.id);
      }
      // Handle image upload for web platforms (using file bytes)
      else if (imageBytes != null) {
        imageUrl = await storageRepo.uploadPostImageWeb(imageBytes, posts.id);
      }

      // If imageUrl is null, it means the upload failed. Log this scenario.
      if (imageUrl == null) {
        print("Image upload failed. No URL returned.");
      }

    //give image url to post
    final newPost = posts.copyWith(imageUrl: imageUrl);

    //create post in the backend
    postRepo.createPost(newPost);

    //re-fetch all in the backend
    fetchAllPosts();
  }catch(e){
    emit(PostsError('Failed to create post: $e'));
  }
}

  //fetch all posts
Future<void> fetchAllPosts() async{
  try{
    emit(PostsLoading());
    final post = await postRepo.fetchAllPosts();
    emit(PostsLoaded(post));
  }
  catch(e){
    emit(PostsError('Error fetching posts: $e'));
  }
}

  //delete a post
Future<void> deletePost(String postId) async {
  try{
    await postRepo.deletePost(postId);
  }catch(e){}
}

  //toggle like on a post
Future<void> toggleLikedPost(String postId, String userId) async{
    try{
      await postRepo.toggleLikePost(postId, userId);
    }catch(e){
      emit(PostsError("Failed to toggle like: $e"));
    }
}
}