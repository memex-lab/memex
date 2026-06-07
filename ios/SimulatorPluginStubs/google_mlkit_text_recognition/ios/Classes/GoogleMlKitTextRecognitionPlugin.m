#import "GoogleMlKitTextRecognitionPlugin.h"

@implementation GoogleMlKitTextRecognitionPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"google_mlkit_text_recognizer"
                                  binaryMessenger:[registrar messenger]];
  GoogleMlKitTextRecognitionPlugin* instance =
      [[GoogleMlKitTextRecognitionPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"vision#startTextRecognizer"]) {
    result(@{
      @"text" : @"",
      @"blocks" : @[],
    });
    return;
  }
  if ([call.method isEqualToString:@"vision#closeTextRecognizer"]) {
    result(nil);
    return;
  }
  result(FlutterMethodNotImplemented);
}

@end
