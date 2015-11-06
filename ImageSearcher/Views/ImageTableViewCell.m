//
//  ImageTableViewCell.m
//  ImageSearcher
//
//  Created by Nathan Arnold on 11/6/15.
//  Copyright © 2015 Nathan Arnold. All rights reserved.
//

#import "ImageTableViewCell.h"
#import "ImageSearchResult.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation ImageTableViewCell


- (void)setImageReults:(NSArray *)imageReults {
    
    _imageReults = imageReults;
    
    NSUInteger imageCount = [imageReults count];
    
    for (UIImageView *imageView in self.imageViews) {
        
        //Clear out the old image
        [imageView setImage:nil];
        
        //if there are enough results, assign them to the correct imageview
        if (imageCount-1 >= imageView.tag){
            ImageSearchResult *image = imageReults[imageView.tag];
            [imageView sd_setImageWithURL:[image thumbURL]];
            
        }
    }
}

@end
