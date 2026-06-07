#import "GoogleMlKitImageLabelingPlugin.h"

@implementation GoogleMlKitImageLabelingPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"google_mlkit_image_labeler"
                                  binaryMessenger:[registrar messenger]];
  GoogleMlKitImageLabelingPlugin* instance =
      [[GoogleMlKitImageLabelingPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"vision#startImageLabelDetector"]) {
    result(@[]);
    return;
  }
  if ([call.method isEqualToString:@"vision#closeImageLabelDetector"]) {
    result(nil);
    return;
  }
  result(FlutterMethodNotImplemented);
}

@end
