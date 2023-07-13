//
//  StorageTableCell.m
//  storage2
//
//  Created by LAP14885 on 12/07/2023.
//

#import "StorageTableCell.h"
#import <Foundation/Foundation.h>
#import "FileHelper.h"

@interface StorageTableCell ()
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *percentLabel;
@property (strong, nonatomic) IBOutlet UILabel *sizeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *checkImageView;
@property (strong, nonatomic) StorageSpaceItem *currentItem;
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

-(void)awakeFromNib {
    [self _setupView];
    [super awakeFromNib];
}

-(void)_setupView {
    [_nameLabel setTextColor:UIColor.blackColor];
    [_percentLabel setTextColor:UIColor.lightGrayColor];
    [_sizeLabel setTextColor:UIColor.lightGrayColor];
    _checkImageView.image = [[UIImage imageNamed:@"check-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

-(void)setItem:(StorageSpaceItem*)item {
    NSString* name = @"Misc";
    switch (item.fileType) {
        case Video:
            name = @"Video";
            break;
        case Picture:
            name = @"Picture";
            break;
        case Misc:
            name = @"Misc";
            break;
    }
    [_nameLabel setText:name];
    NSString *percentText = [NSString stringWithFormat:@"%.1f%%", (item.percent*100)];
    [_percentLabel setText:percentText];
    [_sizeLabel setText: [FileHelper sizeStringFormatterFromBytes:item.size]];
    NSString* iconName = @"check-icon";
    if (item.selected) {
        iconName = @"check-icon-filled";
    }
    
    UIImage* image = [[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    self.checkImageView.image = image;
    [_checkImageView setTintColor:item.color];
    
    _currentItem = item;
}

-(void)didTouch {
    
    NSString* iconName = @"check-icon";
    if (!_currentItem.selected) {
        iconName = @"check-icon-filled";
    }
    
    UIImage* image = [[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [UIView transitionWithView:_checkImageView
            duration:0.2f
            options:UIViewAnimationOptionTransitionCrossDissolve
            animations:^{
        self.checkImageView.image = image;
    } completion:nil];
}

@end
