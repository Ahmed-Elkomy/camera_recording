import 'package:camerarecording/video_selection.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class LastVideo extends StatefulWidget {
  @override
  _LastVideoState createState() => _LastVideoState();
}

class _LastVideoState extends State<LastVideo> {
  Widget _lastVideo = Container();
  VideoData selectedVideo;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadLastVideo(),
      builder: (context, snapshot) => _lastVideo,
    );
  }

  Future<void> _loadLastVideo() async {
    double radius = 5;
    double height = 60;
    double width = 50;
    double borderWidth = 2;
    Color borderColor = Colors.white;

    var result = await PhotoManager.requestPermission();
    if (result) {
      // success
      AssetPathEntity path = AssetPathEntity(name: "Movies");
      List<AssetEntity> media = await path.getAssetListPaged(0, 1);
      print(media);
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.video,
      );
      print(albums);
//      List<AssetEntity> media = await albums[0].getAssetListPaged(0, 1);
      var asset = await media[0].thumbData;
      print(asset);
      _lastVideo = GestureDetector(
        onTap: _videoList,
        child: Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(radius)),
              border: Border.all(
                color: borderColor,
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
//      setState(() {});
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
