import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:xchange_net/src/view/screen/user/search_ad_detail_screen.dart';

class SearchFavoriteScreen extends StatefulWidget {
  const SearchFavoriteScreen({Key? key}) : super(key: key);

  @override
  State<SearchFavoriteScreen> createState() => _SearchFavoriteScreenState();
}

class _SearchFavoriteScreenState extends State<SearchFavoriteScreen> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        title: Card(
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search...',
            ),
            onChanged: (val) {
              setState(() {
                searchText = val;
              });
            },
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ads').snapshots(),
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final searchResults = snapshots.data!.docs.where((doc) =>
          doc['title']
              .toString()
              .toLowerCase()
              .startsWith(searchText.toLowerCase())
              && doc['isPublished'] == true
          );
          if (searchText.isEmpty) {
            return Container();
          } else if (searchResults.isEmpty) {
            return Center(
              child: Text(
                'No results found',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                var document = searchResults.elementAt(index);
                return ListTile(
                  title: Text(
                    document['title'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    document['description'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(document['image']),
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => DetailScreen(document),
                    ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}