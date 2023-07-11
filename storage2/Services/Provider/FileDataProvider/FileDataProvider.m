//
//  FileDataProvider.m
//  storage2
//
//  Created by LAP14885 on 11/07/2023.
//

#import "FileDataProvider.h"
#import "ChatDetailEntity.h"
#import "CompressorHelper.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface FileDataProvider ()
@property (nonatomic) id<StorageManagerType> storageManager;
@end

@implementation FileDataProvider

-(instancetype)initWithStorageManager:(id<StorageManagerType>)storageManager {
    if (self ==[super init]) {
        self.storageManager = storageManager;
    }
    return self;
}


- (void)updateFile:(FileData*)fileData completionBlock:(void(^)(BOOL isFinish))completionBlock {
    [_storageManager updateFileData:fileData completionBlock:completionBlock];
}

- (void)saveFileData:(FileDataWrapper*)data completionBlock:(void(^)(id entity))completionBlock {
    [_storageManager createFile:data.fileData withNSData:data.nsData completionBlock:^(BOOL isSuccess){
        completionBlock(nil);
    }];
}

-(FileType)getFileTypeOfFilePath:(NSString*)filePath {
    FileType type = Unknown;
    CFStringRef fileExtension = (__bridge CFStringRef) [filePath pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    
    if (UTTypeConformsTo(fileUTI, kUTTypeImage)) {
        type = Picture;
    }
    else if (UTTypeConformsTo(fileUTI, kUTTypeMovie)) {
        type = Video;
    }
    else if (UTTypeConformsTo(fileUTI, kUTTypeText)) {
        NSLog(@"Text type");
    }
    CFRelease(fileUTI);
    return type;
}

- (NSString*)moveFileToGeneralFolders:(NSString*) currentfilePath forFileType:(FileType)fileType andSetName:(NSString*)name {
    
    NSString* folderPath = [FileHelper getDefaultDirectoryByFileType:fileType];
    NSString* fileRelativePath = [folderPath stringByAppendingPathComponent:name];
    
    NSString* absolutePath = [FileHelper absolutePath:fileRelativePath];
    
    if ([FileHelper existsItemAtPath:absolutePath]) {
        return fileRelativePath;
    }
    [FileHelper createDirectoriesForFileAtPath:absolutePath];
    
    NSError *error;
    NSURL *srcUrl = [FileHelper urlForItemAtPath:currentfilePath];
    NSURL *dstUrl = [FileHelper urlForItemAtPath:absolutePath];
    [FileHelper copyItemAtPath:srcUrl toPath:dstUrl error:&error];
    [FileHelper removeItemAtPath:currentfilePath];
    return fileRelativePath;
}

- (void)saveImageWithData:(NSData*)data ofRoomId:(NSString*)roomId completionBlock:(void(^)(ChatDetailEntity* entity)) completionBlock errorBlock:(void (^)(NSError *error))errorBlock {
    
    __weak FileDataProvider* weakself = self;
    [_storageManager uploadImage:data withRoomId:roomId completionBlock:^(id object) {
        ChatMessageData* data = (ChatMessageData*)object;
        ChatDetailEntity*entity = [data  toChatDetailEntity];
        entity.thumbnail = [weakself.storageManager getImageByKey:entity.file.checksum];
        completionBlock(entity);
    }];
}

@end
