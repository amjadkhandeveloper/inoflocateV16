// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool showPassword = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor),
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(0, 10))
                          ],
                          shape: BoxShape.circle,
                          // image: const DecorationImage(
                          //   fit: BoxFit.cover,
                          //   image: NetworkImage(
                          //     "https://images.pexels.com/photos/2422278/pexels-photo-2422278.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
                          //   ),
                          // ),
                        ),
                        child: LottieBuilder.asset(
                          'assets/animation/user_animation.json',
                          repeat: false,
                          width: 130,
                          height: 130,
                          fit: BoxFit.fill,
                        ),
                      ),
                      // Positioned(
                      //     bottom: 0,
                      //     right: 0,
                      //     child: Container(
                      //       height: 40,
                      //       width: 40,
                      //       decoration: BoxDecoration(
                      //         shape: BoxShape.circle,
                      //         border: Border.all(
                      //           width: 4,
                      //           color:
                      //               Theme.of(context).scaffoldBackgroundColor,
                      //         ),
                      //         color: Theme.of(context).colorScheme.primary,
                      //       ),
                      //       child: const Icon(
                      //         Icons.edit,
                      //         color: Colors.white,
                      //       ),
                      //     )),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Admin",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              buildTextField("Full Name", "Infoadmin", false),
              buildTextField("Selected Language", "English", false),
              buildTextField("E-mail", "infoadmin@gmail.com", false),
              buildTextField("Password", "********", true),
              buildTextField("Location", "TLV, Banglore", false),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
      String labelText, String placeholder, bool isPasswordTextField) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 35.0),
      child: TextField(
        obscureText: isPasswordTextField ? showPassword : false,
        obscuringCharacter: "*",
        readOnly: true,
        decoration: InputDecoration(
            suffixIcon: isPasswordTextField
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        showPassword = !showPassword;
                      });
                    },
                    icon: const Icon(
                      Icons.remove_red_eye,
                      color: Colors.grey,
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.only(bottom: 3),
            labelText: labelText,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: placeholder,
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            )),
      ),
    );
  }
}
