//
//  ChatRoomCell.h
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

@class ChatRoomModel;

@protocol ChatRoomCellDelegate <NSObject>
- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key;
@end

@interface ChatRoomCell : UICollectionViewCell
@property (nonatomic, copy) ChatRoomModel *chat;
@property (nonatomic, weak) id <ChatRoomCellDelegate>  delegate;
@end
