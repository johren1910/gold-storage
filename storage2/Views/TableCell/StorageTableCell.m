//
//  StorageTableCell.m
//  storage2
//
//  Created by LAP14885 on 12/07/2023.
//

#import "StorageTableCell.h"
#import <Foundation/Foundation.h>

@interface StorageTableCell ()
@property (strong, nonatomic) IBOutlet UIImageView *checkImageView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *percentLabel;
@property (strong, nonatomic) IBOutlet UILabel *sizeLabel;

@end

@implementation StorageTableCell

- (instancetype)init {
    if (self == [super init]) {
        [self _setupView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        [self _setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self == [super initWithCoder:coder]) {
        [self _setupView];
    }
    return self;
}

-(void)_setupView {
    [_nameLabel setTextColor:UIColor.blackColor];
    [_percentLabel setTextColor:UIColor.lightGrayColor];
    [_sizeLabel setTextColor:UIColor.lightGrayColor];
}

-(void)setItem:(StorageSpaceItem*)item {
    [_nameLabel setText:item.name];
    NSString *percentText = [NSString stringWithFormat:@"%.1f%%", (item.percent*100)];
    [_percentLabel setText:percentText];
    [_sizeLabel setText: item.space];
}

@end
