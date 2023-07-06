//
//  StorageManager.h
//  storage2
//
//  Created by LAP14885 on 27/06/2023.
//

#import "StorageManagerType.h"

@interface ZOUploadUnit : NSObject
@property (nonatomic, copy) NSData *data;
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) ZOFetchCompletionBlock completionBlock;
@end

@interface StorageManager : NSObject <StorageManagerType>

-(instancetype) initWithCacheService:(id<CacheServiceType>)cacheService andDatabaseService:(id<DatabaseServiceType>)databaseService;

@end
