//
//  ChatMessageCell.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

@protocol ChatMessageCellDelegate <NSObject>
- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key;
@end

@interface ChatMessageCell : UICollectionViewCell
@property (nonatomic, copy) ChatMessageModel *chat;
@property (nonatomic, weak) id <ChatMessageCellDelegate> delegate;
@end
