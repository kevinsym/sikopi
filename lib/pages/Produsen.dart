import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sikopi/admin/ArtikelPage.dart';
import 'package:sikopi/admin/CoffeeShopPage.dart';
import 'package:sikopi/admin/KebunKopiPage.dart';
import 'package:sikopi/admin/RoasteryPage.dart';
import 'package:sikopi/authentication/LoginPage.dart';
import 'package:sikopi/pages/Cafe.dart';
import 'package:sikopi/pages/RoasteryDetail.dart';
import 'package:sikopi/pages/homepage.dart';
import 'package:sikopi/pages/KebunKopiDetail.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProdusenPage extends StatefulWidget {
  int selectedPageIndex = 0; // Indeks halaman yang dipilih pada bottom navigation bar
  final bool isAdmin; // Tambahkan atribut isAdmin pada constructor

  ProdusenPage({required this.isAdmin});

  @override
  _ProdusenPageState createState() => _ProdusenPageState();
}

class _ProdusenPageState extends State<ProdusenPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produsen Page'),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Kebun Kopi',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('kebun_kopi').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No data found'));
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index];
                    var imageUrl = data['imageUrl'];
                    var title = data['title'];

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          // Navigasi ke halaman detail kebun kopi berdasarkan judul
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => KebunKopiDetail(title: title)),
                          );
                        },
                        child: Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                                child: Image.network(
                                  imageUrl,
                                  width: 200.0,
                                  height: 150.0,
                                  fit: BoxFit.cover,
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Roastery',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('roastery').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No data found'));
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data!.docs[index];
                    var imageUrl = data['imageUrl'];
                    var title = data['title'];

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          // Navigasi ke halaman detail roastery berdasarkan judul
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RoasteryDetail(title: title)),
                          );
                        },
                        child: Card(
                          elevation: 4.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                                child: Image.network(
                                  imageUrl,
                                  width: 200.0,
                                  height: 150.0,
                                  fit: BoxFit.cover,
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
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
        currentIndex: widget.selectedPageIndex,
        selectedItemColor: Colors.blue,
        onTap: (index) {
          print('Index = $index');
          widget.selectedPageIndex = index;
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomePage(isAdmin: widget.isAdmin)),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CafePage(isAdmin: widget.isAdmin)),
            );
          }
        },
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      setState(() {});
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
