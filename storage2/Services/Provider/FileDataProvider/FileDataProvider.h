//
//  FileDataProvider.h
//  storage2
//
//  Created by LAP14885 on 11/07/2023.
//

#import <Foundation/Foundation.h>
#import "StorageManagerType.h"

@protocol FileDataProviderType
-(instancetype)initWithStorageManager:(id<StorageManagerType>)storageManager;

#pragma mark - CRUD Operations
-(void)getAllFilesByType:(FileType)fileType completionBlock:(void (^)(NSArray* objects))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;
-(FileType)getFileTypeOfFilePath:(NSString*)filePath;
-(NSString*)moveFileToGeneralFolders:(NSString*) currentfilePath forFileType:(FileType)fileType andSetName:(NSString*)name;
-(void)updateFile:(FileData*)fileData completionBlock:(void(^)(BOOL isFinish))completionBlock;
-(void)saveFileData:(FileDataWrapper*)data completionBlock:(void(^)(id entity))completionBlock;
-(void) saveImageWithData:(NSData*)data ofRoomId:(NSString*)roomId completionBlock:(void(^)(ChatDetailEntity* entity)) completionBlock errorBlock:(void (^)(NSError *error))errorBlock;
-(void)deleteFile:(FileData*)file completionBlock:(void(^)(BOOL isFinish))completionBlock;
-(void)getAllStorageItem:(void (^)(NSArray* items))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;

- (void)getFilesWhere:(NSString*)where select:(NSString*)select isDistinct:(BOOL)isDistinct groupBy:(NSString*)groupBy orderBy:(NSString*)orderBy completionBlock:(void (^)(NSArray* items))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;

#pragma mark - Size Operations
-(void)getPhoneSize:(void (^)(long long size))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;
-(void)getAppSize:(void (^)(long long size))completionBlock errorBlock:(void (^)(NSError *error))errorBlock;


@end

@interface FileDataProvider : NSObject <FileDataProviderType>
@end

