import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sql_try/providers/db_helper.dart';
import 'package:sql_try/models/photo.dart';
import 'package:sql_try/utility/utility.dart';

class SQLPage extends StatefulWidget {
   
  const SQLPage({Key? key}) : super(key: key);

  @override
  State<SQLPage> createState() => _SQLPageState();
}

class _SQLPageState extends State<SQLPage> {

  late Future<XFile> imageFile;
  late Image image; 
  late DBHelper dbHelper;
  late List<Photo> images;

  @override
  void initState() {
    super.initState();
    images = [];
    dbHelper = DBHelper.db;
    refreshImages();
  }

  refreshImages(){
    dbHelper.getPhotos().then((imgs){
      setState(() {
        images.clear();
        images.addAll(imgs);
      });
    });
  }

  pickImageFromGallery(){
    ImagePicker().pickImage(source: ImageSource.gallery).then((imgFile) async{
      String imgString = Utility.base64String(await imgFile!.readAsBytes());
      Photo photo = Photo(0, imgString);
      dbHelper.save(photo);
      refreshImages();
    });
  }

  gridView(){
    return Padding(
      padding: const EdgeInsets.all(5),
      child: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 1,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: images.map((photo){
          return Utility.imageFromBase64String(photo.photoName);
        }).toList(),
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQL'),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              pickImageFromGallery();
            }, 
          ),
        ],
      ),
      body: Center(
         child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              child: gridView()
            ),
          ],
         ),
      ),
    );
  }
}