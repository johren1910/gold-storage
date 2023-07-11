//
//  ChatDetailDataRepository.m
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import "ChatDetailDataRepository.h"
#import <UIKit/UIKit.h>
#import "ChatMessageProvider.h"
#import "FileDataProvider.h"

@interface ChatDetailDataRepository ()
@property (nonatomic) id<ZODownloadManagerType> downloadManager;
@property (nonatomic) id<StorageManagerType> storageManager;
@property (nonatomic) dispatch_queue_t backgroundQueue;
@end

@implementation ChatDetailDataRepository

- (void)startDownloadWithUnit:(ZODownloadUnit*)unit
                   forMessage: (ChatMessageData*)message completionBlock:(void(^)(FileData* fileData, UIImage* thumbnail))completionBlock {
    __weak ChatDetailDataRepository* weakself = self;
    __weak ZODownloadUnit* weakunit = unit;
    unit.completionBlock = ^(NSString *filePath) {
        FileDataProvider* fileProvider = (FileDataProvider*)weakself.fileDataProvider;
        FileType fileType = [fileProvider getFileTypeOfFilePath:filePath];
        NSString *currentFilePath = filePath;
        if (!weakunit.destinationDirectoryPath) {
            currentFilePath = [fileProvider moveFileToGeneralFolders:filePath forFileType:fileType andSetName:[message.file.filePath lastPathComponent]];
        }
        message.messageState = Sent;
        [weakself.chatMessageProvider updateMessage:message completionBlock:^(BOOL isFinish){
            NSLog(@"updated");
        }];
        [weakself _saveMedia:currentFilePath forMessage:message completionBlock:completionBlock];
        NSLog(@"destinationPath download: %@", currentFilePath);
    };
    
    unit.errorBlock = ^(NSError *error) {
        
        NSLog(@"error");
    };
    
    [_downloadManager startDownloadWithUnit:unit];
}

- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key {
    [_storageManager cacheImageByKey:image withKey:key];
}

-(instancetype) initWithDownloadManager:(id<ZODownloadManagerType>)downloadManager andFileDataProvider:(id<FileDataProviderType>)fileDataProvider
        andChatMessageProvider:(id<ChatMessageProviderType>)messageProvider andStorageManager:(id<StorageManagerType>)storageManager {
    if (self == [super init]) {
        self.downloadManager = downloadManager;
        self.storageManager = storageManager;
        self.chatMessageProvider = messageProvider;
        self.fileDataProvider = fileDataProvider;
        self.backgroundQueue = dispatch_queue_create("com.chatdetail.datarepository.queue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

@synthesize chatMessageProvider;
@synthesize fileDataProvider;

#pragma mark - Private
- (void)_saveMedia:(NSString*)filePath forMessage:(ChatMessageData*)message completionBlock:(void(^)(FileData* fileData, UIImage* thumbnail))completionBlock {
    __weak ChatDetailDataRepository* weakself = self;
    dispatch_async(_backgroundQueue, ^{
        
        FileDataProvider* fileProvider = (FileDataProvider*)weakself.fileDataProvider;
        FileType fileType = [fileProvider getFileTypeOfFilePath:filePath];
        NSData *fileData = [FileHelper readFileAtPathAsData:[FileHelper absolutePath:filePath]];
        NSString *checkSum = [HashHelper hashDataMD5:fileData];
        UIImage *thumbnail = [weakself.storageManager getImageByKey:checkSum];
        double duration = 0;
        ZOMediaInfo *mediaInfo = nil;
        switch (fileType) {
            case Picture:
                if (!thumbnail) {
                    thumbnail = [UIImage imageWithData:fileData];
                    NSData* compressed = UIImageJPEGRepresentation(thumbnail, 0.5);
                    thumbnail = [UIImage imageWithData:compressed];
                    [weakself.storageManager compressThenCache:thumbnail withKey:checkSum];
                }
                
                break;
            case Video:
                mediaInfo = [FileHelper getMediaInfoOfFilePath:[FileHelper absolutePath:filePath]];
                duration = mediaInfo.duration;
                if (!thumbnail) {
                    thumbnail = mediaInfo.thumbnail;
                    [weakself.storageManager compressThenCache:thumbnail withKey:checkSum];
                }
                
                break;
            default:
                break;
        }
        
        double size = ((double)fileData.length/1024.0f)/1024.0f; // MB
    
        NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970];
        
        FileData *newFileData = [[FileData alloc] init];
        newFileData.checksum = checkSum;
        newFileData.fileName = [filePath lastPathComponent];
        newFileData.fileId = message.file.fileId;
        newFileData.messageId = message.messageId;
        newFileData.type = fileType;
        newFileData.size = size;
        newFileData.filePath = filePath;
        newFileData.createdAt = timeStamp;
        newFileData.duration = duration;
        
        [weakself.fileDataProvider updateFile:newFileData completionBlock:^(BOOL isFinish){
            completionBlock(newFileData, thumbnail);
        }];
    });
}


@end
