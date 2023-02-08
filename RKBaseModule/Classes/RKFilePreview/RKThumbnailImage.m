//
//  RKThumbnailImage.m
//  RKBaseModule
//
//  Created by 刘爽 on 2023/2/6.
//

#import "RKThumbnailImage.h"
#import <KSYMediaPlayer/KSYMediaInfoProber.h>

@implementation RKThumbnailImage

+ (void)thumbnailImage:(NSURL *)fileUrl complete:(ThumbnailClosure)closure {
    KSYMediaInfoProber *prober = [[KSYMediaInfoProber alloc] initWithContentURL:fileUrl];
    prober.timeout = 15;
    UIImage *image = [prober getVideoThumbnailImageAtTime:0 width:0 height:0];
    closure(image);
}

@end
