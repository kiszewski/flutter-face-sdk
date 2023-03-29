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

  Future<List> getTemplate(Uint8List bytes, int width, int height) async {
    try {
      final resp = await _platform.invokeMethod(
        'getTemplate',
      );

      print(resp);
    } catch (e) {
      print(e);
    }

    return [];
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
