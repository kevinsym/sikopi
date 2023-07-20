import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:file_picker/file_picker.dart';

class AddCoffeeShopPage extends StatefulWidget {
  const AddCoffeeShopPage({super.key});

  @override
  _AddCoffeeShopPageState createState() => _AddCoffeeShopPageState();
}

class _AddCoffeeShopPageState extends State<AddCoffeeShopPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  File? _image;

  void _addCoffeeShop() async {
    String title = _titleController.text;
    String body = _bodyController.text;
    String location = _locationController.text;
    String ownerName = _ownerNameController.text;
    String contact = _contactController.text;

    // Simpan gambar ke Firebase Storage
    if (_image != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference storageRef =
      firebase_storage.FirebaseStorage.instance.ref().child('images/$fileName');
      firebase_storage.UploadTask uploadTask = storageRef.putFile(_image!);
      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Simpan data coffee shop beserta URL gambar ke Firebase Firestore
      FirebaseFirestore.instance.collection('coffee_shop').add({
        'title': title,
        'body': body,
        'imageUrl': imageUrl,
        'location': location,
        'ownerName': ownerName,
        'contact': contact,
      }).then((value) {
        // Tampilkan snackbar untuk memberi tahu pengguna bahwa data coffee shop berhasil ditambahkan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data coffee shop added')),
        );

        // Clear input fields setelah data coffee shop ditambahkan
        _titleController.clear();
        _bodyController.clear();
        _locationController.clear();
        _ownerNameController.clear();
        _contactController.clear();
        setState(() {
          _image = null;
        });
      }).catchError((error) {
        // Tampilkan snackbar untuk memberi tahu pengguna jika terjadi kesalahan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add data coffee shop: $error')),
        );
      });
    } else {
      // Jika gambar tidak dipilih, simpan data coffee shop tanpa URL gambar
      FirebaseFirestore.instance.collection('coffee_shop').add({
        'title': title,
        'body': body,
        'location': location,
        'ownerName': ownerName,
        'contact': contact,
      }).then((value) {
        // Tampilkan snackbar untuk memberi tahu pengguna bahwa data coffee shop berhasil ditambahkan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data coffee shop added')),
        );

        // Clear input fields setelah data coffee shop ditambahkan
        _titleController.clear();
        _bodyController.clear();
        _locationController.clear();
        _ownerNameController.clear();
        _contactController.clear();
      }).catchError((error) {
        // Tampilkan snackbar untuk memberi tahu pengguna jika terjadi kesalahan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add data coffee shop: $error')),
        );
      });
    }
  }

  void _cancelAddCoffeeShop() {
    Navigator.of(context).pop();
  }

  Future<void> _getImageFromGallery() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;
      setState(() {
        _image = File(file.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Coffee Shop'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ElevatedButton(
                onPressed: _getImageFromGallery,
                child: const Text('Add Image'),
              ),
              const SizedBox(height: 16.0),
              if (_image != null)
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(_image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter the coffee shop title',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  hintText: 'Enter the coffee shop description',
                ),
                maxLines: 8,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter the coffee shop location (Google Maps URL)',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _ownerNameController,
                decoration: const InputDecoration(
                  labelText: 'Owner Name',
                  hintText: 'Enter the coffee shop owner name',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact',
                  hintText: 'Enter the coffee shop contact number',
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addCoffeeShop,
                child: const Text('Save'),
              ),
              const SizedBox(height: 8.0),
              TextButton(
                onPressed: _cancelAddCoffeeShop,
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
