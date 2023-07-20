import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sikopi/admin/ArtikelPage.dart';
import 'package:sikopi/admin/CoffeeShopPage.dart';
import 'package:sikopi/admin/KebunKopiPage.dart';
import 'package:sikopi/admin/RoasteryPage.dart';
import 'package:sikopi/authentication/LoginPage.dart';
import 'package:sikopi/pages/ArticleDetail.dart';
import 'package:sikopi/pages/Produsen.dart';
import 'package:sikopi/pages/Cafe.dart';

class HomePage extends StatefulWidget {
  final bool isAdmin; // Tambahkan atribut isAdmin pada constructor

  HomePage({required this.isAdmin});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  int selectedPageIndex = 1; // Indeks halaman yang dipilih pada bottom navigation bar

  @override
  void initState() {
    super.initState();
    // Set halaman default saat pertama kali diakses
    selectedPageIndex = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coffee App'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            if (widget.isAdmin) // Tampilkan drawer sesuai dengan nilai isAdmin
              ListTile(
                title: Text('Email: ${_auth.currentUser?.email ?? "Not logged in"}'),
              ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                _signOut();
              },
            ),
            if (widget.isAdmin)
              Column(
                children: [
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.article),
                    title: Text('Artikel'),
                    onTap: () {
                      // Navigasi ke halaman artikel
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ArtikelPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.local_florist),
                    title: Text('Kebun Kopi'),
                    onTap: () {
                      // Navigasi ke halaman kebun kopi
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => KebunKopiPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.local_cafe),
                    title: Text('Roastery'),
                    onTap: () {
                      // Navigasi ke halaman roastery
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RoasteryPage()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.coffee),
                    title: Text('Coffee Shop'),
                    onTap: () {
                      // Navigasi ke halaman coffee shop
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CoffeeShopPage()),
                      );
                    },
                  ),
                ],
              ),
            if (!widget.isAdmin) // Tampilkan drawer sesuai dengan nilai isAdmin
              ListTile(
                title: Text('Logout'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('articles').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('Artikel masih kosong'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var article = snapshot.data!.docs[index];
              var title = article['title'];
              var imageUrl = article['imageUrl'];

              return GestureDetector(
                onTap: () {
                  // Navigasi ke halaman ArticleDetail saat gambar atau judul artikel ditekan
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleDetail(title: title),
                    ),
                  );
                },
                child: Card(
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                          child: Image.network(imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          title,
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.coffee),
            label: 'Coffee',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_cafe),
            label: 'Cafe',
          ),
        ],
        currentIndex: selectedPageIndex, // Menandai item yang dipilih pada bottom navigation bar
        selectedItemColor: Colors.blue, // Warna item yang dipilih
        onTap: (index) {
          // Panggil setState untuk memperbarui indeks halaman yang dipilih
          setState(() {
            selectedPageIndex = index;
          });

          print('Index = $index');
          // Navigasi ke halaman ProdusenPage saat item "Coffee" diklik
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProdusenPage(isAdmin: widget.isAdmin)),
            );
          }
          // Navigasi ke halaman CafePage saat item "Cafe" diklik
          else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CafePage(isAdmin: widget.isAdmin)), // Ubah ke halaman CafePage
            );
          }
        },
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      // Refresh state untuk memperbarui tampilan drawer
      setState(() {});
      // Kembali ke halaman login setelah logout
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to sign out.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
