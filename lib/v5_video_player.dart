import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

final MethodChannel _channel =
    const MethodChannel('v5cn.cn/v5VideoPlayer');

class V5VideoPlayer extends StatefulWidget {

  final VideoPlayerController controller;
  final x;
  final y;
  final width;
  final height;

  V5VideoPlayer({
    Key key,
    @required this.controller,
    @required this.x,
    @required this.y,
    @required this.width,
    @required this.height,
  });

  @override
  State<StatefulWidget> createState() => _VideoPlayerState();

}

class _VideoPlayerState extends State<V5VideoPlayer> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//    return GestureDetector(
//      behavior: HitTestBehavior.opaque,
//      child: nativeView(),
//      onTap: () {
//        print("-------------------------单击了");
//      },
//      onTapUp: (TapUpDetails details) {
//        print("ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd");
//      },
//      onHorizontalDragStart: (DragStartDetails details) {
//        print("onHorizontalDragStart: ${details.globalPosition}");
//        // if (!controller.value.initialized) {
//        //   return;
//        // }
//        // _controllerWasPlaying = controller.value.isPlaying;
//        // if (_controllerWasPlaying) {
//        //   controller.pause();
//        // }
//      },
//      onHorizontalDragUpdate: (DragUpdateDetails details) {
//        print("onHorizontalDragUpdate: ${details.globalPosition}");
//        print(details.globalPosition);
//        // if (!controller.value.initialized) {
//        //   return;
//        // }
//        // seekToRelativePosition(details.globalPosition);
//      },
//      onHorizontalDragEnd: (DragEndDetails details) {
//        print("onHorizontalDragEnd");
//        // if (_controllerWasPlaying) {
//        //   controller.play();
//        // }
//      },
//      onTapDown: (TapDownDetails details) {
//        print("onTapDown: ${details.globalPosition}");
//      },
//    );
    return nativeView();
  }

  nativeView() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: 'plugins.v5_video_player/view',
        onPlatformViewCreated: onPlatformViewCreated,
        gestureRecognizers: Set()..add(Factory<TapGestureRecognizer>(() => TapGestureRecognizer())),
        creationParams: <String,dynamic>{
          "x": widget.x,
          "y": widget.y,
          "width": widget.width,
          "height": widget.height,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return UiKitView(
        viewType: 'plugins.v5_video_player/view',
        onPlatformViewCreated: onPlatformViewCreated,
        creationParams: <String,dynamic>{
          "x": widget.x,
          "y": widget.y,
          "width": widget.width,
          "height": widget.height,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
  }

  Future<void> onPlatformViewCreated(id) async {
    if (widget.controller == null) {
      return;
    }

    widget.controller.viewId = id;//(new V5VideoPlayerController.init(id));
    widget.controller.initialize();
    await widget.controller.create();
  }
}

class VideoPlayerController extends ValueNotifier<VideoPlayerValue> {
  VideoPlayerController.path(this.dataSource,
      {this.playerConfig})
      : super(VideoPlayerValue(duration: null));

  int _viewId;

  set viewId(int value) {
    _viewId = value;
  }

  String dataSource;
  PlayerConfig playerConfig;
  _VideoAppLifeCycleObserver _lifeCycleObserver;

//  @visibleForTesting
//  void set viewId => _viewId;
  bool _isDisposed = false;
  Completer<void> _creatingCompleter;
  StreamSubscription<dynamic> _eventSubscription;

  void initialize() {
    _lifeCycleObserver = _VideoAppLifeCycleObserver(this);
    _lifeCycleObserver.initialize();
    _creatingCompleter = Completer<void>();

    if (null == playerConfig) {
      playerConfig = PlayerConfig();
    }
//    //_textureId = response['textureId'];
//    _creatingCompleter.complete(null);

//    final Completer<void> initializingCompleter = Completer<void>();
    void eventListener(dynamic event) {
      final Map<dynamic, dynamic> map = event;
      final eventName = enumFromString<EventType>(EventType.values, map['event']);
      switch (eventName) {
        case EventType.PLAYER_EVENT_RENDERING_START: // 首帧渲染显示事件
          break;
        case EventType.PLAYER_EVENT_PREPARED: //准备完成事件
          break;
        case EventType.PLAYER_EVENT_LOADING_BEGIN: // loading开始
          value = value.copyWith(isBuffering: true);
          break;
        case EventType.PLAYER_EVENT_LOADING_END: //loading结束
          value = value.copyWith(isBuffering: false);
          break;
        case EventType.PLAYER_EVENT_AUTO_PLAY_START:
          value = value.copyWith(
            isPlaying: true,
            duration: Duration(milliseconds: map['duration']),
            position: Duration(milliseconds: map['position']),
          );
          break;
        case EventType.PLAYER_EVENT_CURRENT_POSITION: // 视频播放开始
          value = value.copyWith(
            isPlaying: true,
            duration: Duration(milliseconds: map['duration']),
            position: Duration(milliseconds: map['position']),
          );
          break;
//        case "PLAY_EVT_PLAY_PROGRESS": // 视频播放进度
//          value = value.copyWith(
//            isPlaying: true,
//            duration: Duration(seconds: map['duration']),
//            position: Duration(seconds: map['position']),
//          );
//          break;
        case EventType.PLAYER_EVENT_COMPLETION: // 视频播放结束
          value = value.copyWith(
            isPlaying: false,
          );
          break;
        case EventType.PLAYER_EVENT_LOOPING_START: // 视频播放循环
          value = value.copyWith(isLooping: true);
          break;
        case EventType.PLAYER_EVENT_FAIL: // 视频播放失败
          value = value.copyWith(errorDescription: map['msg']);
          break;
        default:
          print("事件没有找到" + eventName.toString());
      }
    }

    void errorListener(Object obj) {
      print(obj);
      final PlatformException e = obj;
      value = VideoPlayerValue.erroneous(e.message);
    }

    EventChannel _eventChannelFor(int viewId) {
      return EventChannel(
          'v5cn.cn/v5VideoPlayer/videoEvents$viewId');
    }
    _eventSubscription = _eventChannelFor(_viewId)
        .receiveBroadcastStream()
        .listen(eventListener, onError: errorListener);
  }

  Future<void> create() async {
    final Map<dynamic, dynamic> response =
    await _channel.invokeMethod('create', {
      "path": dataSource,
      "playerConfig": playerConfig.toJson()
    });

    _creatingCompleter.complete(null);
  }

  ///开始播放
  Future<void> play() async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    value = value.copyWith(isPlaying: true);
    if (value.isPlaying) {
      await _channel.invokeMethod(
        'start'
      );
    }
  }

  ///暂停播放
  Future<void> pause() async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    value = value.copyWith(isPlaying: false);
    if (!value.isPlaying) {
      await _channel.invokeMethod(
        'pause'
      );
    }
  }

  ///重新加载
  Future<void> reload() async {
    if (!value.initialized || _isDisposed) {
      return;
    }
    value = value.copyWith(isPlaying: false);
    if (!value.isPlaying) {
      await _channel.invokeMethod(
          'reload'
      );
    }
  }

  Future<void> dispose() async {
    if (_creatingCompleter != null) {
      await _creatingCompleter.future;
      if (!_isDisposed) {
        await _eventSubscription?.cancel();
        await _channel.invokeMethod(
          'dispose'
        );
        _isDisposed = true;
      }
      _lifeCycleObserver.dispose();
    }

    super.dispose();
  }

  ///设置是否循环播放
  Future<void> setLoop(bool loop) async {
    value = value.copyWith(isLooping: loop);
    if (!value.initialized || _isDisposed) {
      return;
    }
    _channel.invokeMethod(
      'setLoop',
      <String, dynamic>{'loop': value.isLooping},
    );
  }

  ///获取当前播放的位置
  Future<Duration> get position async {
    if (_isDisposed) {
      return null;
    }
    return Duration(
      seconds: await _channel.invokeMethod(
        'position',
        //<String, dynamic>{'textureId': _textureId},
      ),
    );
  }

  ///获取可播放的时长
  Future<Duration> get duration async {
    if (_isDisposed) {
      return null;
    }
    return Duration(
      milliseconds: await _channel.invokeMethod('getDuration'),
    );
  }

  ///获取视频宽度
  Future<Duration> get width async {
    if (_isDisposed) {
      return null;
    }
    return await _channel.invokeMethod('getVideoWidth');
  }

  ///获取视频高度
  Future<Duration> get height async {
    if (_isDisposed) {
      return null;
    }
    return await _channel.invokeMethod('getVideoHeight');
  }

  Future<Duration> get volume async {
    if (_isDisposed) {
      return null;
    }
    return await _channel.invokeMethod('getVolume');
  }

  ///跳转位置
  Future<void> seekTo(Duration moment) async {
    if (_isDisposed) {
      return;
    }
    if (moment > value.duration) {
      moment = value.duration;
    } else if (moment < const Duration()) {
      moment = const Duration();
    }
    await _channel.invokeMethod('seekTo', <String, dynamic>{
      'position': moment.inMilliseconds,
    });
    value = value.copyWith(position: moment);
  }

  ///跳转精确位置
  Future<void> seekToAccurate(Duration moment) async {
    if (_isDisposed) {
      return;
    }
    if (moment > value.duration) {
      moment = value.duration;
    } else if (moment < const Duration()) {
      moment = const Duration();
    }
    await _channel.invokeMethod('seekToAccurate', <String, dynamic>{
      'position': moment.inMilliseconds,
    });
    value = value.copyWith(position: moment);
  }

  /// 设置画面的裁剪模式
  /// @param renderMode 裁剪
  ///
  /// 图像铺满屏幕
  /// RENDER_MODE_FILL_SCREEN
  /// 图像长边填满屏幕
  /// RENDER_MODE_FILL_EDGE
  Future<void> setRenderMode(String renderMode) async {
    if (_isDisposed) {
      return;
    }
    await _channel.invokeMethod('setRenderMode', <String, dynamic>{
      //'textureId': _textureId,
      'renderMode': renderMode,
    });
    value = value.copyWith(renderMode: renderMode);
  }

  /// 设置画面的方向
  /// @param renderRotation 方向
  ///
  /// home在右边
  /// HOME_ORIENTATION_RIGHT
  /// home在下面
  /// HOME_ORIENTATION_DOWN,
  /// home在左边
  /// HOME_ORIENTATION_LEFT,
  /// home在上面
  /// HOME_ORIENTATION_UP,
  Future<void> setRenderRotation(String renderRotation) async {
    if (_isDisposed) {
      return;
    }
    await _channel.invokeMethod('setRenderRotation', <String, dynamic>{
      //'textureId': _textureId,
      'renderRotation': renderRotation,
    });
    value = value.copyWith(renderRotation: renderRotation);
  }

  Future<void> snapshot() async {
    if (_isDisposed) {
      return;
    }
    await _channel.invokeMethod('snapshot');
  }

  Future<void> setMute(bool isMute) async {
    if (_isDisposed) {
      return;
    }
    await _channel.invokeMethod('setMute', <String, dynamic>{
      'mute': isMute,
    });
    value = value.copyWith(isMute: isMute);
  }

  Future<void> setSpeed(double speed) async {
    if (_isDisposed) {
      return;
    }
    await _channel.invokeMethod('setSpeed', <String, dynamic>{
      'speed': speed,
    });
    value = value.copyWith(speed: speed);
  }

  Future<void> setMirror(bool isMirror) async {
    if (_isDisposed) {
      return;
    }
    await _channel.invokeMethod('setMirror', <String, dynamic>{
      //'textureId': _textureId,
      'mirror': isMirror,
    });
    value = value.copyWith(isMirror: isMirror);
  }
}

/// The duration, current position, buffering state, error state and settings
/// of a [VideoPlayerController].
class VideoPlayerValue {
  VideoPlayerValue({
    @required this.duration,
    this.size,
    this.position = const Duration(),
    this.buffered = const <DurationRange>[],
    this.isPlaying = false,
    this.isLooping = false,
    this.isBuffering = false,
    this.percent,
    this.kbps,
    this.isMute = false,
    this.isMirror = false,
    this.speed = 1,
    this.renderMode,
    this.renderRotation,
    this.volume = 1.0,
    this.errorDescription,
  });

  VideoPlayerValue.uninitialized() : this(duration: null);

  VideoPlayerValue.erroneous(String errorDescription)
      : this(duration: null, errorDescription: errorDescription);

  /// The total duration of the video.
  ///
  /// Is null when [initialized] is false.
  final Duration duration;

  /// The current playback position.
  final Duration position;

  /// The currently buffered ranges.
  final List<DurationRange> buffered;

  /// True if the video is playing. False if it's paused.
  final bool isPlaying;

  /// True if the video is looping.
  final bool isLooping;

  /// True if the video is currently buffering.
  final bool isBuffering;

  //缓冲百分百
  final int percent;
  //缓冲网速
  final double kbps;

  /// The current volume of the playback.
  final double volume;

  /// A description of the error if present.
  ///
  /// If [hasError] is false this is [null].
  final String errorDescription;

  /// The [size] of the currently loaded video.
  ///
  /// Is null when [initialized] is false.
  final Size size;

  final String renderMode;
  final String renderRotation;
  final bool isMute;
  final double speed;
  final bool isMirror;

  bool get initialized => duration != null;

  bool get hasError => errorDescription != null;

  double get aspectRatio => size != null ? size.width / size.height : 1.0;

  VideoPlayerValue copyWith({
    Duration duration,
    Size size,
    Duration position,
    List<DurationRange> buffered,
    bool isPlaying,
    bool isLooping,
    bool isBuffering,
    int percent,
    double kbps,
    String renderMode,
    String renderRotation,
    bool isMute,
    double speed,
    double volume,
    String errorDescription,
    bool isMirror,
  }) {
    return VideoPlayerValue(
      duration: duration ?? this.duration,
      size: size ?? this.size,
      position: position ?? this.position,
      buffered: buffered ?? this.buffered,
      isPlaying: isPlaying ?? this.isPlaying,
      isLooping: isLooping ?? this.isLooping,
      isBuffering: isBuffering ?? this.isBuffering,
      percent: percent ?? this.percent,
      kbps: kbps ?? this.kbps,
      isMute: isMute ?? this.isMute,
      isMirror: isMirror ?? this.isMirror,
      speed: speed ?? this.speed,
      renderMode: renderMode ?? this.renderMode,
      renderRotation: renderRotation ?? this.renderRotation,
      volume: volume ?? this.volume,
      errorDescription: errorDescription ?? this.errorDescription,
    );
  }

  @override
  String toString() {
    return '$runtimeType('
        'duration: $duration, '
        'size: $size, '
        'position: $position, '
        'buffered: [${buffered.join(', ')}], '
        'isPlaying: $isPlaying, '
        'isLooping: $isLooping, '
        'isBuffering: $isBuffering'
        'volume: $volume, '
        'errorDescription: $errorDescription)';
  }
}

class DurationRange {
  DurationRange(this.start, this.end);

  final Duration start;
  final Duration end;

  double startFraction(Duration duration) {
    return start.inMilliseconds / duration.inMilliseconds;
  }

  double endFraction(Duration duration) {
    return end.inMilliseconds / duration.inMilliseconds;
  }

  @override
  String toString() => '$runtimeType(start: $start, end: $end)';
}

class PlayerConfig {

  PlayerConfig({
      this.mHttpProxy = "",
      this.mReferrer,

      this.mMaxDelayTime = 0,
      this.mMaxBufferDuration = 0,
      this.mHighBufferDuration = 0,
      this.mStartBufferDuration = 0,
      this.mMaxProbeSize = 0,
      this.mClearFrameWhenStop,
      this.mEnableVideoTunnelRender = false,
      this.mEnableSEI = false,
      this.mUserAgen = "",
      this.mNetworkRetryCount = 2,
      this.mNetworkTimeout = 5000,
      this.mCustomHeaders});
  // http代理
  final String mHttpProxy;

  final String mReferrer;

  // 最大延迟
  final int mMaxDelayTime;
  // 最大缓冲区时长
  final int mMaxBufferDuration;
  // 高缓冲时长
  final int mHighBufferDuration;
  // 起播缓冲区时长。
  final int mStartBufferDuration;
  // 最大probe大小
  final int mMaxProbeSize;
  // 停止后是否清空画面
  final bool mClearFrameWhenStop;
  // 是否启用TunnelRender
  final bool mEnableVideoTunnelRender;
  final bool mEnableSEI;
  // 设置请求的ua
  final String mUserAgen;
  //网络重试次数，每次间隔networkTimeout，networkRetryCount=0则表示不重试，重试策略app决定，默认值为2
  final int mNetworkRetryCount;
  //网络超时时间。
  final int mNetworkTimeout;

  final List<String> mCustomHeaders;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'mHttpProxy': this.mHttpProxy,
    'mReferrer': this.mReferrer,
    'mNetworkTimeout': this.mNetworkTimeout,
    'mMaxBufferDuration': this.mMaxBufferDuration,
    'mHighBufferDuration': this.mHighBufferDuration,
    'mStartBufferDuration': this.mStartBufferDuration,
    'mMaxProbeSize': this.mMaxProbeSize,
    'mClearFrameWhenStop': this.mClearFrameWhenStop,
    'mEnableVideoTunnelRender': this.mEnableVideoTunnelRender,
    'mEnableVideoTunnelRender': this.mEnableVideoTunnelRender,
    'mEnableSEI': this.mEnableSEI,
    'mUserAgen': this.mUserAgen,
    'mNetworkRetryCount': this.mNetworkRetryCount,
    'mCustomHeaders': this.mCustomHeaders,
  };
}

/// APP生命周期监听
class _VideoAppLifeCycleObserver with WidgetsBindingObserver {
  _VideoAppLifeCycleObserver(this._controller);

  bool _wasPlayingBeforePause = false;
  final VideoPlayerController _controller;

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.paused:
        _wasPlayingBeforePause = _controller.value.isPlaying;
        _controller.pause();
        break;
      case AppLifecycleState.resumed:
        if (_wasPlayingBeforePause) {
          _controller.play();
        }
        break;
      default:
    }
  }
}

enum EventType {
  //准备完成事件
  PLAYER_EVENT_PREPARED,
  //视频播放失败事件
  PLAYER_EVENT_FAIL,
  //分辨率发生变化
  PLAYER_EVENT_SIZE_CHANGED,
  //首帧渲染显示事件
  PLAYER_EVENT_RENDERING_START,
  //开始自动播放
  PLAYER_EVENT_AUTO_PLAY_START,
  //缓冲位置
  PLAYER_EVENT_BUFFERED_POSITION,
  //当前播放位置
  PLAYER_EVENT_CURRENT_POSITION,
  //循环播放开始。
  PLAYER_EVENT_LOOPING_START,
  //拖动完成
  PLAYER_EVENT_SEEK_COMPLETE,
  //播放状态改变
  PLAYER_EVENT_STATE_CHANGED,
  //截图事件
  PLAYER_EVENT_SNAP_SHOT,
  //loading开始
  PLAYER_EVENT_LOADING_BEGIN,
  //缓冲进度
  PLAYER_EVENT_LOADING_PROGRESS,
  //loading结束
  PLAYER_EVENT_LOADING_END,
  //视频播放完成
  PLAYER_EVENT_COMPLETION,
}

///string转枚举类型
T enumFromString<T>(Iterable<T> values, String value) {
  return values.firstWhere((type) => type.toString().split('.').last == value,
      orElse: () => null);
}