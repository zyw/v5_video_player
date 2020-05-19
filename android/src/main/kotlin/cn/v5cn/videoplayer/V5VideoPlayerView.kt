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
                //TODO("Not yet implemented 播放失败的事件监听")
                //Log.d("dd","播放失败的事件监听")
            }
        })

        //准备成功事件
        aliPlayer?.setOnPreparedListener {
            //TODO("准备成功事件")
            //Log.d("dd","准备成功事件")
            //aliPlayer?.redraw()
        }

        //视频分辨率变化回调
        aliPlayer?.setOnVideoSizeChangedListener { width, height ->
            //视频分辨率变化回调
        }

        //首帧渲染显示事件
        aliPlayer?.setOnRenderingStartListener {
            //首帧渲染显示事件
            //Log.d("dd","首帧渲染显示事件")
        }

        // 其他信息的事件，type包括了：循环播放开始，缓冲位置，当前播放位置，自动播放开始等
        aliPlayer?.setOnInfoListener(object : IPlayer.OnInfoListener{
            override fun onInfo(info: InfoBean?) {
                //TODO("Not yet implemented")
                //其他信息的事件，type包括了：循环播放开始，缓冲位置，当前播放位置，自动播放开始等
                //Log.d("dd","其他信息的事件，type包括了：循环播放开始，缓冲位置，当前播放位置，自动播放开始等" + info?.code)
                if(info?.code == InfoCode.CurrentPosition) {
                    //Log.d("dd","其他信息的事件，type包括了：循环播放开始，缓冲位置，当前播放位置，自动播放开始等: " + info.extraValue)
                    //Log.d("dd", info.extraMsg)
                }

                if (info?.code == InfoCode.AutoPlayStart){
                    //自动播放开始事件。
                }

                if (info?.code == InfoCode.LoopingStart){
                    //循环播放开始事件。
                }
            }
        })

        aliPlayer?.setOnLoadingStatusListener(object : IPlayer.OnLoadingStatusListener{
            override fun onLoadingBegin() {
                //TODO("Not yet implemented")
                //缓冲开始。
            }

            override fun onLoadingProgress(percent: Int, kbps: Float) {
                //TODO("Not yet implemented")
                //缓冲进度
            }

            override fun onLoadingEnd() {
                //TODO("Not yet implemented")
                //缓冲结束
            }
        })

        //拖动结束
        aliPlayer?.setOnSeekCompleteListener {
            //拖动结束
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
            //aliPlayer?.redraw();
        }

        //截图事件
        aliPlayer?.setOnSnapShotListener(object : IPlayer.OnSnapShotListener{
            override fun onSnapShot(bm: Bitmap?, width: Int, height: Int) {
                //TODO("Not yet implemented")
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
                val mes = call.argument<Long>("position") ?: 0
                aliPlayer?.seekTo(mes)
                result.success(null)
            }
            "seekToAccurate" -> {
                val mes = call.argument<Long>("position") ?: 0
                aliPlayer?.seekTo(mes,IPlayer.SeekMode.Accurate)
                result.success(null)
            }
            "snapshot" -> {
                aliPlayer?.snapshot()
                result.success(null)
            }
            "setSpeed" -> {
                val speed = call.argument<Float>("speed") ?: 0.0F
                aliPlayer?.setSpeed(speed)
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
            else -> result.notImplemented()
        }
    }
}