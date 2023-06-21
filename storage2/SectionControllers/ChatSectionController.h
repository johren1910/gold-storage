//
//  ChatSectionController.h
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

@import IGListKit;
#import "ChatRoomModel.h"

@protocol ChatSectionControllerDelegate <NSObject>

- (void) didSelect: (ChatRoomModel*) chat;
@end


@interface ChatSectionController : IGListSectionController
@property (nonatomic, strong) id <ChatSectionControllerDelegate>  delegate;
@end
