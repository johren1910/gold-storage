//
//  DatabaseService.h
//  storage2
//
//  Created by LAP14885 on 17/06/2023.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "ChatRoomModel.h"
#import "FileData.h"
#import "DBRepositoryInterface.h"

@protocol DatabaseServiceType

#pragma mark - ChatMessage
- (id<DBRepositoryInterface>) getChatMessageDBRepository;

#pragma mark - ChatRoom
- (id<DBRepositoryInterface>) getChatRoomDBRepository;

#pragma mark - File 
- (void)saveFileData:(FileData*) fileData completionBlock:(ZOCompletionBlock)completionBlock;
- (void)deleteFileData:(FileData*) file completionBlock:(ZOCompletionBlock)completionBlock;
- (void) getFileOfMessageId:(NSString*)messageId completionBlock:(ZOFetchCompletionBlock)completionBlock;
- (void)updateFileData:(FileData*) fileData completionBlock:(ZOCompletionBlock)completionBlock;

@end

@interface DatabaseService : NSObject <DatabaseServiceType>


+(DatabaseService*)getSharedInstance;

@end
