import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class FaceService {
  static const _platform = MethodChannel('haila.display.com/face');

  Future initialize() async {
    try {
      final resp = await _platform.invokeMethod('initialize');

      print(resp);
    } catch (e) {
      print(e);
    }
  }

  Future<List> getTemplate(List<int> pixels, int width, int height) async {
    try {
      final newPixels = Int32List.fromList(pixels);

      final resp = await _platform.invokeMethod(
        'getTemplate',
        {
          'width': width,
          'height': height,
          'pixels': newPixels,
        },
      );

      // print(resp);

      return resp;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List> getTemplateFromBuffer(
      Uint8List buffer, int width, int height) async {
    try {
      final resp = await _platform.invokeMethod(
        'getTemplateFromBuffer',
        {
          'width': width,
          'height': height,
          'pixels': buffer,
        },
      );

      // print(resp);

      return resp;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<List> getTemplateFromPath(String filePath) async {
    try {
      final resp = await _platform.invokeMethod(
        'getTemplateFromPath',
        filePath,
      );

      print(resp);
      return resp;
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<double> matchTemplates(List template1, List template2) async {
    try {
      final Uint8List t1Parsed = template1 as Uint8List;
      final Uint8List t2Parsed = template2 as Uint8List;

      final resp = await _platform.invokeMethod(
        'matchTemplates',
        [
          t1Parsed,
          t2Parsed,
        ],
      );

      print(resp);
    } catch (e) {
      print(e);
    }

    return 0;
  }
}
