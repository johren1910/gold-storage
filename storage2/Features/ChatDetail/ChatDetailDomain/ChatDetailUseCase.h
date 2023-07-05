//
//  ChatDetailUseCase.h
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import <Foundation/Foundation.h>
#import "ChatDetailReporitoryInterface.h"
#import "ChatDetailEntity.h"
#import "ChatMessageData.h"
#import "ChatRoomModel.h"

@protocol ChatDetailUseCaseInterface

- (void)getChatDetailsOfRoomId:(NSString*)roomId completionBlock:(void (^)(NSArray<ChatDetailEntity *> *chats))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;
- (void)deleteChatEntities:(NSArray<ChatDetailEntity*>*)entities completionBlock:(void (^)(BOOL isSuccess))completionBlock;

- (void)saveImageWithData:(NSData *)data
                 ofRoomId:(NSString*)roomId completionBlock:(void (^)(ChatDetailEntity *))completionBlock errorBlock:(void (^)(NSError *))errorBlock;
- (void)requestDownloadFileWithUrl:(NSString *)url forRoom:(ChatRoomModel*)roomModel completionBlock:(void (^)(ChatDetailEntity *entity, BOOL isDownloaded))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;
- (void)resumeDownloadForEntity:(ChatDetailEntity *)entity OfRoom:(ChatRoomModel*)roomModel completionBlock:(void (^)(ChatDetailEntity *entity))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;
- (void)updateRamCache:(UIImage*)image withKey:(NSString*)key;

@end

@interface ChatDetailUseCase : NSObject<ChatDetailUseCaseInterface>
@property (nonatomic) id<ChatDetailRepositoryInterface> chatDetailRepository;
-(instancetype) initWithRepository:(id<ChatDetailRepositoryInterface>)repository;

@end
