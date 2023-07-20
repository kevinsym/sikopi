import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CoffeeShopDetail extends StatefulWidget {
  final String title;

  CoffeeShopDetail({required this.title});

  @override
  _CoffeeShopDetailState createState() => _CoffeeShopDetailState();
}

class _CoffeeShopDetailState extends State<CoffeeShopDetail> {
  String body = '';
  String imageUrl = '';
  String ownerName = '';
  String contact = '';
  String location = '';

  @override
  void initState() {
    super.initState();
    // Panggil metode untuk mengambil data coffee shop berdasarkan judul
    _fetchCoffeeShopData();
  }

  Future<void> _fetchCoffeeShopData() async {
    try {
      // Dapatkan data coffee shop berdasarkan judul
      QuerySnapshot coffeeShopSnapshot = await FirebaseFirestore.instance
          .collection('coffee_shop')
          .where('title', isEqualTo: widget.title)
          .limit(1)
          .get();

      if (coffeeShopSnapshot.docs.isNotEmpty) {
        // Jika coffee shop dengan judul yang sesuai ditemukan, ambil data coffee shopnya
        var coffeeShopData = coffeeShopSnapshot.docs.first.data() as Map<String, dynamic>?;

        setState(() {
          body = coffeeShopData?['body'] ?? 'Coffee shop body not found';
          imageUrl = coffeeShopData?['imageUrl'] ?? '';
          ownerName = coffeeShopData?['ownerName'] ?? '';
          contact = coffeeShopData?['contact'] ?? '';
          location = coffeeShopData?['location'] ?? '';
        });
      } else {
        // Jika coffee shop tidak ditemukan, beri tahu pengguna
        setState(() {
          body = 'Coffee shop not found';
          imageUrl = '';
          ownerName = '';
          contact = '';
          location = '';
        });
      }
    } catch (e) {
      // Tangani kesalahan jika terjadi saat mengambil data coffee shop
      setState(() {
        body = 'Error: $e';
        imageUrl = '';
        ownerName = '';
        contact = '';
        location = '';
      });
    }
  }

  // Fungsi untuk membuka Google Maps dengan alamat URL yang diberikan
  void _openGoogleMaps() async {
    final String googleMapsUrl = '$location';
    if (await canLaunchUrlString(googleMapsUrl)) {
      await launchUrlString(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      // Jika tidak dapat membuka Google Maps, tampilkan pesan kesalahan
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to open Google Maps.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            if (imageUrl.isNotEmpty)
              InkWell(
                onTap: () {
                  // Tampilkan gambar dalam dialog saat ditekan
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
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 16.0),
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),

            // Body Section
            Text(
              body,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),

            // Owner Section
            Text(
              'Pemilik:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(ownerName),
            Text(contact),
            SizedBox(height: 16.0),

            // Location Section
            Text(
              'Lokasi:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Tambahkan logo Google Maps yang dapat diklik
            GestureDetector(
              onTap: _openGoogleMaps,
              child: Image.asset(
                'assets/images/google_maps_logo.png',
                width: 50.0,
                height: 50.0,
              ),
            ),
            SizedBox(height: 16.0),


          ],
        ),
      ),
    );
  }
}
