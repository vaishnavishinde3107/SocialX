/*
Auth state
 */

import 'package:socialx/features/auth/domain/entities/app_users.dart';

abstract class AuthState {}

//initial 
class AuthInitial extends AuthState{}

//loading...
class AuthLoading extends AuthState{}

//Authenticated
class Authenticated extends AuthState{
  Authenticated(AppUsers user);
}

//Unauthenticated
class Unauthenticated extends AuthState{}

//errors
class AuthErrors extends AuthState{
  final String message;
  AuthErrors(this.message);
}