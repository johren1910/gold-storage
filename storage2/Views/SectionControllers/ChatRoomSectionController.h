//
//  ChatSectionController.h
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

@import IGListKit;
#import "ChatRoomEntity.h"

@protocol ChatRoomSectionControllerDelegate <NSObject>
- (void)didSelect:(ChatRoomEntity*) chat;
- (void)didSelectForDelete:(ChatRoomEntity*) chatRoom;
- (void)didDeselect:(ChatRoomEntity*) chatRoom;
@end


@interface ChatRoomSectionController : IGListSectionController
@property (nonatomic, strong) id <ChatRoomSectionControllerDelegate>  delegate;
@end
