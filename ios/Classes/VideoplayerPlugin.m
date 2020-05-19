#import "VideoplayerPlugin.h"
#if __has_include(<videoplayer/videoplayer-Swift.h>)
#import <videoplayer/videoplayer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "videoplayer-Swift.h"
#endif

@implementation VideoplayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftVideoplayerPlugin registerWithRegistrar:registrar];
}
@end
