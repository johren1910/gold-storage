//
//  AppService.m
//  storage2
//
//  Created by LAP14885 on 28/06/2023.
//

#import <Foundation/Foundation.h>
#import "AppEnvironment.h"

@interface AppEnvironment ()
@end

@implementation AppEnvironment

- (instancetype)init {
    if (self == [super init]) {
        self.baseUrl = @"";
        [FileHelper createDirectoriesForPath:[FileHelper pathForApplicationSupportDirectory]];
        _cacheService = [[CacheService alloc] init];
        [CompressorHelper prepareCompressor];
        _databaseManager = [DatabaseManager getSharedInstance];
        _storageManager = [[StorageManager alloc] initWithCacheService:_cacheService andDatabaseManager:_databaseManager];
        _downloadManager = [ZODownloadManager getSharedInstance];
    }
    return self;
}

@end