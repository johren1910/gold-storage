//
//  ChatDetailRemoteDataSourceInterface.h
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import "ChatMessageData.h"
#import "ZODownloadManagerType.h"

@protocol ChatDetailRemoteDataSourceType
-(void)startDownloadWithUrl:(NSString *)downloadUrl destinationDirectory:(NSString *)dstDirectory
       isBackgroundDownload:(BOOL)isBackgroundDownload
              priority:(ZODownloadPriority)priority  progressBlock:(ZODownloadProgressBlock)progressBlock
                 completionBlock:(ZODownloadCompletionBlock)completionBlock
                    errorBlock:(ZODownloadErrorBlock)errorBlock;

@end

@interface ChatDetailRemoteDataSource : NSObject <ChatDetailRemoteDataSourceType>
-(instancetype)init:(NSString*) baseUrl;
@property (nonatomic) id<ZODownloadManagerType> downloadManager;
@end
