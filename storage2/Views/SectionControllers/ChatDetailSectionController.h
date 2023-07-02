//
//  ChatDetailSectionController.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

@import IGListKit;
#import "ChatDetailEntity.h"

@protocol ChatDetailSectionControllerDelegate <NSObject>

- (void) didSelect: (ChatDetailEntity*) chat;
- (void) didDeselect: (ChatDetailEntity*) chat;
- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key;
- (void) retryWithModel: (ChatDetailEntity*)model;
@end


@interface ChatDetailSectionController : IGListSectionController
@property (nonatomic, weak) id <ChatDetailSectionControllerDelegate>  delegate;
@end
