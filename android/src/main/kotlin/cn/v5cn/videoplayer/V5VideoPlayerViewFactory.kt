package cn.v5cn.videoplayer

import android.content.Context
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

public class V5VideoPlayerViewFactory(var registrar: PluginRegistry.Registrar) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context?, viewId: Int, args: Any?): PlatformView {
        return V5VideoPlayerView(context,viewId,args,registrar)
    }
}