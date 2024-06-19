import 'package:firebase_auth/firebase_auth.dart';

abstract class FacebookAuthState{}

class FacebookAuthInitialState extends FacebookAuthState{}

class FacebookAuthLoadingState extends FacebookAuthState{}

class FacebookAuthSuccessState extends FacebookAuthState{
  final User user;
  FacebookAuthSuccessState(this.user);
}

class FacebookAuthErrorState extends FacebookAuthState{
  String error;
  FacebookAuthErrorState(this.error);
}

class FacebookAuthLogOutState extends FacebookAuthState {}