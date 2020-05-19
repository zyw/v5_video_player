import 'dart:async';

import 'package:flutter/material.dart';
import 'package:videoplayer/v5_video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  VideoPlayerController _controller;

  bool _showOverlay = false;
  Timer _timer;
  final String title = "播放器播放测试标题";

  VoidCallback _listener;

  @override
  void initState() {
    super.initState();
     _controller = VideoPlayerController.path(
        "http://vfx.mtime.cn/Video/2019/03/21/mp4/190321153853126488.mp4")
      ..initialize();

    _listener = () {
      setState(() {});
      if (_controller.value.hasError) {
        print(_controller.value);
      }
    };

    _controller?.addListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    var x = 0.0;
    var y = 0.0;
    var width = 400.0;
    var height = width * 9.0 / 16.0;

    V5VideoPlayer videoPlayer = new V5VideoPlayer(
        controller: _controller,
        x: x,
        y: y,
        width: width,
        height: height
    );
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Container(
            child: videoPlayer,
            width: width,
            height: height
        ),
      ),
    );
  }

//  void onViewPlayerCreated(viewPlayerController) {
//    this.viewPlayerController = viewPlayerController;
//    this.viewPlayerController.initVideo("http://vfx.mtime.cn/Video/2019/03/21/mp4/190321153853126488.mp4");
//  }
}
