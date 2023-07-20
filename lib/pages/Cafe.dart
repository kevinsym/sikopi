import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sikopi/admin/ArtikelPage.dart';
import 'package:sikopi/admin/CoffeeShopPage.dart';
import 'package:sikopi/admin/KebunKopiPage.dart';
import 'package:sikopi/admin/RoasteryPage.dart';
import 'package:sikopi/authentication/LoginPage.dart';
import 'package:sikopi/pages/homepage.dart';
import 'package:sikopi/pages/CoffeeShopDetail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sikopi/pages/Produsen.dart';

class CafePage extends StatefulWidget {
  final bool isAdmin;

  CafePage({required this.isAdmin});

  @override
  _CafePageState createState() => _CafePageState();
}

class _CafePageState extends State<CafePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman Cafe'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            if (widget.isAdmin)
              UserAccountsDrawerHeader(
                accountName: Text('Admin'), // Ganti dengan nama admin atau nama pengguna
                accountEmail: Text(
                  FirebaseAuth.instance.currentUser?.email ?? "Belum login",
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Colors.blue,
                  ),
                ),
              ),
            if (!widget.isAdmin)
              UserAccountsDrawerHeader(
                accountName: Text('User'), // Ganti dengan nama pengguna
                accountEmail: Text(
                  FirebaseAuth.instance.currentUser?.email ?? "Belum login",
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    color: Colors.blue,
                  ),
                ),
              ),
            ListTile(
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
              title: Text('Coffee Shop'),
              onTap: () {
                // Navigasi ke halaman coffee shop
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CoffeeShopPage()),
                );
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                _signOut(context); // Pass the context here
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Coffee Shop',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('coffee_shop').snapshots(), // Ubah stream ke koleksi "coffee_shop"
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Tidak ada data'));
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index];
                    var imageUrl = data['imageUrl'];
                    var title = data['title'];

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CoffeeShopDetail(title: title)), // Ubah ke CoffeeShopDetail
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AspectRatio(
                              aspectRatio: 4 / 3,
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8.0),
                                  topRight: Radius.circular(8.0),
                                ),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
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
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.coffee),
            label: 'Kopi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_cafe),
            label: 'Kafe',
          ),
        ],
        currentIndex: 2,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          print('Index = $index');
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(isAdmin: widget.isAdmin)),
            );
          } else if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProdusenPage(isAdmin: widget.isAdmin)),
            );
          }
        },
      ),
    );
  }

  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
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
            content: Text('Gagal keluar.'),
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
