import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class VideoPickerTmp extends StatefulWidget {
  VideoPickerTmp({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _VideoPickerTmpState createState() => _VideoPickerTmpState();
}

class _VideoPickerTmpState extends State<VideoPickerTmp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Video Picker"),
      ),
      body: MediaGrid(),
    );
  }
}

class MediaGrid extends StatefulWidget {
  @override
  _MediaGridState createState() => _MediaGridState();
}

class _MediaGridState extends State<MediaGrid> {
  List<Widget> _mediaList = [];
  Widget _lastVideo = Container();
  int currentPage = 0;
  int lastPage;
  @override
  void initState() {
    super.initState();
    _fetchLastVideo();
    _fetchNewMedia();
  }

  _handleScrollEvent(ScrollNotification scroll) {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
      if (currentPage != lastPage) {
        _fetchNewMedia();
      }
    }
  }

  _fetchNewMedia() async {
    lastPage = currentPage;
    var result = await PhotoManager.requestPermission();
    if (result) {
      // success
//load the album list
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.video,
      );
      print(albums);
      List<AssetEntity> media =
          await albums[0].getAssetListPaged(currentPage, 60);
      print(media);
      List<Widget> temp = [];
      for (var asset in media) {
        temp.add(
          FutureBuilder(
            future: asset.thumbDataWithSize(200, 200),
            builder: (BuildContext context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done)
                return Container(
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
                            snapshot.data,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Padding(
                            padding: EdgeInsets.only(right: 5, bottom: 5),
                            child: Text(
//                              _convertDuration(asset.duration),
                              _convertDuration(asset.duration),
                              style: TextStyle(color: Colors.white),
                            )
//                          Icon(
//                            Icons.videocam,
//                            color: Colors.white,
//                          ),
                            ),
                      ),
                    ],
                  ),
                );
              return Container();
            },
          ),
        );
      }
      setState(() {
        _mediaList.addAll(temp);
        currentPage++;
      });
    } else {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
    }
  }

  _fetchLastVideo() async {
    var result = await PhotoManager.requestPermission();
    if (result) {
      // success
//load the album list
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.video,
      );
      print(albums);
      List<AssetEntity> media =
          await albums[0].getAssetListPaged(currentPage, 1);
      print(media);
      List<Widget> temp = [];
      var asset = await media[0].thumbDataWithSize(200, 200);
      _lastVideo = Container(
        height: 60,
        width: 40,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: Colors.white,
              width: 1,
            )),
        child: Stack(children: <Widget>[
          Container(
            child: Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(
                      color: Colors.white,
                      width: 1,
                    )),
                child: Image.memory(
                  asset,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ]),
      );
      setState(() {});
    } else {
      // fail
      /// if result is fail, you can call `PhotoManager.openSetting();`  to open android/ios applicaton's setting to get permission
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

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scroll) {
        _handleScrollEvent(scroll);
        return;
      },
      child: _lastVideo,
//        GridView.builder(
//            itemCount: _mediaList.length,
//            gridDelegate:
//            SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
//            itemBuilder: (BuildContext context, int index) {
//              return _mediaList[index];
//            })
    );
  }
}
