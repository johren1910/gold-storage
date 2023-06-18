//
//  ChatDetailCell.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

@class ChatMessageModel;

@protocol ChatDetailCellDelegate <NSObject>
- (void) didSelectDelete: (ChatMessageModel*) chat;
@end

@interface ChatDetailCell : UICollectionViewCell
@property (nonatomic, copy) ChatMessageModel *chat;
@end
