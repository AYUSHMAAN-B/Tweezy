import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minimal_tweets_app/pages/profile_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();
  List<DocumentSnapshot> searchResults = [];

  Future<void> searchUsers() async {
    if (searchController.text.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    final result = await FirebaseFirestore.instance
        .collection('users')
        .where(
          'name',
          isGreaterThanOrEqualTo: searchController.text,
        )
        .where(
          'name',
          isLessThanOrEqualTo: '${searchController.text}\uf8ff',
        ) 
        .get();

    setState(() {
      searchResults = result.docs;
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text('S E A R C H   F O R   U S E R S'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) => searchUsers(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Type User\'s Name',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Search Results
          Expanded(
            child: ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                var user = searchResults[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                      return ProfilePage(userId: user['uid']);
                    }));
                  },
                  child: ListTile(
                    title: Text(user['name']),
                    subtitle: Text(user['email']),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
