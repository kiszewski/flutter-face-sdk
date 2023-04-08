import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:haila_display_flutter/camera_service.dart';
import 'package:haila_display_flutter/face_service.dart';
import 'package:haila_display_flutter/image_converter.dart';
import 'package:haila_display_flutter/image_converter_service.dart';
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

  bool isComparing = false;
  bool isMatch = false;
  bool _initializing = false;
  bool isProcessing = false;

  // service injection
  final CameraService _cameraService = CameraService();
  final FaceService _faceService = FaceService();
  final ImageConverterService _imgService = ImageConverterService();

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _imgService.dispose();
    super.dispose();
  }

  _start() async {
    setState(() => _initializing = true);
    await _cameraService.initialize();
    await _faceService.initialize();
    await _imgService.initialize();

    await _cameraService.cameraController!
        .startImageStream(_onReceiveCameraStream);

    setState(() => _initializing = false);
  }

  _onReceiveCameraStream(CameraImage img) async {
    if (!isProcessing) {
      isProcessing = true;

      final image = await _imgService.convert(img);

      if (image == null) {
        isProcessing = false;
        return;
      }

      // final image = imglib.Image(10, 10);
      final imgRotated = imglib.copyRotate(image, -90);

      final width = imgRotated.width;
      final height = imgRotated.height;
      final pixels = imgRotated.data;

      final template = await _faceService.getTemplate(pixels, width, height);

      if (template1 != null) {
        setState(() => isComparing = true);
        final isMatched =
            await _faceService.matchTemplates(template, template1!);

        setState(() => isMatch = isMatched);
        setState(() => isComparing = false);
      }

      await Future.delayed(const Duration(seconds: 1));

      isProcessing = false;
    }
  }

  Future<bool> onShot1() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _cameraService.cameraController?.stopImageStream();
    await Future.delayed(const Duration(milliseconds: 200));
    XFile? file = await _cameraService.takePicture();
    imagePath = file?.path;

    final template = await _faceService.getTemplateFromPath(imagePath!);

    setState(() {
      template1 = template;
    });

    await _cameraService.cameraController
        ?.startImageStream(_onReceiveCameraStream);

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    late Widget body;
    if (_initializing) body = const Center(child: CircularProgressIndicator());

    if (!_initializing) {
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
          if (isComparing)
            const Align(
              alignment: Alignment.topLeft,
              child: CircularProgressIndicator(),
            ),
          if (isMatch)
            const Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.check,
                  size: 32,
                  color: Colors.green,
                )),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
          onPressed: onShot1, child: const Icon(Icons.camera)),
    );
  }
}
//921600 pixels