//
//  CustomCollectionViewCell.m
//  ClipsImageView
//
//  Created by 张奥 on 2020/9/17.
//  Copyright © 2020 oak. All rights reserved.
//

#import "CustomCollectionViewCell.h"

@implementation CustomCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

@end
