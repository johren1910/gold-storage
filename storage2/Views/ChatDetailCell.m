//
//  ChatDetailCell.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <UIKit/UIKit.h>
#import "ChatMessageModel.h"
#import "ChatDetailCell.h"

@interface ChatDetailCell ()
@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;

@property (strong, nonatomic) IBOutlet UIButton *selectBtn;
@property (strong, nonatomic) IBOutlet UILabel *sizeLabel;
@property (strong, nonatomic) IBOutlet UIImageView *typeIconView;
@property (strong, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation ChatDetailCell

- (instancetype)init {
    if (self = [super init]) {
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)layoutSubviews {
    [super layoutSubviews];
   
}

- (void)setChat:(ChatMessageModel *)chat {
    
    _chat = [chat copy];
    
    self.sizeLabel.text = [NSString stringWithFormat:@"%.1f Mb", _chat.size];
//    self.thumbnailImageView.image = chat.image;
    [self.selectBtn.titleLabel setText:nil];
    
    switch (_chat.type) {
        case Video:
            self.typeIconView.image = [UIImage imageNamed:@"camera"];
            [self.typeIconView setHidden:false];
            [self.timeLabel setHidden:false];
            self.timeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)_chat.duration];
            break;
        default:
            [self.timeLabel setHidden:true];
            [self.typeIconView setHidden:true];
            break;
    }
}

@end

