package cn.v5cn.videoplayer

import io.flutter.plugin.common.PluginRegistry.Registrar

/** V5VideoPlayerPlugin */
public class V5VideoPlayerPlugin {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
//  private lateinit var channel : MethodChannel
//
//  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
//    channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "videoplayer")
//    channel.setMethodCallHandler(this);
//  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      registrar.platformViewRegistry().registerViewFactory("plugins.v5_video_player/view", V5VideoPlayerViewFactory(registrar))
    }
  }

//  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
//    if (call.method == "getPlatformVersion") {
//      result.success("Android ${android.os.Build.VERSION.RELEASE}")
//    } else {
//      result.notImplemented()
//    }
//  }
//
//  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
//    channel.setMethodCallHandler(null)
//  }
}
