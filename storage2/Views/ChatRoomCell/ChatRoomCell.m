//
//  ChatRoomCell.m
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

#import <UIKit/UIKit.h>
#import "ChatRoomEntity.h"
#import "ChatRoomCell.h"

@interface ChatRoomCell ()
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIImageView *circleImageView;
@end

@implementation ChatRoomCell

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
    self.contentView.backgroundColor = [UIColor systemBackgroundColor];

    self.nameLabel.textAlignment = NSTextAlignmentLeft;

    if (@available(iOS 13.0, *)) {
        self.nameLabel.textColor = [UIColor labelColor];
    } else {
        self.nameLabel.textColor = [UIColor darkTextColor];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

static NSAttributedString *AttributedStringForChat(ChatRoomEntity *chat) {
    NSMutableAttributedString *string = [NSMutableAttributedString new];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:chat.name
                                                                   attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0]}]];
    return string;
}
- (IBAction)onSelectBtnTouched:(id)sender {
    [_delegate didSelectCircle];
}

- (void)setChat:(ChatRoomEntity *)chat {
    
    _chat = [chat copy];
    
    self.nameLabel.attributedText = AttributedStringForChat(chat);
    
    if (_chat.selected) {
        self.circleImageView.image = [[UIImage imageNamed:@"circle-filled"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.circleImageView setTintColor:[UIColor darkGrayColor]];
    } else {
        self.circleImageView.image = [[UIImage imageNamed:@"circle-empty"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.circleImageView setTintColor:[UIColor darkGrayColor]];
    }
}

@end
