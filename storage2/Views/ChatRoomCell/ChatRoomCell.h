//
//  ChatRoomCell.h
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

@class ChatRoomEntity;

@protocol ChatRoomCellDelegate <NSObject>
- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key;
- (void) didSelectCircle;
@end

@interface ChatRoomCell : UICollectionViewCell
@property (nonatomic, copy) ChatRoomEntity *chat;
@property (nonatomic, weak) id <ChatRoomCellDelegate>  delegate;
@end
