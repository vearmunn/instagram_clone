import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/screens/profile_screen.dart';
import 'package:instagram_clone/utils/spacer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var searchController = TextEditingController();
  QuerySnapshot<Map<String, dynamic>>? users;
  bool isShowUsers = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  fetchUsers() async {
    var snap = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: searchController.text)
        .get();
    setState(() {
      users = snap;
    });
    print(users);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: TextFormField(
          controller: searchController,
          onFieldSubmitted: (_) {
            setState(() {
              isShowUsers = true;
              fetchUsers();
            });
          },
          decoration: const InputDecoration(
              hintText: 'Search users...', border: InputBorder.none),
        ),
        actions: [
          const Icon(
            Icons.search,
            color: Colors.grey,
          ),
          horizontalSpace(16)
        ],
      ),
      body: isShowUsers
          ? users == null
              ? const Center(child: Text(''))
              : ListView.builder(
                  itemCount: users!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final snap = users!.docs[index];
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    ProfileScreen(uid: snap['uid'])));
                      },
                      leading: CircleAvatar(
                          backgroundImage: NetworkImage(snap['photoUrl'])),
                      title: Text(snap['username']),
                    );
                  },
                )
          : FutureBuilder(
              future: FirebaseFirestore.instance.collection('posts').get(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return MasonryGridView.count(
                  crossAxisCount: 3,
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index) => Image.network(
                    (snapshot.data! as dynamic).docs[index]['postUrl'],
                    fit: BoxFit.cover,
                  ),
                  mainAxisSpacing: 8.0,
                  crossAxisSpacing: 8.0,
                );
              },
            ),
    );
  }
}
