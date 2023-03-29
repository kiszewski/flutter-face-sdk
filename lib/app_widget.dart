import 'package:flutter/material.dart';
import 'package:haila_display_flutter/face_service.dart';
import 'package:haila_display_flutter/pages/sign_up_page.dart';

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  @override
  void initState() {
    super.initState();
    final service = FaceService();

    service.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: SignUp(),
      ),
    );
  }
}
