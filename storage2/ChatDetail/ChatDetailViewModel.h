//
//  ChatDetailViewModel.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//
#import <Foundation/Foundation.h>
#import "ChatDetailSectionController.h"
#import "ChatRoomModel.h"
#import "DatabaseManager.h"

@protocol ChatDetailViewModelDelegate <NSObject>

- (void) didUpdateData;

@end

@interface ChatDetailViewModel : NSObject

- (void)getData:(void (^)(NSArray<ChatMessageModel *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion;
- (void)changeSegment: (NSUInteger*) index;
- (ChatMessageModel *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger) numberOfSections;
- (void)addImage:(UIImage *)image;
- (void)addFile:(NSData *)data;

@property (nonatomic, weak) id <ChatDetailViewModelDelegate>  delegate;
@property (copy,nonatomic) NSArray<ChatMessageModel *> *filteredChats;
@property (nonatomic, strong) DatabaseManager* databaseManager;

-(instancetype) initWithChatRoom: (ChatRoomModel*) chatRoom;
@end
