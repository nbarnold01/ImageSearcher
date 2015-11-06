//
//  ImageTableViewCell.h
//  ImageSearcher
//
//  Created by Nathan Arnold on 11/6/15.
//  Copyright © 2015 Nathan Arnold. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imageViews;

@property (strong) NSArray *imageReults;

@end
