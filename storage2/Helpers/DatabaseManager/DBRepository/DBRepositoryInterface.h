//
//  DBRepositoryInterface.h
//  storage2
//
//  Created by LAP14885 on 05/07/2023.
//
#import <Foundation/Foundation.h>
#import "sqlite3.h"

typedef void(^ZOCompletionBlock)(BOOL isSuccess);
typedef void(^ZOFetchCompletionBlock)(id object);

@protocol DBRepositoryInterface <NSObject>

- (BOOL)save:(id)object;
- (BOOL)remove:(id)object;
- (BOOL)removeObjectWhere:(NSString*)where;
- (BOOL)update:(id)object;
- (id)getObjectWhere:(NSString*)where;
- (NSArray*)getObjectsWhere:(NSString*)where select:(NSString*)select isDistinct:(BOOL)isDistinct groupBy:(NSString*)groupBy orderBy:(NSString*)orderBy;
- (NSArray*)getObjectsWhere:(NSString*)where isDistinct:(BOOL)isDistinct;
- (NSArray*)getObjectsWhere:(NSString *)where take:(int) countItem;
- (NSArray*)getObjectsWhere:(NSString*)where orderBy:(NSString*)orderByAttribute ascending:(BOOL)ascending;
- (NSArray*)getObjectsWhere:(NSString*)where orderBy:(NSString*)orderByAttribute ascending:(BOOL)ascending take:(int)countItem;
-(void)setDatabasePath:(NSString*)path;
@end
