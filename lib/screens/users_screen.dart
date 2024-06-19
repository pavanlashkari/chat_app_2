import 'package:chat_app/cubit/authCubit/auth_cubit.dart';
import 'package:chat_app/cubit/authCubit/auth_state.dart';
import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/screens/log_in_screen.dart';
import 'package:chat_app/services/database_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/chat_detail_widget.dart';
import '../widgets/chat_tile.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final textStyle = GoogleFonts.poppins();
  final DatabaseService databaseService = DatabaseService();
  Stream? _userStream;
  List<UserProfile>? _filteredUsers;
  final searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _userStream = databaseService.getUserProfiles();
    _filteredUsers = [];
    searchController.addListener(() {
      _onSearchChanged();
    });
  }

  void _onSearchChanged() {
    print(searchController.text);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  right: 20, left: 20, top: 50, bottom: 10),
              child: Row(
                children: [
                  Text(
                    "Chat",
                    style: GoogleFonts.poppins().copyWith(
                      color: Theme.of(context).textTheme.bodyLarge!.color,
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                    textAlign: TextAlign.start,
                  ),
                  const Spacer(),
                  BlocListener<GoogleAuthCubit, GoogleAuthState>(
                    listener: (context, state) {
                      if (state is GoogleAuthLogOutState) {
                        Navigator.popUntil(context, (route) => route.isFirst);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      }
                    },
                    child: InkWell(
                      onTap: () => context.read<GoogleAuthCubit>().logOut(),
                      child: Icon(
                        Icons.logout,
                        size: 24,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 20, right: 20, top: 10, bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            offset: Offset(2, 2),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                        color: const Color.fromRGBO(255, 255, 255, 1),
                      ),
                      child: TextFormField(
                        controller: searchController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search User",
                          hintStyle: textStyle.copyWith(
                            color: const Color.fromRGBO(184, 175, 175, 1),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 22,
                            color: Color.fromRGBO(184, 175, 175, 1),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.1),
                            offset: Offset(2, 2),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                        color: const Color.fromRGBO(255, 255, 255, 1),
                      ),
                      child: const Icon(Icons.edit_calendar,
                          size: 24, color: Color.fromRGBO(184, 175, 175, 1)),
                    ),
                  )
                ],
              ),
            ),
            //listView
            Expanded(child: _chatsList())
          ],
        ),
      ),
    );
  }

  Widget _chatsList() {
    return StreamBuilder(
      stream: _userStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Stream has Error");
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          final users = snapshot.data?.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              UserProfile user = users[index].data();
              final uid = FirebaseAuth.instance.currentUser!.uid;
              return Column(
                children: [
                  ChatListTile(
                    userProfile: user,
                    onTap: () async {
                      final chatExists = await databaseService.checkChatExists(
                        uid,
                        user.uid!,
                      );
                      print(chatExists);
                      if (!chatExists) {
                        databaseService.createNewChat(uid, user.uid!);
                        print("new chat created");
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatDetailsScreen(userProfile: user),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Divider(),
                  ),
                  // const Padding(
                  //   padding: EdgeInsets.only(top: 10),
                  //   child: Divider(
                  //     height: 1,
                  //     color: Color.fromRGBO(217, 217, 217, 0.24),
                  //   ),
                  // )
                ],
              );
            },
          );
        }
        return Container();
      },
    );
  }
}
