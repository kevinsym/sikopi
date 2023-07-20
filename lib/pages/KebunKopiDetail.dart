import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class KebunKopiDetail extends StatefulWidget {
  final String title;

  KebunKopiDetail({required this.title});

  @override
  _KebunKopiDetailState createState() => _KebunKopiDetailState();
}

class _KebunKopiDetailState extends State<KebunKopiDetail> {
  String body = '';
  String imageUrl = '';
  String ownerName = '';
  String contact = '';
  String location = '';

  @override
  void initState() {
    super.initState();
    // Panggil metode untuk mengambil data kebun kopi berdasarkan judul
    _fetchKebunKopiData();
  }

  Future<void> _fetchKebunKopiData() async {
    try {
      // Dapatkan data kebun kopi berdasarkan judul
      QuerySnapshot kebunKopiSnapshot = await FirebaseFirestore.instance
          .collection('kebun_kopi')
          .where('title', isEqualTo: widget.title)
          .limit(1)
          .get();

      if (kebunKopiSnapshot.docs.isNotEmpty) {
        // Jika kebun kopi dengan judul yang sesuai ditemukan, ambil data kebun kopinya
        var kebunKopiData = kebunKopiSnapshot.docs.first.data() as Map<String, dynamic>?;

        setState(() {
          body = kebunKopiData?['body'] ?? 'Isi kebun kopi tidak ditemukan';
          imageUrl = kebunKopiData?['imageUrl'] ?? '';
          ownerName = kebunKopiData?['ownerName'] ?? '';
          contact = kebunKopiData?['contact'] ?? '';
          location = kebunKopiData?['location'] ?? '';
        });
      } else {
        // Jika kebun kopi tidak ditemukan, beri tahu pengguna
        setState(() {
          body = 'Kebun kopi tidak ditemukan';
          imageUrl = '';
          ownerName = '';
          contact = '';
          location = '';
        });
      }
    } catch (e) {
      // Tangani kesalahan jika terjadi saat mengambil data kebun kopi
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
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      // Jika tidak dapat membuka Google Maps, tampilkan pesan kesalahan
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Gagal membuka Google Maps.'),
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
            Text(
              body,
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 16.0),
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
          ],
        ),
      ),
    );
  }
}
