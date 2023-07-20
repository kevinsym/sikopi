import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:file_picker/file_picker.dart';

class AddArticlePage extends StatefulWidget {
  const AddArticlePage({super.key});

  @override
  _AddArticlePageState createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  File? _image;

  void _addArticle() async {
    String title = _titleController.text;
    String body = _bodyController.text;

    // Simpan gambar ke Firebase Storage
    if (_image != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      firebase_storage.Reference storageRef =
      firebase_storage.FirebaseStorage.instance.ref().child('images/$fileName');
      firebase_storage.UploadTask uploadTask = storageRef.putFile(_image!);
      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      // Simpan artikel beserta URL gambar ke Firebase Firestore
      FirebaseFirestore.instance.collection('articles').add({
        'title': title,
        'body': body,
        'imageUrl': imageUrl,
      }).then((value) {
        // Tampilkan snackbar untuk memberi tahu pengguna bahwa artikel berhasil ditambahkan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article added')),
        );

        // Clear input fields setelah artikel ditambahkan
        _titleController.clear();
        _bodyController.clear();
        setState(() {
          _image = null;
        });
      }).catchError((error) {
        // Tampilkan snackbar untuk memberi tahu pengguna jika terjadi kesalahan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add article: $error')),
        );
      });
    } else {
      // Jika gambar tidak dipilih, simpan artikel tanpa URL gambar
      FirebaseFirestore.instance.collection('articles').add({
        'title': title,
        'body': body,
      }).then((value) {
        // Tampilkan snackbar untuk memberi tahu pengguna bahwa artikel berhasil ditambahkan
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Article added')),
        );

        // Clear input fields setelah artikel ditambahkan
        _titleController.clear();
        _bodyController.clear();
      }).catchError((error) {
        // Tampilkan snackbar untuk memberi tahu pengguna jika terjadi kesalahan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add article: $error')),
        );
      });
    }
  }

  void _cancelAddArticle() {
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
        title: const Text('Add Article'),
      ),
      body: Padding(
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
                hintText: 'Enter the article title',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Body',
                hintText: 'Enter the article body',
              ),
              maxLines: 8,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addArticle,
              child: const Text('Save'),
            ),
            const SizedBox(height: 8.0),
            TextButton(
              onPressed: _cancelAddArticle,
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
