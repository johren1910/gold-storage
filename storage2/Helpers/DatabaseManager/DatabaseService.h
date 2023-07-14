//
//  DatabaseService.h
//  storage2
//
//  Created by LAP14885 on 17/06/2023.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "ChatRoomData.h"
#import "FileData.h"
#import "DBRepositoryInterface.h"

@protocol DatabaseServiceType

#pragma mark - ChatMessage
- (id<DBRepositoryInterface>) getChatMessageDBRepository;

#pragma mark - ChatRoom
- (id<DBRepositoryInterface>) getChatRoomDBRepository;

#pragma mark - File
- (id<DBRepositoryInterface>) getFileDBRepository;

@end

@interface DatabaseService : NSObject <DatabaseServiceType>


+(DatabaseService*)getSharedInstance;

@end
