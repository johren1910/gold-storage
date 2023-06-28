//
//  StorageManager.h
//  storage2
//
//  Created by LAP14885 on 27/06/2023.
//

#import "StorageManagerType.h"

@interface StorageManager : NSObject <StorageManagerType>

-(instancetype) initWithCacheService:(id<CacheServiceType>)cacheService andDatabaseManager:(id<DatabaseManagerType>)databaseManager;

@property (strong,nonatomic) id<CacheServiceType> cacheService;
@property (strong,nonatomic) id<DatabaseManagerType> databaseManager;

@end
