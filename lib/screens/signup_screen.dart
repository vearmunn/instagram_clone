import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/responsive/responsive_layout_screen.dart';
import 'package:instagram_clone/services/auth_methods.dart';
import 'package:instagram_clone/utils/utils.dart';

import '../responsive/mobile_screen_layout.dart';
import '../responsive/web_screen_layout.dart';
import '../utils/colors.dart';
import '../utils/spacer.dart';
import '../widgets/textfield_input.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final bioController = TextEditingController();
  final usernameController = TextEditingController();
  Uint8List? profileImage;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    bioController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  void selectImage() async {
    Uint8List selectedImage = await pickImage(ImageSource.camera);
    setState(() {
      profileImage = selectedImage;
    });
  }

  void signUpUser() async {
    setState(() {
      isLoading = true;
    });
    String res = await AuthMethods().signupUser(
        email: emailController.text,
        password: passwordController.text,
        username: usernameController.text,
        bio: bioController.text,
        file: profileImage!);
    setState(() {
      isLoading = false;
    });

    if (res != 'success') {
      if (mounted) {
        showSnackBar(res, context);
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: ((context) => const ResponsiveLayout(
                    webScreenLayout: WebScreenLayout(),
                    mobileScreenLayout: MobileScreenLayout()))));
      }
    }

    print(res);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(flex: 2, child: Container()),
              SvgPicture.asset(
                'assets/ic_instagram.svg',
                colorFilter:
                    const ColorFilter.mode(primaryColor, BlendMode.srcIn),
              ),
              verticalSpace(32),
              GestureDetector(
                onTap: () {
                  selectImage();
                },
                child: Stack(
                  children: [
                    profileImage != null
                        ? CircleAvatar(
                            backgroundImage: MemoryImage(profileImage!),
                            radius: 64,
                          )
                        : const CircleAvatar(
                            backgroundImage: NetworkImage(
                                'https://cdn.icon-icons.com/icons2/2643/PNG/512/male_boy_person_people_avatar_icon_159358.png'),
                            radius: 64,
                          ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(40)),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                        ),
                      ),
                    )
                  ],
                ),
              ),
              verticalSpace(16),
              TextFieldInput(
                controller: emailController,
                hintText: 'Email',
                textInputType: TextInputType.emailAddress,
              ),
              verticalSpace(16),
              TextFieldInput(
                controller: usernameController,
                hintText: 'Username',
                textInputType: TextInputType.text,
              ),
              verticalSpace(16),
              TextFieldInput(
                controller: passwordController,
                hintText: 'Password',
                textInputType: TextInputType.text,
                isPass: true,
              ),
              verticalSpace(16),
              TextFieldInput(
                controller: bioController,
                hintText: 'Bio',
                textInputType: TextInputType.text,
              ),
              verticalSpace(16),
              isLoading
                  ? const CircularProgressIndicator()
                  : GestureDetector(
                      onTap: () async {
                        signUpUser();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(4)),
                        alignment: Alignment.center,
                        child: const Text('Sign Up'),
                      ),
                    ),
              Flexible(flex: 2, child: Container()),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: TextStyle(color: secondaryColor, fontSize: 12),
                    ),
                    Text(
                      'Login',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              verticalSpace(8),
            ],
          ),
        ),
      ),
    );
  }
}
