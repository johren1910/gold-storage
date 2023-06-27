//
//  ChatDetailSectionController.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

@import IGListKit;
#import "ChatMessageModel.h"

@protocol ChatDetailSectionControllerDelegate <NSObject>

- (void) didSelect: (ChatMessageModel*) chat;
- (void) didDeselect: (ChatMessageModel*) chat;
- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key;
@end


@interface ChatDetailSectionController : IGListSectionController
@property (nonatomic, weak) id <ChatDetailSectionControllerDelegate>  delegate;
@end
