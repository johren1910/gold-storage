//
//  ChatDetailViewModel.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//
#import <Foundation/Foundation.h>
#import "ChatDetailModel.h"
#import "ChatDetailSectionController.h"

@interface ChatDetailViewModel : NSObject

- (void)getData:(void (^)(NSArray<ChatDetailModel *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion;
- (void)changeSegment: (NSUInteger*) index;

- (ChatDetailModel *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger) numberOfSections;

@property (copy,nonatomic) NSArray<ChatDetailModel *> *filteredChats;

@end
