import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ImagePicker imagePicker;
  PickedFile image;
  List result = [
    {'confidence': 0.0, 'index': 11, 'label': '-'}
  ];
  var letter = 'U+0B85';

  Future<bool> _requestPermission() async {
    final PermissionHandler _permissionHandler = PermissionHandler();
    var result = await _permissionHandler
        .requestPermissions(<PermissionGroup>[PermissionGroup.storage]);
    if (result[PermissionGroup.storage] == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  void askPermission() async {
    await _requestPermission();
  }

  static Future<String> loadModel() async {
    return Tflite.loadModel(
      model: "assets/tamil_recog.tflite",
      labels: "assets/labels.txt",
    );
  }

  getImage() async {
    imagePicker = ImagePicker();
    image = await imagePicker.getImage(source: ImageSource.gallery);
    print('Image Path: ${image.path}');
    classifyImage();
  }

  classifyImage() async {
    result = await Tflite.runModelOnImage(path: image.path).whenComplete(() {
      setState(() {
        print('Result: $result');
      });
    });
  }

  showChar() {}

  @override
  void initState() {
    super.initState();
    askPermission();
    loadModel().whenComplete(() {
      print('Model Loaded');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Tamil Character Recognition'),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              margin: EdgeInsets.all(20),
              height: 350,
              color: Colors.blueGrey.shade200,
              child: image == null
                  ? Container()
                  : Image.file(
                      File(image.path),
                      scale: .19,
                    ),
            ),
            Column(
              children: [
                for (var element in result) ResultIndicator(result: element)
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  getImage();
                },
                child: Text('Select Image'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultIndicator extends StatelessWidget {
  ResultIndicator({
    this.result,
  });

  final Map result;

  @override
  Widget build(BuildContext context) {
    double percentD = result['confidence']*100;
    int percent = percentD.toInt();
    List letters = [
      '\u{0B85}',
      '\u{0B86}',
      '\u{0B87}',
      '\u{0B88}',
      '\u{0B89}',
      '\u{0B8A}',
      '\u{0B8E}',
      '\u{0B8F}',
      '\u{0B90}',
      '\u{0B92}',
      '\u{0B93}',
      'Not Detected'
    ];
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              text: letters[result['index']],
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
                fontSize: 30,
              ),
              children: [
                TextSpan(
                  text: ' -  ' + percent.toString() +'%',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 20),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: LinearProgressIndicator(
              value: result['confidence'],
              backgroundColor: Colors.grey.shade400,
              minHeight: 10,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
