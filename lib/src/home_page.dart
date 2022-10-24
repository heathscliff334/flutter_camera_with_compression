// ignore_for_file: avoid_unnecessary_containers, avoid_print
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CameraDescription>? cameras; // list available camera
  CameraController? camController;
  XFile? image;
  int _cameraOrientation = 0; // 1 = front, 0 = rear

  @override
  void initState() {
    loadCameras();

    super.initState();
  }

  loadCameras() async {
    cameras = await availableCameras();
    if (cameras != null) {
      camController =
          CameraController(cameras![_cameraOrientation], ResolutionPreset.max);

      camController!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    } else {
      print("NO any camera found");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(color: Colors.black38),
          CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                  hasScrollBody: false,
                  fillOverscroll: false,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          child: Container(
                            color: Colors.black38,
                            child: Container(
                                child: camController == null
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                            backgroundColor: Colors.black,
                                            color: Colors.white),
                                      )
                                    : !camController!.value.isInitialized
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                                backgroundColor: Colors.black,
                                                color: Colors.white),
                                          )
                                        : CameraPreview(camController!)),
                          ),
                        ),
                        // Actions
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            color: Colors.black38.withOpacity(0.5),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Container(
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        // Navigator.pop(context);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(10),
                                        color: Colors.transparent,
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                                Expanded(
                                    child: Container(
                                  padding: const EdgeInsets.all(15),
                                  child: Center(
                                      child: GestureDetector(
                                    onTap: _captureImage,
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle),
                                      child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  width: 2,
                                                  color: Colors.black38),
                                              shape: BoxShape.circle)),
                                    ),
                                  )),
                                )),
                                Expanded(
                                    child: Container(
                                  child: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (_cameraOrientation == 0) {
                                            _cameraOrientation = 1;
                                          } else {
                                            _cameraOrientation = 0;
                                          }
                                          camController = CameraController(
                                              cameras![_cameraOrientation],
                                              ResolutionPreset.max);
                                          camController!.initialize().then((_) {
                                            if (!mounted) {
                                              return;
                                            }
                                            setState(() {});
                                          });
                                        });
                                      },
                                      icon: const Icon(
                                          CupertinoIcons.camera_rotate,
                                          color: Colors.white)),
                                )),
                              ],
                            ),
                          ),
                        ),
                        // Preview captured image
                        Positioned(
                          right: 5,
                          top: 5,
                          child: Container(
                            height: 150,
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.red)),
                            child: image == null
                                ? const Center(child: Text("No Image"))
                                : Image.file(
                                    File(image!.path),
                                    height: 300,
                                  ),
                          ),
                        )
                      ],
                    ),
                  ))
            ],
          )
        ],
      ),
    );
  }

  void _captureImage() async {
    try {
      log("try taking image...");
      if (camController != null) {
        if (camController!.value.isInitialized) {
          log("take picture...");
          image = await camController!.takePicture();
          if (image != null) {
            var _image = File(image!.path);
            // Compress captured image
            var _imageCompressed = await compressFile(_image);
            final bytesCompressed = _imageCompressed.readAsBytesSync();
            // Convert to base64
            String? base64ImageCompressed = base64Encode(bytesCompressed);

            log("picture taken successfuly...");
            log(base64ImageCompressed);
            setState(() {});
          }
        } else {
          log("camController not initialized yet...");
        }
      }
    } catch (e) {
      log("catch: $e");
    }
  }

  Future<File> compressFile(File file) async {
    log("compress starting...");
    File compressedFile = await FlutterNativeImage.compressImage(file.path,
        percentage: 100, quality: 70, targetHeight: 480, targetWidth: 1037);
    log("compress finished...");
    return compressedFile;
  }
}
