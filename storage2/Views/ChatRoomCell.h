//
//  ChatRoomCell.h
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

@class ChatRoomModel;

@protocol ChatRoomCellDelegate <NSObject>
- (void) didSelectDelete: (ChatRoomModel*) chat;
@end

@interface ChatRoomCell : UICollectionViewCell
@property (nonatomic, copy) ChatRoomModel *chat;
@end
