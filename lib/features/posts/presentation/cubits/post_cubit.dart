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

  //handle image upload for mobile platforms (using file path)
  if(imagePath != null) {
    emit(PostsUploading());
    imageUrl = await storageRepo.uploadProfileImageMobile(imagePath, posts.id);
  }

  //handle image upload for web platforms (using file bytes)
  else if (imageBytes != null){
    emit(PostsUploading());
    imageUrl = await storageRepo.uploadProfileImageMobile(imageBytes as String, posts.id);
  }
}
}