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

- (void)startDownloadWithItem:(ZODownloadItem*)item
                   forMessage: (ChatMessageData*)message completionBlock:(void(^)(FileData* fileData, UIImage* thumbnail))completionBlock {
    __weak ChatDetailDataRepository* weakself = self;
    __weak ZODownloadItem* weakItem = item;
    __weak __block ChatMessageData* weakMessage = message;
    
    item.completionBlock = ^(NSString *filePath) {
        dispatch_async(weakself.backgroundQueue, ^{
            FileDataProvider* fileProvider = (FileDataProvider*)weakself.fileDataProvider;
            FileType fileType = [fileProvider getFileTypeOfFilePath:filePath];
            NSString *currentFilePath = filePath;
            if (!weakItem.destinationDirectoryPath) {
                currentFilePath = [fileProvider moveFileToGeneralFolders:filePath forFileType:fileType andSetName:[filePath lastPathComponent]];
            }
            weakMessage.messageState = Sent;
            [weakself.chatMessageProvider updateMessage:weakMessage completionBlock:^(BOOL isFinish){
                [weakself _saveMedia:currentFilePath forMessage:weakMessage completionBlock:completionBlock];
            }];
            
            NSLog(@"destinationPath download: %@", currentFilePath);
        });
        
        
    };
    
    item.errorBlock = ^(NSError *error) {
        
        NSLog(@"error");
    };
    
    ZODOwnloadUnit *downloadUnit = [[ZODOwnloadUnit alloc] initWithItem:item andRepository:nil];
    [_downloadManager startDownloadWithUnit:downloadUnit];
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
                    [weakself.storageManager cacheImageByKey:thumbnail withKey:checkSum];
                    NSLog(@"LOG 4");
                }
                
                break;
            case Video:
                mediaInfo = [FileHelper getMediaInfoOfFilePath:[FileHelper absolutePath:filePath]];
                duration = mediaInfo.duration;
                if (!thumbnail) {
                    thumbnail = mediaInfo.thumbnail;
                    [weakself.storageManager cacheImageByKey:thumbnail withKey:checkSum];
                    NSLog(@"LOG 4");
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
