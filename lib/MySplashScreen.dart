import 'package:flutter/material.dart';
import 'package:jarvis/screens/caption/ImageCaption.dart';
import 'package:splashscreen/splashscreen.dart';

import 'package:jarvis/screens/recognition/ObjectRecognition.dart';

class MySlashScreen extends StatefulWidget {
  const MySlashScreen({Key key}) : super(key: key);

  @override
  _MySlashScreenState createState() => _MySlashScreenState();
}

class _MySlashScreenState extends State<MySlashScreen> {
  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
      seconds: 5,
      imageBackground: AssetImage("assets/back.jpg"),
      navigateAfterSeconds: new ImageCaptionGenerator(),
      useLoader: true,
      loadingText: new Text("Loading", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 25),),
      loaderColor: Colors.deepOrange,
      image: Image.asset("assets/back.jpg"),

    );
  }
}
