import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import 'package:jarvis/MySplashScreen.dart';

List<CameraDescription> cameras;

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jarvis Object Detection',
      home: MySlashScreen(),
    );
  }
}
