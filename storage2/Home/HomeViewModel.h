//
//  HomeViewModel.h
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>
#import "ChatModel.h"
#import "ChatSectionController.h"

@interface HomeViewModel : NSObject

- (void)getData:(void (^)(NSArray<ChatModel *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion;

- (ChatModel *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger) numberOfSections;

@property (copy,nonatomic) NSArray<ChatModel *> *chats;

@end
