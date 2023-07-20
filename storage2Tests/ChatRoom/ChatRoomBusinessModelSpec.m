//
//  ChatRoomBusinessModelSpec.m
//  storage2Tests
//
//  Created by LAP14885 on 20/07/2023.
//

#import <Foundation/Foundation.h>

@import Quick;
@import Nimble;

#import "ChatRoomDataRepository.h"
#import "ChatRoomBusinessModel.h"
#import <OCMock/OCMock.h>

QuickSpecBegin(ChatRoomBusinessModelSpec)

__block ChatRoomBusinessModel* businessModel = nil;
__block id mockRepository = nil;
__block id mockChatRoomProvider = nil;
__block id mockChatRoomEntity = nil;
__block id mockChatRoomData = nil;
beforeEach(^{
    mockChatRoomData = OCMClassMock([ChatRoomData class]);
    mockChatRoomEntity = OCMClassMock([ChatRoomEntity class]);
    mockChatRoomProvider = OCMClassMock([ChatRoomProvider class]);
    mockRepository = [[ChatRoomDataRepository alloc] initWithStorageManager:[OCMArg any] andChatRoomProvider:mockChatRoomProvider];
    businessModel = [[ChatRoomBusinessModel alloc] initWithRepository:mockRepository];
});

describe(@"chatRoom CRUD", ^{
  beforeEach(^{
      
  });

  it(@"getChatRoom", ^{
      OCMExpect([mockChatRoomProvider getChatRoomsByPage:1 completionBlock:nil errorBlock:nil]);
      [businessModel getChatRoomsByPage:1 completionBlock:nil errorBlock:nil];
      
      OCMVerifyAllWithDelay(mockChatRoomProvider, 0.5);
  });
    
    it(@"deleteChatRoom", ^{
        OCMExpect([mockChatRoomProvider deleteChatRoom:mockChatRoomEntity completionBlock:nil errorBlock:nil]);
        [businessModel deleteChatRoom:mockChatRoomEntity completionBlock:nil errorBlock:nil];
        
        OCMVerifyAllWithDelay(mockChatRoomProvider, 0.5);
    });
    
    it(@"createChatRoom", ^{
        id block = ^(BOOL isFinish){};
        id blockError = ^(NSError* error){};
        OCMExpect([mockChatRoomProvider createChatRoom:mockChatRoomData completionBlock:block errorBlock:blockError]);
        
        [businessModel createChatRoom:mockChatRoomData completionBlock:block errorBlock:blockError];
        
        OCMVerifyAllWithDelay(mockChatRoomProvider, 0.5);
    });
});


QuickSpecEnd

