// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String caption;
  final String uid;
  final String postId;
  final String profileImage;
  final String username;
  final DateTime datePublished;
  final List likes;
  final String postUrl;
  PostModel({
    required this.caption,
    required this.uid,
    required this.postId,
    required this.profileImage,
    required this.username,
    required this.datePublished,
    required this.likes,
    required this.postUrl,
  });

  Map<String, dynamic> toMap() => {
        "username": username,
        "uid": uid,
        "caption": caption,
        "profileImage": profileImage,
        "postId": postId,
        "datePublished": datePublished,
        "likes": likes,
        "postUrl": postUrl,
      };

  static PostModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return PostModel(
        username: snapshot['username'],
        uid: snapshot['uid'],
        caption: snapshot['caption'],
        profileImage: snapshot['profileImage'],
        postId: snapshot['postId'],
        datePublished: snapshot['datePublished'],
        likes: snapshot['likes'],
        postUrl: snapshot['postUrl']);
  }
}
