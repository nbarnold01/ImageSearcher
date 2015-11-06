//
//  CachedImageView.m
//  ImageSearcher
//
//  Created by Nathan Arnold on 11/5/15.
//  Copyright © 2015 Nathan Arnold. All rights reserved.
//

#import "CachedImageView.h"

@implementation CachedImageView


- (void)is_setImageWithURL:(NSURL *)url {
    
    if (url) {
        __weak typeof(self) weakSelf = self;
        self.alpha = 0;
        [self sd_setImageWithURL:url
                placeholderImage:nil
                         options:SDWebImageRetryFailed
                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                           
                           __strong typeof(self) strongSelf = weakSelf;
                           if (image && cacheType == SDImageCacheTypeNone)
                           {
                               strongSelf.alpha = 0.0;
                               [UIView animateWithDuration:.15
                                                animations:^{
                                                    strongSelf.alpha = 1.0;
                                                }];
                           } else {
                               strongSelf.alpha = 1.0;
                           }
                       }];
        
    } else {
        self.image = nil;
    }
}
@end
