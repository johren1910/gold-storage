//
//  ChatDetailViewModel.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

#import "ChatDetailViewModel.h"
#import "ChatDetailModel.h"

@interface ChatDetailViewModel ()

@end

@implementation ChatDetailViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.chats = @[];
    }
    
    return self;
}

- (void)getData:(void (^)(NSArray<ChatDetailModel *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion {
    
    //TODO: FETCH DATA HERE
    
    NSArray *testData = [[NSArray alloc] init];
    testData = @[[[ChatDetailModel alloc] initWithName:@"nice name" chatId:@"1"],
                   [[ChatDetailModel alloc] initWithName:@"anothoer name" chatId:@"2"],
                   [[ChatDetailModel alloc] initWithName:@"nice bye" chatId:@"3"],
                   [[ChatDetailModel alloc] initWithName:@"nice ba" chatId:@"4"],
                   [[ChatDetailModel alloc] initWithName:@"nice bubo" chatId:@"5"],
                 [[ChatDetailModel alloc] initWithName:@"nice ba 1 " chatId:@"6"],
                 [[ChatDetailModel alloc] initWithName:@"nice ba2 " chatId:@"7"],
                 [[ChatDetailModel alloc] initWithName:@"nice ba3" chatId:@"8"],
                 [[ChatDetailModel alloc] initWithName:@"nice b5a" chatId:@"9"],
                 [[ChatDetailModel alloc] initWithName:@"nice b6a" chatId:@"10"],
                 [[ChatDetailModel alloc] initWithName:@"nice b87a" chatId:@"11"],
                 [[ChatDetailModel alloc] initWithName:@"nice b9a" chatId:@"12"],
                 [[ChatDetailModel alloc] initWithName:@"nice b96a" chatId:@"13"],
                 [[ChatDetailModel alloc] initWithName:@"nice ba9" chatId:@"14"],
                 [[ChatDetailModel alloc] initWithName:@"nice ba43" chatId:@"15"]
    ];
    
    _chats = testData;
    successCompletion(testData);
}

- (ChatDetailModel *)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.chats.count) {
        return nil;
    }
    
    return self.chats[indexPath.row];
}

- (NSUInteger) numberOfSections {
    return 1;
}

- (NSArray<ChatDetailModel*>*) items {
    return _chats;
}
@end
