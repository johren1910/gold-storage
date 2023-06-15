//
//  HomeViewModel.m
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

#import "HomeViewModel.h"
#import "ChatModel.h"

@interface HomeViewModel ()

@end

@implementation HomeViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.chats = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)getData:(void (^)(NSMutableArray<ChatModel *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion {
    
    _chats = [[NSMutableArray alloc] init];
    
    //TODO: FETCH DATA HERE
    
//    NSArray *testData = [[NSMutableArray alloc] init];
//    testData = @[[[ChatModel alloc] initWithName:@"nice name" chatId:@"1"],
//                   [[ChatModel alloc] initWithName:@"anothoer name" chatId:@"2"],
//                   [[ChatModel alloc] initWithName:@"nice bye" chatId:@"3"],
//                   [[ChatModel alloc] initWithName:@"nice ba" chatId:@"4"],
//                   [[ChatModel alloc] initWithName:@"nice bubo" chatId:@"5"],
//                 [[ChatModel alloc] initWithName:@"nice ba 1 " chatId:@"6"],
//                 [[ChatModel alloc] initWithName:@"nice ba2 " chatId:@"7"],
//                 [[ChatModel alloc] initWithName:@"nice ba3" chatId:@"8"],
//                 [[ChatModel alloc] initWithName:@"nice b5a" chatId:@"9"],
//                 [[ChatModel alloc] initWithName:@"nice b6a" chatId:@"10"],
//                 [[ChatModel alloc] initWithName:@"nice b87a" chatId:@"11"],
//                 [[ChatModel alloc] initWithName:@"nice b9a" chatId:@"12"],
//                 [[ChatModel alloc] initWithName:@"nice b96a" chatId:@"13"],
//                 [[ChatModel alloc] initWithName:@"nice ba9" chatId:@"14"],
//                 [[ChatModel alloc] initWithName:@"nice ba43" chatId:@"15"]
//    ];
//    
//    
//    
//    _chats = [NSMutableArray arrayWithArray:testData];
//    successCompletion(_chats);
}

- (ChatModel *)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.chats.count) {
        return nil;
    }
    
    return self.chats[indexPath.row];
}

- (NSUInteger) numberOfSections {
    return 1;
}

- (NSMutableArray<ChatModel*>*) items {
    return _chats;
}

- (void)createNewChat: (NSString *) name {

    ChatModel *newChat = [[ChatModel alloc] initWithName:name chatId:[[NSUUID UUID] UUIDString]];
    [_chats addObject:newChat];
}
@end
