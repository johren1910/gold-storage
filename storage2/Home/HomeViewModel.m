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
        self.chats = @[];
    }
    
    return self;
}

- (void)getData:(void (^)(NSArray<ChatModel *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion {
    
    //TODO: FETCH DATA HERE
    
    NSArray *testData = [[NSArray alloc] init];
    testData = @[[[ChatModel alloc] initWithName:@"nice name" chatId:@"1"],
                   [[ChatModel alloc] initWithName:@"anothoer name" chatId:@"2"],
                   [[ChatModel alloc] initWithName:@"nice bye" chatId:@"3"],
                   [[ChatModel alloc] initWithName:@"nice ba" chatId:@"4"],
                   [[ChatModel alloc] initWithName:@"nice bubo" chatId:@"5"]
    ];
    
    _chats = testData;
    successCompletion(testData);
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

- (NSArray<ChatModel*>*) items {
    return _chats;
}

@end
