//
//  RokidReplayKitExtension.h
//  RokidReplayKit
//
//  Created by 刘爽 on 2022/12/2.
//

#import <ReplayKit/ReplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RokidReplayKitExtension : NSObject

+ (void)extensionStartSampleHandler;

+ (void)extensionPaused;

+ (void)extensionResumed;

+ (void)extensionFinished;

+ (void)extensionProcessSampleBuffer:(CMSampleBufferRef)sampleBuffer
                            withType:(RPSampleBufferType)sampleBufferType;

+ (void)monitorProcessSampleBuffer:(nullable void(^)(CVPixelBufferRef sampleBuffer))sampleBuffer;
@end

NS_ASSUME_NONNULL_END
