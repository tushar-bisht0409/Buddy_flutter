import 'dart:math';

import 'package:buddy/screens/imageviewScreen.dart';
import 'package:buddy/screens/videoviewscreen.dart';
import 'package:buddy/screens/addpostscreen.dart';
import 'package:buddy/widgets/addstory.dart';
import 'package:camera/camera.dart';
// import 'package:chatapp/Screens/CameraView.dart';
// import 'package:chatapp/Screens/VideoView.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
//import 'package:path_provider/path_provider.dart';

List<CameraDescription> cameras;

class CameraScreen extends StatefulWidget {
  static const routeName = '/camera';

  String type;
  CameraScreen(this.type);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController _cameraController;
  Future<void> cameraValue;
  bool _isReady = false;
  bool isRecoring = false;
  bool flash = false;
  bool iscamerafront = true;
  double transform = 0;

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      _cameraController = CameraController(cameras[0], ResolutionPreset.high);
      cameraValue = _cameraController.initialize();
      camReady();
    });
  }

  void camReady() {
    setState(() {
      _isReady = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _cameraController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder(
              future: cameraValue,
              builder: (context, snapshot) {
                if (_isReady) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: CameraPreview(_cameraController));
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              }),
          Positioned(
            bottom: 0.0,
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.only(top: 5, bottom: 5),
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                          icon: Icon(
                            flash ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {
                            setState(() {
                              flash = !flash;
                            });
                            flash
                                ? _cameraController
                                    .setFlashMode(FlashMode.torch)
                                : _cameraController.setFlashMode(FlashMode.off);
                          }),
                      GestureDetector(
                        onLongPress: widget.type == "Message"
                            ? () async {
                                await _cameraController.startVideoRecording();
                                setState(() {
                                  isRecoring = true;
                                });
                              }
                            : null,
                        onLongPressUp: widget.type == "Message"
                            ? () async {
                                XFile videopath = await _cameraController
                                    .stopVideoRecording();
                                setState(() {
                                  isRecoring = false;
                                });
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => VideoViewScreen(
                                              path: videopath.path,
                                            )));
                              }
                            : null,
                        onTap: () {
                          if (!isRecoring) takePhoto(context);
                        },
                        child: isRecoring
                            ? Icon(
                                Icons.radio_button_on,
                                color: Colors.red,
                                size: 80,
                              )
                            : Icon(
                                Icons.radio_button_off_rounded,
                                color: Colors.white,
                                size: 70,
                              ),
                      ),
                      IconButton(
                          icon: Transform.rotate(
                            angle: transform,
                            child: Icon(
                              Icons.flip_camera_ios,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          onPressed: () async {
                            setState(() {
                              iscamerafront = !iscamerafront;
                              transform = transform + pi;
                            });
                            int cameraPos = iscamerafront ? 0 : 1;
                            _cameraController = CameraController(
                                cameras[cameraPos], ResolutionPreset.high);
                            cameraValue = _cameraController.initialize();
                          }),
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  widget.type == "Message"
                      ? Text(
                          "Hold for Video, tap for photo",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        )
                      : SizedBox()
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void takePhoto(BuildContext context) async {
    XFile file = await _cameraController.takePicture();
    if (widget.type == "Message") {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (builder) => ImageViewScreen(
                    path: file.path,
                  )));
    } else if (widget.type == "Story") {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (builder) => AddStory("Image", file.path)));
    } else if (widget.type == "Post") {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (builder) => AddPostScreen(file.path, "image")));
    }
  }
}
