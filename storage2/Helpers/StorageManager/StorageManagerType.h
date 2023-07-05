//
//  StorageManagerType.h
//  storage2
//
//  Created by LAP14885 on 28/06/2023.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CacheService.h"
#import "HashHelper.h"
#import "DatabaseManager.h"
#import "FileHelper.h"
#import "ChatRoomModel.h"
#import "FileData.h"

@protocol StorageManagerType

# pragma mark - DB Operation

- (void)createChatMessage:(ChatMessageData*) chatMessage  completionBlock:(ZOCompletionBlock)completionBlock;
- (void)deleteChatMessage:(ChatMessageData*) message completionBlock:(ZOCompletionBlock)completionBlock;
- (void) getChatMessagesByRoomId:(NSString*)chatRoomId completionBlock:(ZOFetchCompletionBlock)completionBlock;
- (void) getMessageOfId:(NSString*)messageId completionBlock:(ZOFetchCompletionBlock)completionBlock;

- (void) createChatRoom:(ChatRoomModel*)chatRoom completionBlock:(ZOCompletionBlock)completionBlock;
- (void)deleteChatRoom:(ChatRoomModel*) chatRoom completionBlock:(ZOCompletionBlock)completionBlock;
- (void) getChatRoomsByPage:(int)page completionBlock:(ZOFetchCompletionBlock)completionBlock;

- (void)createFile:(FileData*) fileData withNSData:(NSData*)data completionBlock:(ZOCompletionBlock)completionBlock;
- (void)deleteFileData:(FileData*) file completionBlock:(ZOCompletionBlock)completionBlock;
- (void) getFileOfMessageId:(NSString*)messageId completionBlock:(ZOFetchCompletionBlock)completionBlock;
- (void)updateFileData:(FileData*) fileData completionBlock:(ZOCompletionBlock)completionBlock;

- (void)uploadImage:(NSData*) data withRoomId:(NSString*)roomId completionBlock:(ZOFetchCompletionBlock)completionBlock;

#pragma mark - Local file operation
-(void)writeToFilePath:(NSString*)filePath withData:(NSData*)data;

# pragma mark - Cache Operation
-(void)cacheImageByKey:(UIImage*)image withKey:(NSString*)key;
-(UIImage*)getImageByKey:(NSString*)key;
-(void)deleteImageByKey:(NSString*)key;
- (void)compressThenCache: (UIImage*)image withKey:(NSString*) key;

#pragma mark - Helper operation
-(FileType)getFileTypeOfFilePath:(NSString*)filePath;

@end
