import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camerarecording/neos_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:thumbnails/thumbnails.dart';

import 'alert_types.dart';
import 'app_colors.dart';
import 'gallery.dart';

//commit2
class AlertsCreateVideoView extends StatefulWidget {
  static const String id = '/alerts_create_video';

  AlertsCreateVideoView({this.alertType});
  final AlertTypes alertType;

  @override
  _AlertsCreateVideoViewState createState() => _AlertsCreateVideoViewState();
}

class _AlertsCreateVideoViewState extends State<AlertsCreateVideoView> {
  CameraController controller;
  String videoPath;

  List<CameraDescription> cameras;
  int selectedCameraIdx;
  bool _isRecording = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // Get the listonNewCameraSelected of available cameras.
    // Then set the first camera as selected.
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIdx = 0;
        });

        _onCameraSwitched(cameras[selectedCameraIdx]).then((void v) {});
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: kSecondaryColor),
        centerTitle: true,
        title: Text(
          handleTypeText(widget.alertType),
          style: TextStyle(color: kSecondaryColor),
        ),
        brightness: Brightness.light,
        backgroundColor: kWhiteColor,
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              child: _cameraPreviewWidget(),
//              decoration: BoxDecoration(
//                color: Colors.black,
//                border: Border.all(
//                  color: controller != null && controller.value.isRecordingVideo
//                      ? Colors.redAccent
//                      : Colors.grey,
//                  width: 3.0,
//                ),
//              ),
            ),
          ],
        ),
      ),
    );
  }

  // Display 'Loading' text when the camera is still loading.
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(kSecondaryColor)),
      );
    }

    return Stack(
      children: <Widget>[
        CameraPreview(controller),
        Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {
              _isRecording ? _onStopButtonPressed() : _onRecordButtonPressed();
              setState(() {
                _isRecording = !_isRecording;
              });
            },
            child: Container(
              height: 60,
              width: 60,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(50)),
                border: Border.all(color: Colors.white, width: 4),
//                  color: _buttonColor
              ),
              child: _isRecording
                  ? Container(
                      margin: EdgeInsets.all(15),
                      color: Colors.red,
                    )
                  : Container(
                      margin: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: Colors.red)),
            ),
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: EdgeInsets.only(right: 20, top: 10),
            child: IconButton(
              icon: Icon(
                NeosIcons.flip_camera_ios_24px,
                size: 40,
                color: Colors.white,
              ),
              onPressed: _onSwitchCamera,
            ),
          ),
        ),
        Align(
          alignment: Alignment.topLeft,
          child: Container(
            margin: EdgeInsets.only(left: 20, top: 20),
            child: Text(
              "10:10",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Container(
            margin: EdgeInsets.only(right: 20, bottom: 10),
            child: FutureBuilder(
              future: getLastImage(),
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return Container(
                    width: 40.0,
                    height: 40.0,
                  );
                }
                print("Last video");
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Gallery(),
                    ),
                  ),
                  child: Container(
                    width: 40.0,
                    height: 40.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4.0),
                      child: Image.file(
                        snapshot.data,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
//      AspectRatio(
//      aspectRatio: controller.value.aspectRatio,
//      child: CameraPreview(controller),
//    );
  }

  Future<FileSystemEntity> getLastImage() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Video';
    final myDir = Directory(dirPath);
    List<FileSystemEntity> _images;
    print("Imgaes before:");
    print(myDir.listSync(recursive: true, followLinks: false));
    _images = myDir.listSync(recursive: true, followLinks: false);
    print("Imgaes:");
    print(_images);
    _images.sort((a, b) {
      return b.path.compareTo(a.path);
    });
    print(_images);
    var lastFile = _images[0];
    var extension = path.extension(lastFile.path);
    if (extension == '.jpeg') {
      return lastFile;
    } else {
      String thumb = await Thumbnails.getThumbnail(
          videoFile: lastFile.path, imageType: ThumbFormat.PNG, quality: 30);
      return File(thumb);
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> _onCameraSwitched(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }

    controller = CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (controller.value.hasError) {
//        Fluttertoast.showToast(
//            msg: 'Camera error ${controller.value.errorDescription}',
//            toastLength: Toast.LENGTH_SHORT,
//            gravity: ToastGravity.CENTER,
//            timeInSecForIos: 1,
//            backgroundColor: Colors.red,
//            textColor: Colors.white
//        );
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onSwitchCamera() {
    selectedCameraIdx =
        selectedCameraIdx < cameras.length - 1 ? selectedCameraIdx + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIdx];

    _onCameraSwitched(selectedCamera);

    setState(() {
      selectedCameraIdx = selectedCameraIdx;
    });
  }

  void _onRecordButtonPressed() {
    _startVideoRecording().then((String filePath) {
      print("AEK Start recodring");
      if (filePath != null) {
//        Fluttertoast.showToast(
//            msg: 'Recording video started',
//            toastLength: Toast.LENGTH_SHORT,
//            gravity: ToastGravity.CENTER,
//            timeInSecForIos: 1,
//            backgroundColor: Colors.grey,
//            textColor: Colors.white
//        );
      }
    });
  }

  void _onStopButtonPressed() {
    print("AEK Stop recodring");
    _stopVideoRecording().then((_) async {
//      await GallerySaver.saveVideo(videoPath);
//      print("AEK saving to gallery");
//      final dir = Directory(videoPath);
//      dir.deleteSync(recursive: true);
//      print("AEK saving to gallery");
//      final result = await ImageGallerySaver.saveFile(videoPath);
//      print(result);
      setState(() {});
//      if (mounted) setState(() {});
    });
  }

  Future<String> _startVideoRecording() async {
    if (!controller.value.isInitialized) {
      return null;
    }

    // Do nothing if a recording is on progress
    if (controller.value.isRecordingVideo) {
      return null;
    }

    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String videoDirectory = '${appDirectory.path}/Videos';
    await Directory(videoDirectory).create(recursive: true);
    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    final String filePath = '$videoDirectory/${currentTime}.mp4';
    print("AEL: File path $filePath");
    try {
      await controller.startVideoRecording(filePath);
      videoPath = filePath;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<void> _stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);

//    Fluttertoast.showToast(
//        msg: 'Error: ${e.code}\n${e.description}',
//        toastLength: Toast.LENGTH_SHORT,
//        gravity: ToastGravity.CENTER,
//        timeInSecForIos: 1,
//        backgroundColor: Colors.red,
//        textColor: Colors.white
//    );
  }

  String handleTypeText(AlertTypes type) {
    switch (type) {
      case AlertTypes.daily_market_update: //daily market update
        return 'Daily Market Update';
      case AlertTypes.monthly_trade: //Monthly trade alert
        return 'Monthly Trade Alert';
      case AlertTypes.trading_room: //trading room alert
        return 'Trading Room';
      case AlertTypes.ready_set_trade: //ready set trade
        return 'Ready Set Trade';
      case AlertTypes.general: //Event reminder 2 days before
        return 'General';
      default:
        return 'Alert';
    }
  }

//  Widget _thumbnailWidget() {
//    return Expanded(
//      child: Align(
//        alignment: Alignment.centerRight,
//        child: Row(
//          mainAxisSize: MainAxisSize.min,
//          children: <Widget>[
//            videoController == null && imagePath == null
//                ? Container()
//                : SizedBox(
//                    child: (videoController == null)
//                        ? Image.file(File(imagePath))
//                        : Container(
//                            child: Center(
//                              child: AspectRatio(
//                                  aspectRatio:
//                                      videoController.value.size != null
//                                          ? videoController.value.aspectRatio
//                                          : 1.0,
//                                  child: VideoPlayer(videoController)),
//                            ),
//                            decoration: BoxDecoration(
//                                border: Border.all(color: Colors.pink)),
//                          ),
//                    width: 64.0,
//                    height: 64.0,
//                  ),
//          ],
//        ),
//      ),
//    );
//  }
}
