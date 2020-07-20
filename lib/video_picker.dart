import 'dart:io';

import 'package:camerarecording/video_selection.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
//test tt
//test tt2
class VideoPicker extends StatefulWidget {
  @override
  _VideoPickerState createState() => _VideoPickerState();
}

class _VideoPickerState extends State<VideoPicker> {
  Widget _lastVideo = Container();
  File _videoURL;
  VideoData selectedVideo;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadLastVideo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
//          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _lastVideo,
            selectedVideo != null
                ? Container(
                    height: 200,
                    decoration: BoxDecoration(
                        border: Border.all(
                      color: Colors.white,
                      width: 1,
                    )),
                    child: Stack(
                      children: <Widget>[
//                      if (asset.type == AssetType.video)
                        Container(
                          child: Positioned.fill(
                            child: Image.memory(
                              selectedVideo.thumbDataCropped,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                              padding: EdgeInsets.only(right: 5, bottom: 5),
                              child: IconButton(
                                icon: Icon(Icons.refresh),
                                onPressed: _videoList,
                                color: Colors.white,
                              )),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                              padding: EdgeInsets.only(right: 5, bottom: 5),
                              child: Text(
                                selectedVideo.duration,
                                style: TextStyle(color: Colors.white),
                              )),
                        ),
                      ],
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  Future<void> _loadLastVideo() async {
    double radius = 5;
    double height = 70;
    double width = 50;
    double borderWidth = 2;

    var result = await PhotoManager.requestPermission();
    if (result) {
      // success
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.video,
      );
      List<AssetEntity> media = await albums[0].getAssetListPaged(0, 1);
      var asset = await media[0].thumbData;
      _lastVideo = GestureDetector(
        onTap: _videoList,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(radius)),
              border: Border.all(
                color: Colors.white,
                width: borderWidth,
              )),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Image.memory(
              asset,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
      setState(() {});
    }
  }

  Future<void> _videoList() async {
    var result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return VideoSelection();
    }));
    selectedVideo = result ?? selectedVideo;
    setState(() {});

//    print("AEK: the file");
//    if (file != null) {
//      print("AEK:$file");
//    }
  }
}
