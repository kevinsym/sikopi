import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:file_picker/file_picker.dart';

class AddRoasteryPage extends StatefulWidget {
  const AddRoasteryPage({super.key});

  @override
  _AddRoasteryPageState createState() => _AddRoasteryPageState();
}

class _AddRoasteryPageState extends State<AddRoasteryPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  File? _image;

  void _addRoastery() async {
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

      // Simpan data roastery beserta URL gambar ke Firebase Firestore
      FirebaseFirestore.instance.collection('roastery').add({
        'title': title,
        'body': body,
        'imageUrl': imageUrl,
        'location': location,
        'ownerName': ownerName,
        'contact': contact,
      }).then((value) {
        // Tampilkan snackbar untuk memberi tahu pengguna bahwa data roastery berhasil ditambahkan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data roastery added')),
        );

        // Clear input fields setelah data roastery ditambahkan
        _titleController.clear();
        _bodyController.clear();
        _locationController.clear();
        _ownerNameController.clear();
        _contactController.clear();
        setState(() {
          _image = null;
        });
      }).catchError((error) {
        // Tampilkan snackBar untuk memberi tahu pengguna jika terjadi kesalahan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add data roastery: $error')),
        );
      });
    } else {
      // Jika gambar tidak dipilih, simpan data roastery tanpa URL gambar
      FirebaseFirestore.instance.collection('roastery').add({
        'title': title,
        'body': body,
        'location': location,
        'ownerName': ownerName,
        'contact': contact,
      }).then((value) {
        // Tampilkan snackbar untuk memberi tahu pengguna bahwa data roastery berhasil ditambahkan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data roastery added')),
        );

        // Clear input fields setelah data roastery ditambahkan
        _titleController.clear();
        _bodyController.clear();
        _locationController.clear();
        _ownerNameController.clear();
        _contactController.clear();
      }).catchError((error) {
        // Tampilkan snackbar untuk memberi tahu pengguna jika terjadi kesalahan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add data roastery: $error')),
        );
      });
    }
  }

  void _cancelAddRoastery() {
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
        title: const Text('Add Roastery'),
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
                  hintText: 'Enter the roastery title',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  hintText: 'Enter the roastery description',
                ),
                maxLines: 8,
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter the roastery location (Google Maps URL)',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _ownerNameController,
                decoration: const InputDecoration(
                  labelText: 'Owner Name',
                  hintText: 'Enter the roastery owner name',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _contactController,
                decoration: const InputDecoration(
                  labelText: 'Contact',
                  hintText: 'Enter the roastery contact number',
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addRoastery,
                child: const Text('Save'),
              ),
              const SizedBox(height: 8.0),
              TextButton(
                onPressed: _cancelAddRoastery,
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
