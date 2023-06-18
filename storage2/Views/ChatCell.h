//
//  ChatCell.h
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

@class ChatRoomModel;

@protocol ChatCellDelegate <NSObject>
- (void) didSelectDelete: (ChatRoomModel*) chat;
@end

@interface ChatCell : UICollectionViewCell
@property (nonatomic, copy) ChatRoomModel *chat;
@end
