//
//  ChatCell.h
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

@class ChatModel;

@protocol ChatCellDelegate <NSObject>
- (void) didSelectDelete: (ChatModel*) chat;
@end

@interface ChatCell : UICollectionViewCell
@property (nonatomic, copy) ChatModel *chat;
@end
