//
//  StorageManagerType.h
//  storage2
//
//  Created by LAP14885 on 28/06/2023.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CacheService.h"

@protocol StorageManagerType

# pragma mark - DB Operation
- (void) saveEntity;
- (void) deleteEntity;
- (void) updateEntity;
- (void) findEntity;
- (void) findEntities;

# pragma mark - Cache Operation
- (void) cacheObjectByKey;
- (void) getObjectByKey;
- (void) deleteObjectByKey;

# pragma mark - File Operation
- (void) createFile;
- (void) deleteFile;

@end
