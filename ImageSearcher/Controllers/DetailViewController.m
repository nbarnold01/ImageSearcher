//
//  DetailViewController.m
//  ImageSearcher
//
//  Created by Nathan Arnold on 11/5/15.
//  Copyright © 2015 Nathan Arnold. All rights reserved.
//

#import "DetailViewController.h"
#import "ImageSearchResult.h"
#import <SDWebImage/UIImageView+WebCache.h>
@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setImageSearchResult:(ImageSearchResult *)image {
    if (_image != image) {
        _image = image;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the image.
    if (self.image) {
        self.title = [self.image title];
        [self.imageView setAccessibilityLabel:[self.image contentDescription]];
        [self.imageView sd_setImageWithURL:[self.image URL]];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
