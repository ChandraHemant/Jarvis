import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:jarvis/main.dart';


class ObjectRecognition extends StatefulWidget {
  const ObjectRecognition({Key key}) : super(key: key);

  @override
  _ObjectRecognitionState createState() => _ObjectRecognitionState();
}

class _ObjectRecognitionState extends State<ObjectRecognition> {

  CameraController cameraController;
  CameraImage cameraImage;
  String result = "";
  bool isWorking = false;

  loadModel() async{
    await Tflite.loadModel(
      model: "assets/models/mobilenet_v1_1.0_224.tflite",
      labels: "assets/models/mobilenet_v1_1.0_224.txt",
      // model: "assets/models/model.tflite",
      // labels: "assets/models/labels.txt"
    );
  }


  initCamera(){
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    cameraController.initialize().then((value){
      if(!mounted){
        return;
      }
      setState(() {
        cameraController.startImageStream((imageFromStream) => {
          if(!isWorking){
            isWorking = true,
            cameraImage = imageFromStream,
            runModelOnStreamFrames(),
          }
        });
      });
    });
  }

  runModelOnStreamFrames() async{
    if(cameraImage != null){
      var recognitions = await Tflite.runModelOnFrame(
          bytesList: cameraImage.planes.map((plane){
            return plane.bytes;
          }).toList(),

        imageHeight: cameraImage.height,
        imageWidth: cameraImage.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 2,
        threshold: 0.1,
        asynch: true,
      );

      result = "";

      recognitions.forEach((response) {
        result += response["label"] + " " + (response["confidence"] as double). toStringAsFixed(2) + "\n\n";
      });

      setState(() {
        result;
      });

      isWorking = false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadModel();
  }

  void dispose() async{
    super.dispose();
    await Tflite.close();
    cameraController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/jarvis.jpg"),
                fit: BoxFit.fitHeight,
              )
            ),
            child: Column(
              children: [
                Stack(
                  children: <Widget>[
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.black26,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                spreadRadius: 5,
                                blurRadius: 7,
                              )
                            ]
                        ),
                        height: 320,
                        width: 360,
                        child: Image.asset("assets/camera.jpg"),
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: initCamera,
                        child: Container(
                            margin: EdgeInsets.only(top: 35),
                            height: 360,
                            width: 360,
                            child: cameraImage == null
                                ? Container(
                                  padding: EdgeInsets.only(top: 80.0),
                                  height: 270,
                                  width: 360,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          // live camera
                                          SizedBox.fromSize(
                                            size: Size(80,80),
                                            child: ClipOval(
                                              child: Material(
                                                color: Colors.blueGrey[600],
                                                child: InkWell(
                                                  splashColor: Colors.green,
                                                  onTap: (){
                                                    initCamera();
                                                  },
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(Icons.photo_camera_front, size: 40, color: Colors.white,),
                                                      Text("Live Camera", style: TextStyle(
                                                          fontSize: 10,color: Colors.white, fontWeight: FontWeight.bold
                                                      ),)
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),

                                    ],
                                  ),
                                )
                                : AspectRatio(
                                    aspectRatio: cameraController.value.aspectRatio,
                                    child: CameraPreview(cameraController),
                                  ),
                          ),
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                          )
                        ]
                    ),
                    margin: EdgeInsets.only(top: 55),
                    child: SingleChildScrollView(
                      child: Text(
                        result,
                        style: TextStyle(
                          backgroundColor: Colors.black87,
                          fontSize: 30,
                          color: Colors.white
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
