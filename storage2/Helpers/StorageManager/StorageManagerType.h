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

@protocol StorageManagerType <FactoryResolvable>

# pragma mark - DB Operation

- (BOOL)saveChatMessageData:(ChatMessageData*) chatMessage;
- (BOOL)deleteChatMessage:(ChatMessageData*) message;
- (NSArray<ChatMessageData*>*) getChatMessagesByRoomId:(NSString*)chatRoomId;

- (BOOL) saveChatRoomData:(ChatRoomModel*)chatRoom;
- (BOOL) deleteChatRoom:(ChatRoomModel*) chatRoom;
-(NSArray<ChatRoomModel*>*) getChatRoomsByPage:(int)page;
- (double)getSizeOfRoomId:(NSString*) roomId;

- (BOOL)saveFileData:(FileData*) fileData;
- (BOOL)deleteFileData:(FileData*) file;
- (FileData*) getFileOfMessageId:(NSString*)messageId;
- (BOOL)updateFileData:(FileData*) fileData;


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
