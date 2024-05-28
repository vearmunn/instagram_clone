import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/provider/user_provider.dart';
import 'package:instagram_clone/services/firestore_methods.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:provider/provider.dart';

import '../utils/spacer.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  Uint8List? _selectedPhoto;
  bool isLoading = false;
  final TextEditingController captionController = TextEditingController();

  _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Create a Post'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(16),
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List photo = await pickImage(ImageSource.camera);
                  setState(() {
                    _selectedPhoto = photo;
                  });
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(16),
                child: const Text('Choose from gallery'),
                onPressed: () async {
                  Navigator.pop(context);
                  Uint8List photo = await pickImage(ImageSource.gallery);
                  setState(() {
                    _selectedPhoto = photo;
                  });
                },
              )
            ],
          );
        });
  }

  void postImage(String uid, String username, String profileImage) async {
    try {
      setState(() {
        isLoading = true;
      });
      String res = await FirestoreMethods().uploadPost(
          captionController.text, _selectedPhoto!, uid, username, profileImage);
      if (res == 'success') {
        if (mounted) {
          showSnackBar('Posted!', context);
        }
        clearSelectedPhoto();
      } else {
        if (mounted) {
          showSnackBar(res, context);
        }
      }
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

  void clearSelectedPhoto() {
    _selectedPhoto = null;
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).getUser;
    return _selectedPhoto == null
        ? Center(
            child: ElevatedButton.icon(
                onPressed: () => _selectImage(context),
                icon: const Icon(Icons.upload),
                label: const Text('Create a Post')),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: const Text('Post to'),
              actions: [
                TextButton(
                    onPressed: () {
                      postImage(user.uid, user.username, user.photoUrl);
                    },
                    child: const Text('Post'))
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  isLoading
                      ? const Padding(
                          padding: EdgeInsets.only(bottom: 8.0),
                          child: LinearProgressIndicator(),
                        )
                      : const Padding(padding: EdgeInsets.only(top: 0)),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(user.photoUrl),
                      ),
                      horizontalSpace(16),
                      Expanded(
                        child: SizedBox(
                          // width: 100,
                          child: TextField(
                            maxLines: 8,
                            controller: captionController,
                            decoration: const InputDecoration(
                                hintText: 'Write a caption...',
                                border: InputBorder.none),
                          ),
                        ),
                      ),
                      horizontalSpace(16),
                      SizedBox(
                        width: 50,
                        height: 50,
                        child: Image.memory(
                          _selectedPhoto!,
                          fit: BoxFit.cover,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
