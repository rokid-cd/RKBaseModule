//
//  RKThumbnailImage.h
//  RKBaseModule
//
//  Created by 刘爽 on 2023/2/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ThumbnailClosure)( UIImage * _Nullable image);

@interface RKThumbnailImage : NSObject

+ (void)thumbnailImage:(NSString *)filePath complete:(ThumbnailClosure)closure;

@end

NS_ASSUME_NONNULL_END
