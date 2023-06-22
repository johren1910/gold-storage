//
//  ChatRoomCell.m
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

#import <UIKit/UIKit.h>
#import "ChatRoomModel.h"
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
    self.contentView.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];

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

static NSAttributedString *AttributedStringForChat(ChatRoomModel *chat) {
    NSMutableAttributedString *string = [NSMutableAttributedString new];
    [string appendAttributedString:[[NSAttributedString alloc] initWithString:chat.name
                                                                   attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:15.0]}]];
    return string;
}

- (void)setChat:(ChatRoomModel *)chat {
    
    _chat = [chat copy];

    self.nameLabel.attributedText = AttributedStringForChat(chat);
}

@end
