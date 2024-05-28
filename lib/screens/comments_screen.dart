// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:instagram_clone/services/firestore_methods.dart';

import '../models/user_model.dart';
import '../provider/user_provider.dart';
import '../utils/spacer.dart';

class CommentScreen extends StatefulWidget {
  final dynamic snap;
  const CommentScreen({
    Key? key,
    required this.snap,
  }) : super(key: key);

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  var commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const inputBorder = InputBorder.none;
    final UserModel user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios)),
        title: const Text('Comments'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.snap['postId'])
            .collection('comments')
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              final snap = snapshot.data!.docs[index];
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
                child: Row(children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(snap['profileImage']),
                  ),
                  horizontalSpace(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                            text: TextSpan(
                                text: '${snap['username']} ',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                                children: [
                              TextSpan(
                                  text: snap['comment'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal))
                            ])),
                        verticalSpace(8),
                        Text(
                          DateFormat.yMMMEd()
                              .format(widget.snap['datePublished'].toDate()),
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        )
                      ],
                    ),
                  ),
                  horizontalSpace(16),
                  const Icon(
                    Icons.favorite_border,
                    size: 16,
                    color: Colors.grey,
                  )
                ]),
              );
            },
          );
        },
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
        width: double.infinity,
        color: mobileBackgroundColor,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.photoUrl),
            ),
            horizontalSpace(8),
            Expanded(
                child: TextField(
              controller: commentController,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                  hintText: 'Comment as ${user.username}',
                  border: inputBorder,
                  focusedBorder: inputBorder,
                  enabledBorder: inputBorder,
                  contentPadding: const EdgeInsets.all(12)),
            )),
            TextButton(
                onPressed: () async {
                  await FirestoreMethods().postComment(
                      widget.snap['postId'],
                      commentController.text,
                      user.uid,
                      user.username,
                      user.photoUrl,
                      context);

                  commentController.clear();
                },
                child: const Text('Post'))
          ],
        ),
      ),
    );
  }
}
