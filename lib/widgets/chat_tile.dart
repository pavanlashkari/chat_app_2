import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/widgets/chat_detail_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatListTile extends StatelessWidget {
  final UserProfile userProfile;
  final VoidCallback onTap;
  const ChatListTile({super.key, required this.userProfile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 18, right: 18),
      width: MediaQuery.of(context).size.width,
      height: 50,
      child: InkWell(
        onTap: onTap,
        // {
        //   FocusScope.of(context).requestFocus(FocusNode());
        //   Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatDetailsScreen(),));
        // },
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  child: Image.network(
                    userProfile.pfpURL!,
                    fit: BoxFit.fill,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 13),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile.name!,
                        style: GoogleFonts.poppins().copyWith(
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
