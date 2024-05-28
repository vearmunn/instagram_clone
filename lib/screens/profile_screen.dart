// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/services/firestore_methods.dart';
import 'package:provider/provider.dart';

import 'package:instagram_clone/provider/user_provider.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/spacer.dart';
import 'package:instagram_clone/utils/utils.dart';

import '../services/auth_methods.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    Key? key,
    required this.uid,
  }) : super(key: key);
  final String uid;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  var userData = {};
  var posts = [];
  bool isLoading = false;
  bool isFollowing = false;

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    try {
      setState(() {
        isLoading = true;
      });
      var res = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();
      setState(() {
        userData = res.data()!;
        posts = postSnap.docs;
        isFollowing = userData['followers']
            .contains(FirebaseAuth.instance.currentUser!.uid);
      });
    } catch (e) {
      if (mounted) {
        showSnackBar(e.toString(), context);
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: isLoading
            ? const Center(child: LinearProgressIndicator())
            : Text('${userData['username']}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    width: double.infinity,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(userData['photoUrl']),
                        ),
                        horizontalSpace(16),
                        Expanded(
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(userData['uid'])
                                .snapshots(),
                            builder: (BuildContext context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      DoubleTexts(
                                          topText: posts.length.toString(),
                                          bottomText: 'Posts'),
                                      DoubleTexts(
                                          topText:
                                              '${snapshot.data!.data()!['followers'].length}',
                                          bottomText: 'Followers'),
                                      DoubleTexts(
                                          topText:
                                              '${snapshot.data!.data()!['following'].length}',
                                          bottomText: 'Following'),
                                    ],
                                  ),
                                  verticalSpace(12),
                                  user.uid == userData['uid']
                                      ? ProfileButton(
                                          text: 'Signout',
                                          onTap: () {
                                            AuthMethods().signOut();
                                          },
                                        )
                                      : snapshot.data!
                                              .data()!['followers']
                                              .contains(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                          ? ProfileButton(
                                              text: 'Unfollow',
                                              onTap: () async {
                                                await FirestoreMethods()
                                                    .unfollowUser(
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid,
                                                        userData['uid']);
                                              },
                                            )
                                          : ProfileButton(
                                              text: 'Follow',
                                              onTap: () async {
                                                await FirestoreMethods()
                                                    .followUser(
                                                        FirebaseAuth.instance
                                                            .currentUser!.uid,
                                                        userData['uid']);
                                              },
                                            ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      userData['username'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  verticalSpace(4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(userData['bio']),
                  ),
                  verticalSpace(16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 1,
                      crossAxisCount: 3,
                    ),
                    itemCount: posts.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Image.network(
                        posts[index]['postUrl'],
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

class ProfileButton extends StatelessWidget {
  const ProfileButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
            color: text != 'Signout' ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: Colors.grey, width: text != 'Edit Profile' ? 0 : 1)),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class DoubleTexts extends StatelessWidget {
  const DoubleTexts({
    Key? key,
    required this.topText,
    required this.bottomText,
  }) : super(key: key);

  final String topText;
  final String bottomText;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          topText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        verticalSpace(4),
        Text(
          bottomText,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
