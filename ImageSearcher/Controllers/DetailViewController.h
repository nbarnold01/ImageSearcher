//
//  DetailViewController.h
//  ImageSearcher
//
//  Created by Nathan Arnold on 11/5/15.
//  Copyright © 2015 Nathan Arnold. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ImageSearchResult;

@interface DetailViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@property (strong) ImageSearchResult *image;

- (void)setImageSearchResult:(ImageSearchResult *)image;

@end

