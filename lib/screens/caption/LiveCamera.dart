import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

class CameraLive extends StatefulWidget {
  const CameraLive({Key key}) : super(key: key);

  @override
  _CameraLiveState createState() => _CameraLiveState();
}

class _CameraLiveState extends State<CameraLive> {

  List<CameraDescription> cameras;
  CameraController cameraController;
  bool takePhoto = false;
  String resultText = "Fetching result...";

  Future<void> detectCameras() async{
    cameras = await availableCameras();
  }
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    
    takePhoto = true;
    detectCameras().then((value) {
      initializeControllers();
    });
  }
  
  void initializeControllers(){
    cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    cameraController.initialize().then((value) {

      if(!mounted){
        return;
      }

      setState(() {
        
      });

      if(takePhoto ){
        const interval = const Duration(seconds: 5);
        new Timer.periodic(interval, (Timer t)=>
          //start capturing picture
          startCapturingPictures()
        );
      }

    });
  }

  startCapturingPictures() async{
    String timeNameforPicture = DateTime.now().microsecondsSinceEpoch.toString();
    final Directory directory = await getApplicationDocumentsDirectory();
    final String dirPath = "${directory.path}/Pictures/flutter_test";
    await Directory(dirPath).create(recursive: true);
    final String filePath = "$dirPath/{$timeNameforPicture}.png";

    if(takePhoto){
      cameraController.takePicture(filePath).then((value){
        if(takePhoto){
          File imgFile = File(filePath);
          getResponse(imgFile);
        }
        else{
          return;
        }
      });
    }
  }


  Future<Map<String, dynamic>> getResponse(File imageFile) async{
    final typeData = lookupMimeType(imageFile.path, headerBytes: [0xFF, 0xD8]).split("/");

    final imgUploadRequest = http.MultipartRequest("POST", Uri.parse("http://max-image-caption-generator-itechquproject1.2886795276-80-lando01.environments.katacoda.com/model/predict"));

    final file = await http.MultipartFile.fromPath("image", imageFile.path, contentType: MediaType(typeData[0], typeData[1]));

    imgUploadRequest.fields["ext"] = typeData[1];
    imgUploadRequest.files.add(file);

    try{
      final responseUpload = await imgUploadRequest.send();
      final response = await http.Response.fromStream(responseUpload);
      final Map<String, dynamic> responseData = json.decode(response.body);
      parseResponse(responseData);
      return responseData;
    }
    catch(e){
      print(e);
      return null;
    }

  }

  parseResponse(var response){
    String result = "";
    var predictions = response["predictions"];

    for(var pred in predictions){
      var caption = pred["caption"];
      var probability = pred["probability"];
      result = result + caption + "\n\n";
    }

    setState(() {
      resultText = result;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    cameraController?.dispose();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: Image.asset("assets/jarvis.jpg").image,
            fit: BoxFit.cover,
          )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.only(top: 30.0),
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
              child: IconButton(
                color: Colors.white,
                icon: Icon(Icons.arrow_back_ios_outlined),
                onPressed: (){
                  setState(() {
                    takePhoto = false;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            (cameraController.value.isInitialized)
                ? Center(child: createCameraView(),)
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget createCameraView(){
    var size = MediaQuery.of(context).size.width / 1.2;
    return Column(
      children: [
        Container(
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
          child: Column(
            children: [
              SizedBox(height: 30,),

              Container(
                width: size,
                height: size,
                child: CameraPreview(cameraController),
              ),
              
              SizedBox(height: 30,),
              
              Text(
                "Prediction is: \n",
                style: TextStyle(
                  color: Colors.pinkAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),

              Text(
                resultText,
                style: TextStyle(fontSize: 16, color: Colors.white),
                textAlign: TextAlign.center,
              )
            ],
          ),
        )
      ],
    );
  }
}
