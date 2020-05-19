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
        body: AspectRatio(
          aspectRatio: 1.8,
          child: Container(
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    _switchOverlay();
                  },
                  child: videoPlayer,
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: _buildTopContainer(),//_showOverlay ? _buildTopContainer() : null,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: buildBottomContainer(),//(_showOverlay && _controller.value.initialized)? buildBottomContainer(): null,
                ),
//                Center(
//                    child: (!controller.value.initialized || controller.value.isBuffering)
//                        ? loadingWidget
//                        : null),
              ],
            ),
          ),
        ),
//        Container(
//            child: videoPlayer,
//            width: width,
//            height: height
//        ),
      ),
    );
  }

  Container buildBottomContainer() {
    String position = _controller.value.position.toString();
    if (position.lastIndexOf(".") > -1) {
      position = position.substring(0, position.lastIndexOf("."));
    }

    String duration = _controller.value.duration.toString();
    if (duration.lastIndexOf(".") > -1) {
      duration = duration.substring(0, duration.lastIndexOf("."));
    }

    return Container(
      color: Colors.black.withAlpha(127),
      child: Row(
        children: <Widget>[
          Container(
            height: 40,
            child: IconButton(
              color: Colors.white,
              highlightColor: Colors.white.withAlpha(127),
              onPressed: () {
                if (_controller.value.isPlaying) {
                  _controller.pause();
                } else {
                  if (_controller.value.position.inSeconds == _controller.value.duration?.inSeconds) {
                    _controller.seekTo(Duration(seconds: 0));
                  }
                  _controller.play();
                }
              },
              icon: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 40,
              child: _SliderWidget(_controller),
            ),
          ),
          Text(
            "$position / $duration",
            textAlign: TextAlign.end,
            style: const TextStyle(color: Colors.white),
          ),
          IconButton(
            color: Colors.white,
            highlightColor: Colors.white.withAlpha(127),
            icon: Icon(_controller.value.isMute ? Icons.volume_off : Icons.volume_up),
            onPressed: () {
              _controller.setMute(!_controller.value.isMute);
            },
          ),
          InkWell(
            child: Padding(
              padding: EdgeInsets.all(2.0),
              child: Text(
                "倍速",
                style: TextStyle(color: Colors.white),
              ),
            ),
            onTap: () {
              if (_controller.value.rate == 1.0) {
                _controller.setRate(1.5);
              } else if (_controller.value.rate == 1.5) {
                _controller.setRate(2.0);
              } else if (_controller.value.rate == 2.0) {
                _controller.setRate(0.5);
              } else if (_controller.value.rate == 0.5) {
                _controller.setRate(1.0);
              }
            },
          ),
          SizedBox(
            width: 10.0,
          )
        ],
      ),
    );
  }

  Container _buildTopContainer() {
    return Container(
      color: Colors.black.withAlpha(127),
      child: Row(
        children: <Widget>[
          Container(
            height: 40,
            child: IconButton(
              color: Colors.white,
              highlightColor: Colors.white.withAlpha(127),
              onPressed: () {},
              icon: const Icon(
                Icons.arrow_back_ios,
              ),
            ),
          ),
          Text(
            title,
            style: const TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }

  void _switchOverlay() {
    if (_showOverlay) {
      _showOverlay = false;
    } else {
      _showOverlay = true;
      _timer = Timer(Duration(milliseconds: 2000), () {
        _showOverlay = false;
        //This error happens if you call setState() on a State object for a widget that no longer appears in the widget tree
        if (mounted) setState(() {});
      });
    }
    setState(() {});
  }

//  void onViewPlayerCreated(viewPlayerController) {
//    this.viewPlayerController = viewPlayerController;
//    this.viewPlayerController.initVideo("http://vfx.mtime.cn/Video/2019/03/21/mp4/190321153853126488.mp4");
//  }
}

class _SliderWidget extends StatefulWidget {
  _SliderWidget(this.controller);

  final VideoPlayerController controller;

  @override
  _SliderWidgetState createState() =>
      _SliderWidgetState(controller.value.position.inMilliseconds.toDouble());
}

class _SliderWidgetState extends State<_SliderWidget> {
  _SliderWidgetState(this.position);

  double position;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      if (!mounted) return;
      setState(() {
        position = widget.controller.value.position.inMilliseconds.toDouble();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.controller.value.duration.inMilliseconds.toDouble() > position
        ? Slider(
        max: widget.controller.value.duration.inMilliseconds.toDouble(),
        value: position,
        onChanged: (double value) {
          setState(() {
            position = value.roundToDouble();
            widget.controller.seekTo(Duration(milliseconds: position.toInt()));
          });
        })
        : Container();
  }
}

