//
//  ChatSectionController.h
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

@import IGListKit;
#import "ChatRoomModel.h"

@protocol ChatRoomSectionControllerDelegate <NSObject>
- (void) didSelect: (ChatRoomModel*) chat;
- (void) didSelectForDelete: (ChatRoomModel*) chatRoom;
- (void) didDeselect: (ChatRoomModel*) chatRoom;
@end


@interface ChatRoomSectionController : IGListSectionController
@property (nonatomic, strong) id <ChatRoomSectionControllerDelegate>  delegate;
@end
