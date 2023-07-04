//
//  ChatDetailRemoteDataSource.m
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//
#import "ChatDetailRemoteDataSource.h"

@implementation ChatDetailRemoteDataSource
-(void)startDownloadWithUrl:(NSString *)downloadUrl destinationDirectory:(NSString *)dstDirectory
       isBackgroundDownload:(BOOL)isBackgroundDownload
              priority:(ZODownloadPriority)priority  progressBlock:(ZODownloadProgressBlock)progressBlock
                 completionBlock:(ZODownloadCompletionBlock)completionBlock
                 errorBlock:(ZODownloadErrorBlock)errorBlock {
    [_downloadManager startDownloadWithUrl:downloadUrl destinationDirectory:dstDirectory isBackgroundDownload:isBackgroundDownload priority:priority progressBlock:progressBlock completionBlock:completionBlock errorBlock:errorBlock];
}

-(void)cancelDownloadOfUrl:(NSString*)downloadUrl {
    [_downloadManager cancelDownloadOfUrl:downloadUrl];
}

-(instancetype)init:(NSString*) baseUrl {
    if (self == [super init]) {
        
    }
    
    return self;
}

@end
