package cn.v5cn.videoplayer

import android.content.Context
import android.graphics.Bitmap
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.view.View
import com.aliyun.player.AliPlayer
import com.aliyun.player.AliPlayerFactory
import com.aliyun.player.IPlayer
import com.aliyun.player.bean.ErrorInfo
import com.aliyun.player.bean.InfoBean
import com.aliyun.player.bean.InfoCode
import com.aliyun.player.nativeclass.TrackInfo
import com.aliyun.player.source.UrlSource
import com.aliyun.utils.VcPlayerLog
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.platform.PlatformView


class V5VideoPlayerView(
        var context: Context?,
        private var viewId: Int,
        var args : Any?,
        var registrar: Registrar
): PlatformView,MethodCallHandler {

    private val tag: String = "V5VideoPlayerView"
    //视频画面
    private var mSurfaceView: SurfaceView? = null
    private var aliPlayer: AliPlayer?= null
    private var methodChannel: MethodChannel? = null

    private val eventSink = QueuingEventSink()
    private var eventChannel: EventChannel? = null

    init {
        initView()
    }

    private fun initView() {
//        this.methodChannel = MethodChannel(registrar.messenger(), "v5_video_player_" + viewId);
        this.methodChannel = MethodChannel(registrar.messenger(), "v5cn.cn/v5VideoPlayer");
        this.methodChannel?.setMethodCallHandler(this);

        eventChannel = EventChannel(registrar.messenger(), "v5cn.cn/v5VideoPlayer/videoEvents${viewId}")
        eventChannel?.setStreamHandler(object : EventChannel.StreamHandler{
            override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                // 把eventSink存起来
                eventSink.setDelegate(sink)
            }

            override fun onCancel(arguments: Any?) {
                eventSink.setDelegate(null)
            }
        })

        aliPlayer = AliPlayerFactory.createAliPlayer(context)
        mSurfaceView = SurfaceView(context);
        val holder = mSurfaceView!!.holder
        //增加surfaceView的监听
        holder.addCallback(object : SurfaceHolder.Callback {
            override fun surfaceCreated(surfaceHolder: SurfaceHolder) {
                VcPlayerLog.d(tag, " surfaceCreated = surfaceHolder = $surfaceHolder")
                if (aliPlayer != null) {
                    aliPlayer?.setDisplay(surfaceHolder)
                    //防止黑屏
                    aliPlayer?.redraw()
                }
            }

            override fun surfaceChanged(surfaceHolder: SurfaceHolder, format: Int, width: Int,
                                        height: Int) {
                VcPlayerLog.d(tag,
                        " surfaceChanged surfaceHolder = " + surfaceHolder + " ,  width = " + width + " , height = "
                                + height)
                if (aliPlayer != null) {
                    aliPlayer?.redraw()
                }
            }

            override fun surfaceDestroyed(surfaceHolder: SurfaceHolder) {
                VcPlayerLog.d(tag, " surfaceDestroyed = surfaceHolder = $surfaceHolder")
                if (aliPlayer != null) {
                    aliPlayer?.setDisplay(null)
                }
            }
        })

        //播放失败的事件监听
        aliPlayer?.setOnErrorListener(object : IPlayer.OnErrorListener{
            override fun onError(errorInfo: ErrorInfo?) {
                //播放失败的事件监听
                VcPlayerLog.d(tag, "播放失败" + errorInfo?.msg)
                val eventResult = HashMap<String, Any>()
                eventResult["event"] = EventType.PLAYER_EVENT_FAIL.name
                eventResult["code"] = errorInfo?.code ?: 0
                eventResult["msg"] = errorInfo?.msg ?: ""
                eventResult["extra"] = errorInfo?.extra ?: ""
                eventSink.success(eventResult)
            }
        })

        //准备成功事件
        aliPlayer?.setOnPreparedListener {
            //准备成功事件
            VcPlayerLog.d(tag, "准备成功事件")
            val eventResult = HashMap<String, Any>()
            eventResult["event"] = EventType.PLAYER_EVENT_PREPARED.name
            eventSink.success(eventResult)
        }

        //视频分辨率变化回调
        aliPlayer?.setOnVideoSizeChangedListener { width, height ->
            //视频分辨率变化回调
            VcPlayerLog.d(tag, "视频分辨率变化回调")
            val eventResult = HashMap<String, Any>()
            eventResult["event"] = EventType.PLAYER_EVENT_SIZE_CHANGED.name
            eventSink.success(eventResult)
        }

        //首帧渲染显示事件
        aliPlayer?.setOnRenderingStartListener {
            //首帧渲染显示事件
            VcPlayerLog.d(tag, "首帧渲染显示事件")
            val eventResult = HashMap<String, Any>()
            eventResult["event"] = EventType.PLAYER_EVENT_RENDERING_START.name
            eventSink.success(eventResult)
        }

        // 其他信息的事件，type包括了：循环播放开始，缓冲位置，当前播放位置，自动播放开始等
        aliPlayer?.setOnInfoListener(object : IPlayer.OnInfoListener{
            override fun onInfo(info: InfoBean?) {
                //其他信息的事件，type包括了：循环播放开始，缓冲位置，当前播放位置，自动播放开始等
                //Log.d("dd","其他信息的事件，type包括了：循环播放开始，缓冲位置，当前播放位置，自动播放开始等" + info?.code)
                when(info?.code) {
                    InfoCode.CurrentPosition -> {
                        //当前播放位置
                        VcPlayerLog.d(tag, "当前播放位置" + info.extraValue)
                        val eventResult = HashMap<String, Any>()
                        eventResult["event"] = EventType.PLAYER_EVENT_CURRENT_POSITION.name
                        eventResult["code"] = info.code.name
                        eventResult["duration"] = aliPlayer?.duration ?: 0
                        eventResult["position"] = info.extraValue
                        eventResult["msg"] = info.extraMsg ?: ""
                        eventSink.success(eventResult)
                    }
                    InfoCode.AutoPlayStart -> {
                        //自动播放开始事件。
                        VcPlayerLog.d(tag, "自动播放开始事件")
                        val eventResult = HashMap<String, Any>()
                        eventResult["event"] = EventType.PLAYER_EVENT_AUTO_PLAY_START.name
                        eventResult["code"] = info.code.name
                        eventResult["duration"] = aliPlayer?.duration ?: 0
                        eventResult["position"] = info.extraValue ?: 0
                        eventSink.success(eventResult)
                    }
                    InfoCode.LoopingStart -> {
                        //循环播放开始事件。
                        VcPlayerLog.d(tag, "循环播放开始事件")
                        val eventResult = HashMap<String, Any>()
                        eventResult["event"] = EventType.PLAYER_EVENT_LOOPING_START.name
                        eventResult["code"] = info.code.name
                        eventSink.success(eventResult)
                    }
                    InfoCode.BufferedPosition -> {
                        //缓存位置。
                        VcPlayerLog.d(tag, "缓存位置事件")
                        val eventResult = HashMap<String, Any>()
                        eventResult["event"] = EventType.PLAYER_EVENT_BUFFERED_POSITION.name
                        eventResult["code"] = info.code.name
                        eventSink.success(eventResult)
                    }
                }
            }
        })

        aliPlayer?.setOnLoadingStatusListener(object : IPlayer.OnLoadingStatusListener{
            override fun onLoadingBegin() {
                //缓冲开始。
                VcPlayerLog.d(tag, "缓冲开始")
                val eventResult = HashMap<String, Any>()
                eventResult["event"] = EventType.PLAYER_EVENT_LOADING_BEGIN.name
                eventSink.success(eventResult)
            }

            override fun onLoadingProgress(percent: Int, kbps: Float) {
                //缓冲进度
                VcPlayerLog.d(tag, "缓冲进度")
                val eventResult = HashMap<String, Any>()
                eventResult["event"] = EventType.PLAYER_EVENT_LOADING_PROGRESS.name
                //缓冲百分百
                eventResult["percent"] = percent
                //缓冲网速
                eventResult["kbps"] = kbps
                eventSink.success(eventResult)
            }

            override fun onLoadingEnd() {
                //缓冲结束
                VcPlayerLog.d(tag, "缓冲结束")
                val eventResult = HashMap<String, Any>()
                eventResult["event"] = EventType.PLAYER_EVENT_LOADING_END.name
                eventSink.success(eventResult)
            }
        })

        aliPlayer?.setOnSeiDataListener(object : IPlayer.OnSeiDataListener{
            override fun onSeiData(p0: Int, p1: ByteArray?) {
                VcPlayerLog.d(tag, "setOnSeiDataListener: " + p0 + "   " + p1?.size)
            }
        })

        //拖动结束
        aliPlayer?.setOnSeekCompleteListener {
            //拖动结束
            VcPlayerLog.d(tag, "拖动结束")
            val eventResult = HashMap<String, Any>()
            eventResult["event"] = EventType.PLAYER_EVENT_SEEK_COMPLETE.name
            eventSink.success(eventResult)
        }

        //视频播放完成
        aliPlayer?.setOnCompletionListener {
            VcPlayerLog.d(tag, "视频播放完成")
            val eventResult = HashMap<String, Any>()
            eventResult["event"] = EventType.PLAYER_EVENT_COMPLETION.name
            eventSink.success(eventResult)
        }

        //字幕
        aliPlayer?.setOnSubtitleDisplayListener(object : IPlayer.OnSubtitleDisplayListener{
            override fun onSubtitleShow(p0: Int, p1: Long, p2: String?) {
                //TODO("Not yet implemented")
            }

            override fun onSubtitleExtAdded(p0: Int, p1: String?) {
                //TODO("Not yet implemented")
            }

            override fun onSubtitleHide(p0: Int, p1: Long) {
                //TODO("Not yet implemented")
            }
        })

        //音视频流或者清晰度切换
        aliPlayer?.setOnTrackChangedListener(object : IPlayer.OnTrackChangedListener{
            override fun onChangedSuccess(trackInfo: TrackInfo?) {
                //TODO("Not yet implemented")
                //切换音视频流或者清晰度成功
            }

            override fun onChangedFail(trackInfo: TrackInfo?, errorInfo: ErrorInfo?) {
                //TODO("Not yet implemented")
                //切换音视频流或者清晰度失败
            }
        })

        //播放器状态改变事件
        aliPlayer?.setOnStateChangedListener { newState ->
            //播放器状态改变事件
            //Log.d("dd","播放器状态改变事件" + newState)
            VcPlayerLog.d(tag, "播放器状态改变事件" + newState)
            val eventResult = HashMap<String, Any>()
            eventResult["event"] = EventType.PLAYER_EVENT_STATE_CHANGED.name
            eventResult["state"] = newState
            eventSink.success(eventResult)
        }

        //截图事件
        aliPlayer?.setOnSnapShotListener(object : IPlayer.OnSnapShotListener{
            override fun onSnapShot(bm: Bitmap?, width: Int, height: Int) {
                VcPlayerLog.d(tag, "截图事件")
                val eventResult = HashMap<String, Any>()
                eventResult["event"] = EventType.PLAYER_EVENT_SNAP_SHOT.name
                eventResult["bm"] = bm!!
                eventResult["width"] = width
                eventResult["height"] = height
                eventSink.success(eventResult)
            }
        })

    }

    override fun getView(): View {
        return mSurfaceView?.rootView!!
    }

    override fun dispose() {
        aliPlayer?.stop()
        eventChannel?.setStreamHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {

            "create" -> { //初始化播放器和创建SurfaceTexture，并返回textureId供flutter的Texture使用
                val path = call.argument<String>("path")
                val urlSource = UrlSource()
                urlSource.uri = path

                aliPlayer?.setDataSource(urlSource)
                aliPlayer?.isAutoPlay = true
                aliPlayer?.prepare()
                result.success(null)
            }
            "dispose" -> {
                dispose()
                result.success(null)
            }
            "setLoop" -> {
                val loop = call.argument<Boolean>("loop") ?: false
                aliPlayer?.isLoop = loop
                result.success(null)
            }
            "start" -> {
                aliPlayer?.start()
                result.success(null)
            }
            "stop" -> {
                aliPlayer?.stop()
                result.success(null)
            }
            "reset" -> {
                aliPlayer?.reset()
                result.success(null)
            }
            "seekTo" -> {
                val mes = call.argument<Int>("position") ?: 0
                aliPlayer?.seekTo(mes.toLong())
                result.success(null)
            }
            "seekToAccurate" -> {
                val mes = call.argument<Int>("position") ?: 0
                aliPlayer?.seekTo(mes.toLong(),IPlayer.SeekMode.Accurate)
                result.success(null)
            }
            "snapshot" -> {
                aliPlayer?.snapshot()
                result.success(null)
            }
            "setSpeed" -> {
                val speed = call.argument<Double>("speed") ?: 0.0
                aliPlayer?.speed = speed.toFloat()
                result.success(null)
            }
            "setMute" -> {
                val mute = call.argument<Boolean>("mute") ?: false
                aliPlayer?.setMute(mute)
                result.success(null)
            }
            "setAutoPlay" -> {
                val autoPlay = call.argument<Boolean>("autoPlay") ?: false
                aliPlayer?.isAutoPlay = autoPlay
                result.success(null)
            }
            "reload" -> {
                aliPlayer?.reload()
                result.success(null)
            }
            "pause" -> {
                aliPlayer?.pause()
                result.success(null)
            }
            "getDuration" -> {
                val duration = aliPlayer?.duration
                result.success(duration)
            }
            "getVideoHeight" -> {
                result.success(aliPlayer?.videoHeight)
            }
            "getVideoWidth" -> {
                result.success(aliPlayer?.videoWidth)
            }
            "getVolume" -> {
                result.success(aliPlayer?.volume)
            }
            "getSpeed" -> {
                result.success(aliPlayer?.speed)
            }
            else -> result.notImplemented()
        }
    }
}