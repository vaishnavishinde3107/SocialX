import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialx/features/auth/data/firebase_auth_repo.dart';
import 'package:socialx/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialx/features/auth/presentation/cubits/auth_state.dart';
import 'package:socialx/features/auth/presentation/pages/auth_page.dart';
import 'package:socialx/features/home/presentation/pages/home_page.dart';
import 'package:socialx/features/posts/data/firebase_post_repo.dart';
import 'package:socialx/features/posts/presentation/cubits/post_cubit.dart';
import 'package:socialx/features/profile/data/firebase_profile_repo.dart';
import 'package:socialx/features/profile/presentation/cubits/profile_cubits.dart';
import 'package:socialx/storage/data/firebase_storage_repo.dart';
import 'package:socialx/themes/light_mode.dart';

/*
App - root level

-----------------------------------------------------

Repositories: for the database
  - firebase

Bloc Providers: State Management
  - auth
  - profile
  - post
  - search
  - Themes

check Auth State
  - unauthenticated -> (login/ register)
  - authenticated -> home page

 */

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //auth repo
    final firebaseAuthRepo = FirebaseAuthRepo();
    //profile repo
    final firebaseProfileRepo = FirebaseProfileRepo();
    //storage repo
    final firebaseStorageRepo = FirebaseStorageRepo();
    //post repo
    final firebasePostRepo = FirebasePostRepo();

    return BlocProvider(
      create: (context)=> AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
      child: MultiBlocProvider(
        //provide cubits to app
        providers: [
          //auth cubit
          BlocProvider<AuthCubit>(create: (context)=> AuthCubit(authRepo: firebaseAuthRepo)..checkAuth()),

          //profile cubit
          BlocProvider<ProfileCubit>(create: (context)=> ProfileCubit(profileRepo: firebaseProfileRepo, storageRepo: firebaseStorageRepo),),

          //post cubit
          BlocProvider<PostCubit>(create: (context)=> PostCubit(postRepo: firebasePostRepo, storageRepo: firebaseStorageRepo)),
        ], 
        child: MaterialApp(
      theme: lightMode,
      home: BlocConsumer<AuthCubit, AuthState>(
        builder: (context, authState){
          print(authState);

          //unauthenticated -> (login/ register)
          if (authState is Unauthenticated) {
            return const AuthPage();
          }
          //authenticated -> home page
          if (authState is Authenticated) {
            return const HomePage();
          }

          //loading
          else {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        }, 
        //listen for errors
        listener: (context, authState){
          if (authState is AuthErrors) {
            ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(authState.message)));
          }
        }),
      debugShowCheckedModeBanner: false,
    ),)
      );
  }
}