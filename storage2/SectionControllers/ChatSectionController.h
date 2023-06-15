//
//  ChatSectionController.h
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

@import IGListKit;
#import "ChatModel.h"

@protocol ChatSectionControllerDelegate <NSObject>

- (void) didSelect: (ChatModel*) chat;

@end


@interface ChatSectionController : IGListSectionController
@property (nonatomic, strong) id <ChatSectionControllerDelegate>  delegate;
@end
