import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class RoasteryDetail extends StatefulWidget {
  final String title;

  RoasteryDetail({required this.title});

  @override
  _RoasteryDetailState createState() => _RoasteryDetailState();
}

class _RoasteryDetailState extends State<RoasteryDetail> {
  String body = '';
  String imageUrl = '';
  String ownerName = '';
  String contact = '';
  String location = '';

  @override
  void initState() {
    super.initState();
    // Panggil metode untuk mengambil data roastery berdasarkan judul
    _fetchRoasteryData();
  }

  Future<void> _fetchRoasteryData() async {
    try {
      // Dapatkan data roastery berdasarkan judul
      QuerySnapshot roasterySnapshot = await FirebaseFirestore.instance
          .collection('roastery')
          .where('title', isEqualTo: widget.title)
          .limit(1)
          .get();

      if (roasterySnapshot.docs.isNotEmpty) {
        // Jika roastery dengan judul yang sesuai ditemukan, ambil data roasterynya
        var roasteryData = roasterySnapshot.docs.first.data() as Map<String, dynamic>?;

        setState(() {
          body = roasteryData?['body'] ?? 'Roastery body not found';
          imageUrl = roasteryData?['imageUrl'] ?? '';
          ownerName = roasteryData?['ownerName'] ?? '';
          contact = roasteryData?['contact'] ?? '';
          location = roasteryData?['location'] ?? '';
        });
      } else {
        // Jika roastery tidak ditemukan, beri tahu pengguna
        setState(() {
          body = 'Roastery not found';
          imageUrl = '';
          ownerName = '';
          contact = '';
          location = '';
        });
      }
    } catch (e) {
      // Tangani kesalahan jika terjadi saat mengambil data roastery
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
