//
//  ChatMessageCell.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

@class ChatMessageModel;

@protocol ChatMessageCellDelegate <NSObject>
- (void) didSelectDelete: (ChatMessageModel*) chat;
@end

@interface ChatMessageCell : UICollectionViewCell
@property (nonatomic, copy) ChatMessageModel *chat;
@end
