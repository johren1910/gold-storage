//
//  ChatDetailViewModel.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

#import "ChatDetailViewModel.h"
#import "ChatMessageModel.h"
#import "MediaType.h"

@interface ChatDetailViewModel ()

@property (retain,nonatomic) NSMutableArray<ChatMessageModel *> *chats;
@end

@implementation ChatDetailViewModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.chats = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)getData:(void (^)(NSArray<ChatMessageModel *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion {
    
    //TODO: FETCH DATA HERE
    
//    NSArray *testData = [[NSArray alloc] init];
//    testData = @[[[ChatMessageModel alloc] initWithName:@"VIDEO name" chatId:@"1" type: Video],
//                 [[ChatMessageModel alloc] initWithName:@"anothoer PICTURE" chatId:@"2" type: Picture],
//                   [[ChatMessageModel alloc] initWithName:@"nice bye" chatId:@"3"],
//                   [[ChatMessageModel alloc] initWithName:@"nice ba" chatId:@"4"],
//                   [[ChatMessageModel alloc] initWithName:@"nice bubo" chatId:@"5"],
//                 [[ChatMessageModel alloc] initWithName:@"nice ba 1 " chatId:@"6"],
//                 [[ChatMessageModel alloc] initWithName:@"nice ba2 " chatId:@"7"],
//                 [[ChatMessageModel alloc] initWithName:@"nice ba3" chatId:@"8"],
//                 [[ChatMessageModel alloc] initWithName:@"nice b5a" chatId:@"9"],
//                 [[ChatMessageModel alloc] initWithName:@"nice b6a" chatId:@"10"],
//                 [[ChatMessageModel alloc] initWithName:@"nice b87a" chatId:@"11"],
//                 [[ChatMessageModel alloc] initWithName:@"nice b9a" chatId:@"12"],
//                 [[ChatMessageModel alloc] initWithName:@"nice b96a" chatId:@"13"],
//                 [[ChatMessageModel alloc] initWithName:@"nice ba9" chatId:@"14"],
//                 [[ChatMessageModel alloc] initWithName:@"nice ba43" chatId:@"15"]
//    ];
    
    _filteredChats = _chats;
    successCompletion(_filteredChats);
}

- (ChatMessageModel *)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.filteredChats.count) {
        return nil;
    }
    
    return self.filteredChats[indexPath.row];
}

- (void)changeSegment: (NSUInteger*) index {
    
    if (index == 0) {
        _filteredChats = _chats;
        return;
    }
    
    NSString *predicateString = @"type =[c] %ld";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString, index];
    
    if (index == 1) {
        predicateString = [predicateString stringByAppendingString:@"|| type =[c] %ld"];
         predicate = [NSPredicate predicateWithFormat:predicateString, Video, Picture];
    } else if (index == 2) {
         predicate = [NSPredicate predicateWithFormat:predicateString, File];
    } else {
        predicate = [NSPredicate predicateWithFormat:predicateString, Other];
    }
    
    NSArray *filteredArray = [_chats filteredArrayUsingPredicate:predicate];
    _filteredChats = filteredArray;
}

- (NSUInteger) numberOfSections {
    return 1;
}

- (NSArray<ChatMessageModel*>*) items {
    return _filteredChats;
}

- (void)addImage:(UIImage *)image {
    __weak ChatDetailViewModel *weakself = self;
    dispatch_queue_t myQueue = dispatch_queue_create("storage.image.data", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(myQueue, ^{
        
        NSData *data = UIImagePNGRepresentation(image);
        float size = ((float)data.length/1024.0f)/1024.0f; // MB
        ChatMessageModel *new = [[ChatMessageModel alloc] initWithName:[[NSUUID UUID] UUIDString] chatId:[[NSUUID UUID] UUIDString]];
        new.size = size;
        new.type = Picture;
//        new.data = data;
//        new.image = image;
        [weakself.chats insertObject:new atIndex:0];
        weakself.filteredChats = weakself.chats;
        // Reload data
        dispatch_async( dispatch_get_main_queue(), ^{
            [weakself.delegate didUpdateData];
        });
    });
}

- (void)addFile:(NSData *)data {
    __weak ChatDetailViewModel *weakself = self;
    float size = ((float)data.length/1024.0f)/1024.0f; // MB
    ChatMessageModel *new = [[ChatMessageModel alloc] initWithName:[[NSUUID UUID] UUIDString] chatId:[[NSUUID UUID] UUIDString]];
    new.size = size;
//    new.type = File;
//    new.data = data;
    //TEMP IMAGE
    if (@available(iOS 13.0, *)) {
//        new.image = [UIImage systemImageNamed:@"doc"];
    } else {
        // Fallback on earlier versions
    }
    [weakself.chats insertObject:new atIndex:0];
    weakself.filteredChats = weakself.chats;
    // Reload data
    dispatch_async( dispatch_get_main_queue(), ^{
        [weakself.delegate didUpdateData];
    });
}
@end
