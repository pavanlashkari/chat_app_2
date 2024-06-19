import 'package:chat_app/cubit/authCubit/auth_cubit.dart';
import 'package:chat_app/screens/data_form_screen.dart';
import 'package:chat_app/screens/users_screen.dart';
import 'package:chat_app/services/database_services.dart';
import 'package:chat_app/services/notification_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../cubit/authCubit/auth_state.dart';
import '../cubit/facebook_cubit/facebook_auth_cubit.dart';
import '../cubit/facebook_cubit/facebook_auth_state.dart';
import '../models/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  NotificationServices notificationServices = NotificationServices();

  RegExp regex = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationService();
    notificationServices.getDeviceToken().then((value){
      print("Value :- $value");
    });
    notificationServices.isTokenRefresh();
    notificationServices.firebaseInit();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: SingleChildScrollView(
          child: SizedBox(
            height: height,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: width * .1, vertical: 24),
                  child: Image.asset("assets/images/login.png"),
                ),
                Container(
                  width: width * .9,
                  padding: const EdgeInsets.only(right: 20, left: 20),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(214, 221, 232, 0.45),
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: BlocConsumer<GoogleAuthCubit, GoogleAuthState>(
                    listener: (context, state) async{
                      if (state is GoogleAuthSuccessState){
                        UserProfile? userProfile = await DatabaseService().getUser();
                        print(userProfile == null);
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => userProfile == null?
                            UserDataScreen():ChatScreen(),
                          ),
                        );

                      } else if (state is GoogleAuthErrorState) {
                        print(state.error);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(state.error)));
                      }
                    },
                    builder: (context, state) {
                      return TextButton(
                        onPressed: state is GoogleAuthLoadingState ?null: () => context.read<GoogleAuthCubit>().login(),
                        child: Stack(
                          children: [
                            SizedBox(
                              width: width,
                              child: Text(
                                "Login with Google",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins().copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: const Color.fromRGBO(0, 0, 0, 0.54),
                                ),
                              ),
                            ),
                            Image.asset(
                              "assets/icons/googleLogo.png",
                              height: 20,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height:  30,),
                Container(
                  width: width * .9,
                  padding: const EdgeInsets.only(right: 20, left: 20),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(214, 221, 232, 0.45),
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: BlocConsumer<FacebookAuthCubit, FacebookAuthState>(
                    listener: (context, state) async{
                      if (state is FacebookAuthSuccessState){
                        UserProfile? userProfile = await DatabaseService().getUser();
                        print(userProfile == null);
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => userProfile == null?
                            UserDataScreen():ChatScreen(),
                          ),
                        );

                      } else if (state is FacebookAuthErrorState) {
                        print(state.error);
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text(state.error)));
                      }
                    },
                    builder: (context, state) {
                      return TextButton(
                        onPressed: state is FacebookAuthLoadingState ?null: () => context.read<FacebookAuthCubit>().facebookLogin(),
                        child: Stack(
                          children: [
                            SizedBox(
                              width: width,
                              child: Text(
                                "Login with Facebook",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins().copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: const Color.fromRGBO(0, 0, 0, 0.54),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
