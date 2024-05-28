import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/post_model.dart';
import 'package:instagram_clone/services/storage_methods.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(String caption, Uint8List file, String uid,
      String username, String profileImage) async {
    String res = "some error occured!";
    String postId = const Uuid().v1();
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage('posts', file, true);

      PostModel post = PostModel(
          caption: caption,
          uid: uid,
          postId: postId,
          profileImage: profileImage,
          username: username,
          datePublished: DateTime.now(),
          likes: [],
          postUrl: photoUrl);

      _firestore.collection('posts').doc(postId).set(post.toMap());
      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid])
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid])
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future postComment(String postId, String comment, String uid, String username,
      String profileImage, context) async {
    try {
      if (comment.isNotEmpty) {
        String commentId = const Uuid().v1();
        // print('$username $profileImage $uid $comment $commentId');
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profileImage': profileImage,
          'username': username,
          'uid': uid,
          'comment': comment,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
        showSnackBar('Comment posted!', context);
      }
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  Future deletePost(String postId, context) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  Future followUser(String uid, String otherUserUid) async {
    try {
      await _firestore.collection('users').doc(otherUserUid).update({
        'followers': FieldValue.arrayUnion([uid])
      });
      await _firestore.collection('users').doc(uid).update({
        'following': FieldValue.arrayUnion([uid])
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future unfollowUser(String uid, String otherUserUid) async {
    try {
      await _firestore.collection('users').doc(otherUserUid).update({
        'followers': FieldValue.arrayRemove([uid])
      });
      await _firestore.collection('users').doc(uid).update({
        'following': FieldValue.arrayRemove([uid])
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
