//
//  CachedImageView.h
//  ImageSearcher
//
//  Created by Nathan Arnold on 11/5/15.
//  Copyright © 2015 Nathan Arnold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/UIImageView+WebCache.h>


@interface CachedImageView : UIImageView

//There's a lot of potential for overlap with 'setImageWithURL' so 'is' as in ImageSearcher is set as the prefix for the method name
- (void)is_setImageWithURL:(NSURL *)url;

@end
