import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jarvis/screens/caption/LiveCamera.dart';
import 'package:jarvis/screens/recognition/ObjectRecognition.dart';
import 'package:mime/mime.dart';
import 'package:http/http.dart' as http;

class ImageCaptionGenerator extends StatefulWidget {
  const ImageCaptionGenerator({Key key}) : super(key: key);

  @override
  _ImageCaptionGeneratorState createState() => _ImageCaptionGeneratorState();
}

class _ImageCaptionGeneratorState extends State<ImageCaptionGenerator> {

  bool _loading = true;
  File image;
  String resultText = "Fetching result...";
  final pickerImage = ImagePicker();

  Future<Map<String, dynamic>> getResponse(File imageFile) async{
    final typeData = lookupMimeType(imageFile.path, headerBytes: [0xFF, 0xD8]).split("/");

    final imgUploadRequest = http.MultipartRequest("POST", Uri.parse("http://max-image-caption-generator-itechquproject1.2886795278-80-elsy07.environments.katacoda.com/model/predict"));

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


  pickImageFromGallery() async{
    var imageFile = await pickerImage.getImage(source: ImageSource.gallery);
    if(imageFile != null){
      setState(() {
        image = File(imageFile.path);
        _loading = false;
      });

      var res = getResponse(image);
    }
  }

  captureImageWithCamera() async{
    var imageFile = await pickerImage.getImage(source: ImageSource.camera);
    if(imageFile != null){
      setState(() {
        image = File(imageFile.path);
        _loading = false;
      });

      var res = getResponse(image);
    }
  }

  Future<bool> _onBackPressed() {
    return showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: roundedButton(
                "No", Color(0xFF212121), const Color(0xFFFFFFFF)),
          ),
          new GestureDetector(
            onTap: () => Navigator.of(context).pop(true),
            child: roundedButton(
                " Yes ", const Color(0xFFFFC107), const Color(0xFFFFFFFF)),
          ),
        ],
      ),
    ) ?? false;
  }

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = new Container(
      padding: EdgeInsets.all(5.0),
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        color: bgColor,
        borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF696969),
            offset: Offset(1.0, 6.0),
            blurRadius: 0.001,
          ),
        ],
      ),
      child: Text(
        buttonLabel,
        style: new TextStyle(
            color: textColor, fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
    return loginBtn;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: Image.asset("assets/jarvis.jpg").image,
                fit: BoxFit.cover,
              )
            ),
            child: Container(
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Center(
                    child: _loading
                        // if true - display user interface for pick image or capture image or live image
                        ? Container(
                          padding: EdgeInsets.only(top: 140.0),
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
                              SizedBox(height: 15,),
                              Container(
                                width: 250.0,
                                child: Image.asset("assets/camera.jpg"),
                              ),
                              SizedBox(height: 50.0,),
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
                                            print("Clicked...");
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>CameraLive()));
                                          },
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.camera_front, size: 40, color: Colors.white,),
                                              Text("Live Camera", style: TextStyle(
                                                fontSize: 10,color: Colors.white, fontWeight: FontWeight.bold
                                              ),)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 4.0,),

                                  // Pick Image from galary
                                  SizedBox.fromSize(
                                    size: Size(80,80),
                                    child: ClipOval(
                                      child: Material(
                                        color: Colors.blueGrey[600],
                                        child: InkWell(
                                          splashColor: Colors.green,
                                          onTap: (){
                                            pickImageFromGallery();
                                            print("Clicked...");
                                          },
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.photo, size: 40, color: Colors.white,),
                                              Text("Gallery", style: TextStyle(
                                                fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold
                                              ),)
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(width: 4.0,),

                                  // capture image from camera
                                  SizedBox.fromSize(
                                    size: Size(80,80),
                                    child: ClipOval(
                                      child: Material(
                                        color: Colors.blueGrey[600],
                                        child: InkWell(
                                          splashColor: Colors.green,
                                          onTap: (){
                                            captureImageWithCamera();
                                            print("Clicked...");
                                          },
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.camera_alt,color: Colors.white, size: 40,),
                                              Text("Camera", style: TextStyle(
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

                              SizedBox(height: 50.0,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>ObjectRecognition()));
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width - 140,
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 17),
                                      decoration: BoxDecoration(
                                          color: Colors.blueGrey[600],
                                          borderRadius: BorderRadius.circular(15)),
                                      child: Text(
                                        'OBJECT RECOGNITION',
                                        style: TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20.0,),

                            ],
                          ),
                        )

                        // implement/ display ui for showing results it means caption acording image by appling algo
                        : Container(
                            color: Colors.black54,
                            padding: EdgeInsets.only(top: 30.0),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  height: 200.0,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: IconButton(
                                          onPressed: (){
                                            print("clicked");
                                            setState(() {
                                              resultText = "Fetching result...";
                                              _loading = true;
                                            });
                                          },
                                          icon: Icon(Icons.arrow_back_ios_outlined),
                                            color: Colors.white,
                                        ),
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width - 140,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Image.file(image, fit: BoxFit.fill,),
                                        ),
                                      )
                                    ],
                                  ),
                                ),

                                SizedBox(height: 30.0,),

                                Container(
                                  child: Text(
                                    "Prediction is: ",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.pink, fontSize: 16.0),
                                  ),
                                ),

                                SizedBox(height: 30.0,),

                                Container(
                                  child: Text(
                                    resultText,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  )
                ],
              ),
            ),
          )
      ),
    );
  }
}
