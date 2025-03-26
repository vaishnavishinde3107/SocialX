import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialx/features/auth/domain/entities/app_users.dart';
import 'package:socialx/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialx/features/posts/presentation/components/post_tile.dart';
import 'package:socialx/features/posts/presentation/cubits/post_cubit.dart';
import 'package:socialx/features/posts/presentation/cubits/post_states.dart';
import 'package:socialx/features/profile/presentation/components/bio_box.dart';
import 'package:socialx/features/profile/presentation/cubits/profile_cubits.dart';
import 'package:socialx/features/profile/presentation/cubits/profile_states.dart';
import 'package:socialx/features/profile/presentation/pages/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //cubits
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  //current user
  late AppUsers? currentUser = authCubit.currentuser;

  //posts
  int postCount = 0;

  //on startup
  @override
  void initState() {
    super.initState();
    
    //load user profile state
    profileCubit.fetchUserProfile(widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileStates>(
      builder: (context, state) {
        //loaded
        if (state is ProfileLoaded) {
          //get loaded user
          final user = state.profileUser;

          return Scaffold(
            //Appbar
            appBar: AppBar(
              title: Text(user.name),
              foregroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                //edit profile button
                IconButton(
                  onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=> EditProfilePage(user: user,))), 
                  icon: const Icon(Icons.settings))
              ],
            ),

            //body
            body: ListView(
              children: [
                //email
                Center(
                  child: Text(user.email,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary
                  ),),
                ),
            
                const SizedBox(height: 25,),
            
                //profile pic
                CachedNetworkImage(imageUrl: user.profileImageUrl,
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
            
                const SizedBox(height: 25,),
            
                //bio box
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Row(
                    children: [
                      Text('Bio',style: TextStyle(
                        color: Theme.of(context).colorScheme.primary
                      ),),
                    ],
                  ),
                ),
                const SizedBox(height: 20,),
                        
                BioBox(text: user.bio),

                //posts
                Padding(
                  padding: const EdgeInsets.only(left: 25.0, top: 25),
                  child: Row(
                    children: [
                      Text('Posts',style: TextStyle(
                        color: Theme.of(context).colorScheme.primary
                      ),),
                    ],
                  ),
                ),
                const SizedBox(height: 20,),

                //list of posts from this user
                BlocBuilder<PostCubit, PostState>(
                    builder: (context, state){
                      //posts loaded
                      if(state is PostsLoaded){
                        // filter posts by user id
                        final userPost = state.posts
                            .where((post)=> post.userId == widget.uid)
                            .toList();

                        postCount = userPost.length;

                        return ListView.builder(
                          itemCount: postCount,
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemBuilder: (context, index){
                              //get individuals post
                              final post = userPost[index];

                              //return as post tile UI
                              return PostTile(
                                  post: post,
                                  onDeletePressed: ()=> context.read<PostCubit>().deletePost(post.id));
                            }
                        );
                      }

                      //post loading...
                      else if(state is PostsLoading){
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return const Center(
                          child: Text("No posts..."),
                        );
                      }
                    }
                )
              ],
            ),

          );
        }
        //loading...
        else if (state is ProfileLoading){
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(),),
          );
        } else {
          return const Center(child: Text("No profile found"));
        }
      },
    );
  }
}