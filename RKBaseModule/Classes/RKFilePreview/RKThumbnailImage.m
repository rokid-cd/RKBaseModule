//
//  RKThumbnailImage.m
//  RKBaseModule
//
//  Created by 刘爽 on 2023/2/6.
//

#import "RKThumbnailImage.h"
#import <KSYMediaPlayer/KSYMediaInfoProber.h>

@implementation RKThumbnailImage

+ (void)thumbnailImage:(NSString *)filePath complete:(ThumbnailClosure)closure {
    NSURL *url = [NSURL URLWithString:filePath];
    KSYMediaInfoProber *prober = [[KSYMediaInfoProber alloc] initWithContentURL:url];
    prober.timeout = 15;
    UIImage *image = [prober getVideoThumbnailImageAtTime:0 width:0 height:0];
    closure(image);
}

@end
