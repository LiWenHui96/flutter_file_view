#import "FlutterFileViewPlugin.h"
#if __has_include(<flutter_file_view/flutter_file_view-Swift.h>)
#import <flutter_file_view/flutter_file_view-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_file_view-Swift.h"
#endif

@implementation FlutterFileViewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterFileViewPlugin registerWithRegistrar:registrar];
}
@end
