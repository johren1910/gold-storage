//
//  ChatDetailRemoteDataSourceInterface.h
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import "ChatMessageData.h"
#import "ZODownloadManagerType.h"

@protocol ChatDetailRemoteDataSourceType
-(void)startDownloadWithUnit:(ZODownloadUnit*)unit;
-(void)cancelDownloadOfUrl:(NSString*)downloadUrl;

@end

@interface ChatDetailRemoteDataSource : NSObject <ChatDetailRemoteDataSourceType>
-(instancetype)init:(NSString*) baseUrl;
@property (nonatomic) id<ZODownloadManagerType> downloadManager;
@end
