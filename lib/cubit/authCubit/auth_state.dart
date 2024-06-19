import "package:firebase_auth/firebase_auth.dart";

abstract class GoogleAuthState{}

class GoogleAuthInitialState extends GoogleAuthState{}

class GoogleAuthLoadingState extends GoogleAuthState{}

class GoogleAuthSuccessState extends GoogleAuthState{
  final User user;
  GoogleAuthSuccessState(this.user);
}

class GoogleAuthErrorState extends GoogleAuthState{
  String error;
  GoogleAuthErrorState(this.error);
}

class GoogleAuthLogOutState extends GoogleAuthState {}