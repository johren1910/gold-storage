//
//  ChatDetailBusinessModel.h
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import <Foundation/Foundation.h>
#import "ChatDetailReporitoryInterface.h"
#import "ChatDetailEntity.h"
#import "ChatMessageData.h"
#import "ChatRoomEntity.h"

@protocol ChatDetailBusinessModelInterface

- (void)getChatDetailsOfRoomId:(NSString*)roomId completionBlock:(void (^)(NSArray<ChatDetailEntity *> *chats))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;
- (void)deleteChatEntities:(NSArray<ChatDetailEntity*>*)entities completionBlock:(void (^)(BOOL isSuccess))completionBlock;

- (void)saveImageWithData:(NSData *)data
                 ofRoomId:(NSString*)roomId completionBlock:(void (^)(ChatDetailEntity *))completionBlock errorBlock:(void (^)(NSError *))errorBlock;
- (void)requestDownloadFileWithUrl:(NSString *)url forRoom:(ChatRoomEntity*)roomData completionBlock:(void (^)(ChatDetailEntity *entity, BOOL isDownloaded))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;
- (void)resumeDownloadForEntity:(ChatDetailEntity *)entity OfRoom:(ChatRoomEntity*)roomData completionBlock:(void (^)(ChatDetailEntity *entity))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;

@end

@interface ChatDetailBusinessModel : NSObject<ChatDetailBusinessModelInterface>
@property (nonatomic) id<ChatDetailRepositoryInterface> chatDetailRepository;
-(instancetype) initWithRepository:(id<ChatDetailRepositoryInterface>)repository;

@end
