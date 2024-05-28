import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../responsive/mobile_screen_layout.dart';
import '../responsive/responsive_layout_screen.dart';
import '../responsive/web_screen_layout.dart';
import '../services/auth_methods.dart';
import '../utils/colors.dart';
import '../utils/spacer.dart';
import '../utils/utils.dart';
import '../widgets/textfield_input.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void loginUser() async {
    setState(() {
      isLoading = true;
    });
    String res = await AuthMethods()
        .loginUser(emailController.text, passwordController.text);
    if (res == "success") {
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: ((context) => const ResponsiveLayout(
                    webScreenLayout: WebScreenLayout(),
                    mobileScreenLayout: MobileScreenLayout()))));
      }
    } else {
      if (mounted) {
        showSnackBar(res, context);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
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
              verticalSpace(40),
              TextFieldInput(
                controller: emailController,
                hintText: 'Email',
                textInputType: TextInputType.emailAddress,
              ),
              verticalSpace(16),
              TextFieldInput(
                controller: passwordController,
                hintText: 'Password',
                textInputType: TextInputType.text,
                isPass: true,
              ),
              verticalSpace(16),
              isLoading
                  ? const CircularProgressIndicator()
                  : GestureDetector(
                      onTap: () {
                        loginUser();
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(4)),
                        alignment: Alignment.center,
                        child: const Text('Log in'),
                      ),
                    ),
              Flexible(flex: 2, child: Container()),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => const SignupScreen())));
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: secondaryColor, fontSize: 12),
                    ),
                    Text(
                      'Register',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              verticalSpace(16),
            ],
          ),
        ),
      ),
    );
  }
}
