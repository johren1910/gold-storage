//
//  AppService.h
//  storage2
//
//  Created by LAP14885 on 28/06/2023.
//

#import <Foundation/Foundation.h>
#import "DatabaseManager.h"
#import "StorageManager.h"
#import "CacheService.h"
#import "ZODownloadManager.h"
#import "CompressorHelper.h"

@interface AppEnvironment : NSObject
@property (nonatomic) NSString* baseUrl;
@property (nonatomic) id<CacheServiceType> cacheService;
@property (nonatomic) id<DatabaseManagerType> databaseManager;
@property (nonatomic) id<StorageManagerType> storageManager;
@property (nonatomic) id<ZODownloadManagerType> downloadManager;
@end
