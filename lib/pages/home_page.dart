import 'package:akunaki_app/services/post_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late Future<List<Map<String, dynamic>>> _futurePosts;

  @override
  void initState() {
    super.initState();
    _futurePosts = PostService().fetchPosts();
  }

  Future<void> _refreshPosts() async {
    try {
      final posts = await PostService().fetchPosts();
      if (mounted) {
        setState(() {
          _futurePosts = Future.value(posts);
        });
      }
    } catch (error) {
      throw Exception('Failed to fetch posts: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade300,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No posts available.'));
          } else {
            final posts = snapshot.data!;
            return Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: const Icon(Icons.push_pin),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Icon(Icons.more_horiz),
                                ),
                              ],
                            ),
                            subtitle: post['content'] != null
                                ? Text(post['content']!)
                                : null,
                          ),
                          if (post['image'] != null)
                            Container(
                              alignment: Alignment.center,
                              child: Image.network(
                                post['image'],
                                fit: BoxFit.cover,
                                headers: const {'Cache-Control': 'no-cache'},
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                (loadingProgress
                                                        .expectedTotalBytes ??
                                                    1)
                                            : null,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: FloatingActionButton(
                    onPressed: () async {
                      final result =
                          await Navigator.pushNamed(context, '/post');
                      if (result == true) {
                        _refreshPosts();
                      }
                    },
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.send),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
