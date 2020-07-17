import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class VideoSelection extends StatefulWidget {
  @override
  _VideoSelectionState createState() => _VideoSelectionState();
}

class _VideoSelectionState extends State<VideoSelection> {
  List<VideoData> _mediaList = [];
  int currentPage = 0;
  int lastPage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchNewMedia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scroll) {
            _handleScrollEvent(scroll);
            return;
          },
          child: GridView.builder(
              itemCount: _mediaList.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context, _mediaList[index]);
                  },
                  child: _mediaList[index].video,
                );
              }),
        ),
      ),
    );
  }

  _fetchNewMedia() async {
    lastPage = currentPage;
    var result = await PhotoManager.requestPermission();
    if (result) {
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.video,
      );

      List<AssetEntity> media =
          await albums[0].getAssetListPaged(currentPage, 60);
      List<VideoData> temp = [];
      for (var asset in media) {
        VideoData videoData = VideoData();
        videoData.thumbDataCropped = await asset.thumbDataWithSize(600, 600);
        videoData.thumbData = await asset.thumbData;
        videoData.file = await asset.file;
        videoData.duration = _convertDuration(asset.duration);

        videoData.video = Container(
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
                    videoData.thumbData,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                    padding: EdgeInsets.only(right: 5, bottom: 5),
                    child: Text(
                      videoData.duration,
                      style: TextStyle(color: Colors.white),
                    )),
              ),
            ],
          ),
        );
        temp.add(videoData);
      }
      setState(() {
        _mediaList.addAll(temp);
        currentPage++;
      });
    }
  }

  _handleScrollEvent(ScrollNotification scroll) {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
      if (currentPage != lastPage) {
        _fetchNewMedia();
      }
    }
  }

  String _convertDuration(int duration) {
    int minutes = (duration / 60).toInt();
    int hours = (duration / 60 / 60).toInt();
    int seconds = (duration % 60);
    String strHours = "";
    String strMinutes = minutes.toString();
    String strSeconds = seconds.toString();
    if (hours > 0) {
      minutes -= 60;
      strMinutes = minutes.toString();
      strHours = "0$hours";
    }

    if (strMinutes.length < 2) {
      strMinutes = "0$strMinutes";
    }
    if (strSeconds.length < 2) {
      strSeconds = "0$strSeconds";
    }
    if (strHours == "") {
      return "$strMinutes:$strSeconds";
    } else {
      return "$strHours:$strMinutes:$strSeconds";
    }
  }
}

class VideoData {
  Widget video;
  File file;
  Uint8List thumbData;
  Uint8List thumbDataCropped;
  String duration;
  VideoData({this.video, this.file, this.thumbData, this.duration});
}
