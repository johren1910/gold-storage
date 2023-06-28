//
//  AppService.h
//  storage2
//
//  Created by LAP14885 on 28/06/2023.
//

#import <Foundation/Foundation.h>
#import "ServiceFactory.h"
#import "DatabaseManager.h"
#import "StorageManager.h"
#import "CacheService.h"
#import "ZODownloadManager.h"

@interface AppService : NSObject
-(id) getService:(id)class;

//- (void) registerServices;
//- (id) getService:(Class) service;
@end
