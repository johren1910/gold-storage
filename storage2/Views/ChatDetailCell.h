//
//  ChatDetailCell.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

@class ChatDetailModel;

@protocol ChatDetailCellDelegate <NSObject>
- (void) didSelectDelete: (ChatDetailModel*) chat;
@end

@interface ChatDetailCell : UICollectionViewCell
@property (nonatomic, copy) ChatDetailModel *chat;
@end
