import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'classifier.dart';
import 'classifier_quant.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CIPE',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'CIPE'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Classifier _classifier;

  File? _image;
  final picker = ImagePicker();

  Image? _imageWidget;

  img.Image? fox;

  Category? category;

  @override
  void initState() {
    super.initState();
    _classifier = ClassifierQuant();
  }

  Future getImageFromCamera() async {

    final pickedFile = await picker.pickImage(
        source: ImageSource.camera, preferredCameraDevice: CameraDevice.rear);


    setState(() {
      _image = File(pickedFile!.path);
      _imageWidget = Image.file(_image!);
      _predict();
    });
  }
  Future getImageFromGallery() async {


    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, preferredCameraDevice: CameraDevice.rear);


    setState(() {
      _image = File(pickedFile!.path);
      _imageWidget = Image.file(_image!);
      _predict();
    });
  }

  void _predict() async {

    img.Image imageInput = img.decodeImage(_image!.readAsBytesSync())!;
    var pred = _classifier.predict(imageInput);

    setState(() {
      this.category = pred;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        title: Text("CIPE"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40)),
              gradient: LinearGradient(
                  colors: [Colors.lightGreen, Colors.green],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 0), // changes position of shadow
              ),
            ],
          ),

        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _image == null
                ? Container(
                    alignment: Alignment.center,
                    height: 300,
                    width: 300,
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height / 2),
                    //decoration: BoxDecoration(
                    //border: Border.all(),
                    //),
                    child: const Icon(
                      Icons.photo,
                      size: 100,
                      color: Colors.lightGreen,
                    ),
                  )
                : Container(
                    height: 300,
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height / 2),
                    decoration: BoxDecoration(

                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: _imageWidget,
                  ),

            Column(
              children: [
                Text(
                    "Predicción:",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: Colors.lightGreen),
                ),
                Text(
                  category != null ? category!.label : '',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        fit: StackFit.expand,
        children: [
          // LEFT BUTON
          Positioned(
            left: 30,
            bottom: 20,
            child:       FloatingActionButton(
              onPressed: getImageFromGallery,
              tooltip: 'Agregar desde la galería',
              child: Icon(Icons.add_photo_alternate),
              backgroundColor: Colors.lightGreen,
            ),
          ),
          // RIGHT BUTTON
          Positioned(
            bottom: 20,
            right: 30,
            child: FloatingActionButton(
            onPressed: getImageFromCamera,
            tooltip: 'Capturar',
            child: Icon(Icons.add_a_photo),
            backgroundColor: Colors.lightGreen,
          ),
          ),
          // Add more floating buttons if you want
          // There is no limit
        ],
      ),

    );
  }
}
