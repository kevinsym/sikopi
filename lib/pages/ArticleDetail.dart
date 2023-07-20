import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ArticleDetail extends StatefulWidget {
  final String title;

  ArticleDetail({super.key, required this.title});

  @override
  _ArticleDetailState createState() => _ArticleDetailState();
}

class _ArticleDetailState extends State<ArticleDetail> {
  String body = '';
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    // Panggil metode untuk mengambil data artikel berdasarkan judul
    _fetchArticleData();
  }

  Future<void> _fetchArticleData() async {
    try {
      // Dapatkan data artikel berdasarkan judul
      QuerySnapshot articleSnapshot = await FirebaseFirestore.instance
          .collection('articles')
          .where('title', isEqualTo: widget.title)
          .limit(1)
          .get();

      if (articleSnapshot.docs.isNotEmpty) {
        // Jika artikel dengan judul yang sesuai ditemukan, ambil data artikelnya
        var articleData = articleSnapshot.docs.first.data() as Map<String, dynamic>?;

        setState(() {
          body = articleData?['body'] ?? 'Isi artikel tidak ditemukan';
          imageUrl = articleData?['imageUrl'] ?? '';
        });
      } else {
        // Jika artikel tidak ditemukan, beri tahu pengguna
        setState(() {
          body = 'Artikel tidak ditemukan';
          imageUrl = '';
        });
      }
    } catch (e) {
      // Tangani kesalahan jika terjadi saat mengambil data artikel
      setState(() {
        body = 'Error: $e';
        imageUrl = '';
      });
    }
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl.isNotEmpty)
              InkWell(
                onTap: _showImageDialog,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              body,
              style: const TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
