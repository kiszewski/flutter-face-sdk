import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:haila_display_flutter/camera_service.dart';
import 'package:haila_display_flutter/face_service.dart';
import 'package:haila_display_flutter/image_converter.dart';
import 'package:image/image.dart' as imglib;

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  SignUpState createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  String? imagePath;
  Size? imageSize;

  List? template1;
  List? template2;
  bool pictureTaken = false;

  bool _initializing = false;

  bool isProcessing = false;

  // service injection
  final CameraService _cameraService = CameraService();
  final FaceService _faceService = FaceService();

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  _start() async {
    setState(() => _initializing = true);
    await _cameraService.initialize();
    await _faceService.initialize();
    await _cameraService.cameraController!.startImageStream((img) async {
      if (!isProcessing) {
        isProcessing = true;

        final image = convertToImage(img);
        final imgRotated = imglib.copyRotate(image, -90);

        final width = imgRotated.width;
        final height = imgRotated.height;
        final pixels = imgRotated.data;

        final template = await _faceService.getTemplate(
          pixels,
          width,
          height,
        );

        await Future.delayed(const Duration(seconds: 1));

        isProcessing = false;
      }
    });

    setState(() => _initializing = false);
  }

  Future<bool> onShot1() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // await _cameraService.cameraController?.stopImageStream();
    await Future.delayed(const Duration(milliseconds: 200));
    XFile? file = await _cameraService.takePicture();
    imagePath = file?.path;

    final template = await _faceService.getTemplateFromPath(imagePath!);

    setState(() {
      pictureTaken = true;
      template1 = template;
    });

    return true;
  }

  Future<bool> onShot2() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // await _cameraService.cameraController?.stopImageStream();
    await Future.delayed(const Duration(milliseconds: 200));
    XFile? file = await _cameraService.takePicture();
    imagePath = file?.path;

    final template = await _faceService.getTemplateFromPath(imagePath!);

    setState(() {
      pictureTaken = true;
      template2 = template;
    });

    return true;
  }

  @override
  Widget build(BuildContext context) {
    const double mirror = math.pi;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    late Widget body;
    if (_initializing) {
      body = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!_initializing && pictureTaken) {
      body = SizedBox(
        width: width,
        height: height,
        child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.rotationY(mirror),
            child: FittedBox(
              fit: BoxFit.cover,
              child: Image.file(File(imagePath!)),
            )),
      );
    }

    if (!_initializing && !pictureTaken) {
      body = Transform.scale(
        scale: 1.0,
        child: AspectRatio(
          aspectRatio: MediaQuery.of(context).size.aspectRatio,
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: SizedBox(
                width: width,
                height:
                    width * _cameraService.cameraController!.value.aspectRatio,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    CameraPreview(_cameraService.cameraController!),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          body,
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: onShot2,
                child: Text('shot 2'),
              ),
              OutlinedButton(
                onPressed: () {
                  if (template1 != null && template2 != null)
                    _faceService.matchTemplates(template1!, template2!);
                },
                child: Text('MATCH'),
              ),
            ],
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(onPressed: onShot1),
    );
  }
}
//921600 pixels