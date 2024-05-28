// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:instagram_clone/provider/user_provider.dart';
import 'package:provider/provider.dart';

import '../utils/dimensions.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget webScreenLayout;
  final Widget mobileScreenLayout;
  const ResponsiveLayout({
    Key? key,
    required this.webScreenLayout,
    required this.mobileScreenLayout,
  }) : super(key: key);

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  bool isLoading = false;
  @override
  void initState() {
    fetchUserData();
    super.initState();
  }

  fetchUserData() async {
    setState(() {
      isLoading = true;
    });
    UserProvider userProvider = Provider.of(context, listen: false);
    await userProvider.fetchUser();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (isLoading == true) {
          return const Center(child: CircularProgressIndicator());
        } else {
          if (constraints.maxWidth > webScreenSize) {
            return widget.webScreenLayout;
          }
          return widget.mobileScreenLayout;
        }
      },
    );
  }
}
