import 'package:chat_app/cubit/facebook_cubit/facebook_auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FacebookAuthCubit extends Cubit<FacebookAuthState> {
  FacebookAuthCubit() : super(FacebookAuthInitialState());

  void facebookLogin() async {
    try {
      emit(FacebookAuthLoadingState());
      final LoginResult loginResult = await FacebookAuth.instance.login();
      print(loginResult.accessToken);

      if (loginResult.accessToken?.token != null) {
        print("true");
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(loginResult.accessToken!.token);

        final userCredential = await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);
        emit(FacebookAuthSuccessState(userCredential.user!));

        print("Accesstoken  1 : ${loginResult.accessToken?.toJson()}");
        print("Accesstoken  2 : ${loginResult.accessToken!.token}");

        SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setBool('isLoggedIn', true);
      } else {
        emit(FacebookAuthErrorState("Facebook Login Cancel!"));
      }
    } catch (e) {
      emit(FacebookAuthErrorState(e.toString()));
      print(e);
    }
  }
}
