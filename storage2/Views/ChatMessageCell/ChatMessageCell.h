//
//  ChatMessageCell.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <UIKit/UIKit.h>

@protocol ChatMessageCellDelegate <NSObject>
- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key;
- (void) retryWithModel: (ChatDetailEntity*)model;
@end

@interface ChatMessageCell : UICollectionViewCell
@property (nonatomic, copy) ChatDetailEntity *chat;
@property (nonatomic, weak) id <ChatMessageCellDelegate> delegate;
@end
