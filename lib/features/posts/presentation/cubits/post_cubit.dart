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
      print("Starting post creation...");

      emit(PostsUploading());  // Emit loading state when starting the upload process.
      print("State set to uploading");

      // Handle image upload for mobile platforms (using file path)
      if (imagePath != null) {
        print("Uploading image from mobile: $imagePath");
        imageUrl = await storageRepo.uploadPostImageMobile(imagePath, posts.id);
        print("Image uploaded. URL: $imageUrl");
      }
      // Handle image upload for web platforms (using file bytes)
      else if (imageBytes != null) {
        print("Uploading image from web (bytes).");
        imageUrl = await storageRepo.uploadPostImageWeb(imageBytes, posts.id);
        print("Image uploaded. URL: $imageUrl");
      }

      // If imageUrl is null, it means the upload failed. Log this scenario.
      if (imageUrl == null) {
        print("Image upload failed. No URL returned.");
      }

      // Give image URL to the post
      final newPost = posts.copyWith(imageUrl: imageUrl);
      print("New post created with image URL: ${newPost.imageUrl}");

      // Create post in the backend
      print("Creating post in the backend...");
      await postRepo.createPost(newPost);
      print("Post created successfully.");

      // Fetch all posts after posting
      print("Fetching all posts...");
      await fetchAllPosts();
      print("All posts fetched successfully.");

      // Emit PostsLoaded or similar state to indicate the process is complete
      //emit(PostsLoaded(allPosts));  // Update the state to indicate the post was successfully created and loaded.
      print("State set to PostsLoaded.");

    } catch (e) {
      print("Error occurred: $e");
      emit(PostsError('Failed to create post: $e'));
    }
  }


  Future<void> fetchAllPosts() async {
    try {
      // Emit loading state to indicate that the posts are being fetched
      emit(PostsLoading());

      // Fetch all posts (you should uncomment and call the appropriate fetch function from your repository)
      final List<Post> allPosts = await postRepo.fetchAllPosts();

      // Emit the PostsLoaded state with the fetched posts
      emit(PostsLoaded(allPosts));

    } catch (e) {
      // If an error occurs during the fetch, emit PostsError with the error message
      emit(PostsError('Error fetching posts: $e'));
    }
  }


  //delete a post
Future<void> deletePost(String postId) async {
  try{
    await postRepo.deletePost(postId);
  }catch(e){}
}
}