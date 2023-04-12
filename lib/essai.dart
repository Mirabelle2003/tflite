import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePageDeux extends StatefulWidget {
  const HomePageDeux({Key? key}) : super(key: key);

  @override
  _HomePageDeuxState createState() => _HomePageDeuxState();
}

class _HomePageDeuxState extends State<HomePageDeux> {
  bool loading = true;
  late File _image;
  late List _result;
  final imagepicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    loadModel().then((val) {
      setState(() {});
    });
  }

  Future<void> detectImage(File image) async {
    var res = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 2,
        threshold: 0.6,
        imageMean: 127.5,
        imageStd: 255.0,
        asynch: true);
    setState(() {
      _result = res!;
      loading = false;
      print("voici : $_result");
    });
  }

  Future<void> loadModel() async {
    try {
      Tflite.close();
      var resultant = await Tflite.loadModel(
          model: 'assets/model_unquant.tflite',
          labels: "assets/labels.txt",
          numThreads: 1, // defaults to 1
          isAsset:
              true, // defaults to true, set to false to load resources outside assets
          useGpuDelegate:
              false // defaults to false, set to true to use GPU delegate
          );
      print("resultat $resultant");
      // await Tflite.loadModel(
      //     model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
    } on PlatformException {
      print('Failed to load model.');
    } catch (e) {
      print("erreur : $e");
    } finally {
      print("Chargement du modèle terminé.");
    }
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  Future<void> pickImageCamera() async {
    try {
      final imagePicker = ImagePicker();
      final XFile? file =
          await imagePicker.pickImage(source: ImageSource.camera);
      if (file == null) {
        return;
      } else {
        _image = File(file.path);
        print(_image);
      }
      detectImage(_image);
    } catch (e) {
      print('Erreur : $e');
    }
  }

  Future<void> pickImageGallery() async {
    try {
      final imagePicker = ImagePicker();
      final XFile? file =
          await imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null) {
        return;
      } else {
        _image = File(file.path);
        print(_image);
      }
      detectImage(_image);
    } catch (e) {
      print('Erreur : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ML Classifier',
          style: GoogleFonts.roboto(),
        ),
      ),
      body: SizedBox(
        height: h,
        width: w,
        child: Column(
          children: [
            Container(
              height: 150,
              width: 150,
              padding: const EdgeInsets.all(10),
              child: Image.asset('assets/mask.png'),
            ),
            Container(
                child: Text('Mask Detector',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ))),
            const SizedBox(height: 50),
            Container(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.teal[800],
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                        child: Text('Capture',
                            style: GoogleFonts.roboto(fontSize: 18)),
                        onPressed: () {
                          pickImageCamera();
                        }),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.teal[800],
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                        child: Text('Gallery',
                            style: GoogleFonts.roboto(fontSize: 18)),
                        onPressed: () {
                          pickImageGallery();
                        }),
                  ),
                ],
              ),
            ),
            loading != true
                ? Container(
                    child: Column(
                      children: [
                        Container(
                          height: 220,
                          // width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          child: Image.file(_image),
                        ),
                        // _result != null
                        //     ? Text(
                        //         (_result[1]['label']).toString().substring(2),
                        //         style: GoogleFonts.roboto(fontSize: 18))
                        //     : const Text(''),
                        // _result != null
                        //     ? Text('Confidence: ${_result[1]['confidence']}',
                        //         style: GoogleFonts.roboto(fontSize: 18))
                        //     : const Text('')
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }
}
