//
//  ChatDetailUseCase.h
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import <Foundation/Foundation.h>
#import "ChatDetailReporitoryInterface.h"
#import "ChatDetailEntity.h"

@protocol ChatDetailUseCaseInterface

- (void)getChatDetailsOfRoomId:(NSString*)roomId successCompletion:(void (^)(NSArray<ChatDetailEntity *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion;

- (void)addImageWithData:(NSData *)data;

@end

@interface ChatDetailUseCase : NSObject<ChatDetailUseCaseInterface>
@property (nonatomic) id<ChatDetailRepositoryInterface> chatDetailRepository;
-(instancetype) initWithRepository:(id<ChatDetailRepositoryInterface>)repository;

@end
