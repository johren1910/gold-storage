//
//  HomeViewModel.h
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>
#import "ChatModel.h"
#import "ChatSectionController.h"

@protocol HomeViewModelDelegate

- (void) didUpdateData;

@end

@interface HomeViewModel : NSObject

- (void)getData:(void (^)(NSMutableArray<ChatModel *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion;

- (ChatModel *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger) numberOfSections;
- (void)createNewChat: (NSString *) name;

@property (strong,nonatomic) NSMutableArray<ChatModel *> *chats;

@property (nonatomic, weak) id <HomeViewModelDelegate>  delegate;

@end
