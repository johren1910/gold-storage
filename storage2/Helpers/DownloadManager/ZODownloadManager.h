//
//  ZODownloadManager.h
//  storage2
//
//  Created by LAP14885 on 25/06/2023.
//

#import "ZODownloadManagerType.h"

@interface ZODownloadManager : NSObject <ZODownloadManagerType>
/// [This property is] define the maximum concurrent download that can happen at the same times. When reached max, the queue will handle download according to FIFO
/// ///  - Note: Default is MAX_DOWNLOAD_TIMEOUT
@property (nonatomic, assign) int maxConcurrentDownloads;

/// [This property is] define the retry time out when client trying to reconnect
///  - Note: Default is MAX_DOWNLOAD_CONCURRENT
@property (nonatomic, assign) CGFloat retryTimeout;

/// [This property is] define if the manager is allowed to auto retry when client lost connection then regain it back.
///  - Note: Default is false
@property (nonatomic, assign) BOOL allowAutoRetry;

+ (instancetype)getSharedInstance;
@end
