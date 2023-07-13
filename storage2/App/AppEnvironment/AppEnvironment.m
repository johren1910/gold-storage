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
        self.cacheService = [[CacheService alloc] init];
        [CompressorHelper prepareCompressor];
        self.databaseService = [DatabaseService getSharedInstance];
        self.storageManager = [[StorageManager alloc] initWithCacheService:self.cacheService andDatabaseService:self.databaseService];
        self.downloadManager = [ZODownloadManager getSharedInstance];
    }
    return self;
}

@synthesize baseUrl;

@synthesize cacheService;

@synthesize databaseService;

@synthesize downloadManager;

@synthesize storageManager;

@end
