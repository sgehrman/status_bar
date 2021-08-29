#import "status_barPlugin.h"
#if __has_include(<status_bar_ios/status_bar_ios-Swift.h>)
#import <status_bar_ios/status_bar_ios-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "status_bar_ios-Swift.h"
#endif

@implementation status_barPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [Swiftstatus_barPlugin registerWithRegistrar:registrar];
}
@end
