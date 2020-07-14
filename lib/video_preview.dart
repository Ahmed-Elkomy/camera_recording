import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  const VideoPreview({this.videoPath});

  final String videoPath;
  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then(
        (_) {
          setState(() {});
        },
      );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (_controller.value.initialized) {
      return Stack(
        children: <Widget>[
          ClipRect(
            child: Container(
              child: Transform.scale(
                scale: _controller.value.aspectRatio / size.aspectRatio,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoControls(
              videoController: _controller,
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}

class VideoControls extends StatefulWidget {
  const VideoControls({this.videoController});

  final VideoPlayerController videoController;

  @override
  _VideoControlsState createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    widget.videoController.addListener(_videoListener);
    widget.videoController.setLooping(true);
    super.initState();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    widget.videoController?.removeListener(_videoListener);
    super.dispose();
  }

  void _videoListener() {
    (widget.videoController.value.isPlaying)
        ? _animationController.forward()
        : _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: const Color(0x40000000),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  '0:00',
                  style: TextStyle(color: Colors.white),
                ),
                Expanded(
                  child: VideoProgressIndicator(
                    widget.videoController,
                    allowScrubbing: true,
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    colors: VideoProgressColors(
                      playedColor: Colors.white,
                    ),
                  ),
                ),
                Text(
                  timeFormatter(widget.videoController.value.duration),
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Center(
            child: IconButton(
              iconSize: 40,
              icon: AnimatedIcon(
                icon: AnimatedIcons.play_pause,
                progress: _animationController,
                color: Colors.white,
              ),
              onPressed: _handleOnPressed,
            ),
          )
        ],
      ),
    );
  }

  String timeFormatter(Duration duration) {
    return [
      if (duration.inHours != 0) duration.inHours,
      duration.inMinutes,
      duration.inSeconds,
    ].map((seg) => seg.remainder(60).toString().padLeft(2, '0')).join(':');
  }

  void _handleOnPressed() {
    widget.videoController.value.isPlaying ? _pauseVideo() : _playVideo();
  }

  void _playVideo() {
    _animationController.forward();
    widget.videoController.play();
  }

  void _pauseVideo() {
    _animationController.reverse();
    widget.videoController.pause();
  }
}
