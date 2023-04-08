import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;

class ImageConverterService {
  SendPort? _sendImagePort;
  Isolate? _isolate;

  Future initialize() async {
    final port = ReceivePort();

    _isolate = await Isolate.spawn<SendPort>(_firstSpawn, port.sendPort);

    _sendImagePort = await port.first;
  }

  Future<imglib.Image?> convert(CameraImage image) async {
    if (image.format.group == ImageFormatGroup.yuv420) {
      return _sendImage(image);
    }

    return null;
  }

  void dispose() {
    _sendImagePort = null;
    _isolate?.kill();
    _isolate = null;
  }

  void _firstSpawn(SendPort port) {
    ReceivePort receivePort = ReceivePort();
    port.send(receivePort.sendPort);

    receivePort.listen((message) {
      final img = message[0];
      final sendPort = message[1];

      if (img is CameraImage) {
        final imgConverted = _convertFromYUV420(img);
        sendPort.send(imgConverted);
      }
    });
  }

  Future<imglib.Image?> _sendImage(CameraImage img) async {
    final receiver = ReceivePort();

    if (_sendImagePort != null) {
      _sendImagePort!.send([img, receiver.sendPort]);

      return await receiver.first;
    }

    return null;
  }

  imglib.Image _convertFromYUV420(CameraImage image) {
    int width = image.width;
    int height = image.height;
    var img = imglib.Image(width, height);
    const int hexFF = 0xFF000000;
    final int uvyButtonStride = image.planes[1].bytesPerRow;
    final int? uvPixelStride = image.planes[1].bytesPerPixel;
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex = uvPixelStride! * (x / 2).floor() +
            uvyButtonStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        img.data[index] = hexFF | (b << 16) | (g << 8) | r;
      }
    }
    return img;
  }
}
