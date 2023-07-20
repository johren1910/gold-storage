//
//  ChatRoomViewModelSpec.m
//  storage2Tests
//
//  Created by LAP14885 on 20/07/2023.
//

#import <Foundation/Foundation.h>

@import Quick;
@import Nimble;

#import "ChatRoomViewModel.h"
#import "ChatRoomDataRepository.h"
#import "ChatRoomBusinessModel.h"
#import "ChatRoomViewController.h"
#import <OCMock/OCMock.h>

QuickSpecBegin(ChatRoomViewModelSpec)

__block ChatRoomViewModel* viewModel = nil;
__block id mockBusinessModel = nil;
__block id mockChatRoomEntity = nil;
__block id mockViewController = nil;
beforeEach(^{
    mockBusinessModel =  OCMClassMock([ChatRoomBusinessModel class]);
    mockChatRoomEntity = OCMClassMock([ChatRoomEntity class]);
    mockViewController = OCMClassMock([ChatRoomViewController class]);
    
    viewModel = [[ChatRoomViewModel alloc] initWithBusinessModel:mockBusinessModel];
    viewModel.delegate = mockViewController;
    viewModel.coordinatorDelegate = mockViewController;
});

describe(@"-viewDidLoad", ^{
  beforeEach(^{
      [viewModel onViewDidLoad];
  });

  it(@"viewModel onViewDidLoad triggered startLoading & call API", ^{
      OCMVerify([viewModel.delegate startLoading]);
      
      OCMVerify([mockBusinessModel getChatRoomsByPage:1 completionBlock:[OCMArg any] errorBlock:[OCMArg any]]);
  });
});


describe(@"ChatRoom CRUD", ^{
  beforeEach(^{
      
  });

  it(@"Select chatroom  -> update selected", ^{
      [viewModel selectChatRoom:mockChatRoomEntity];
      OCMVerify([viewModel.delegate didUpdateObject:mockChatRoomEntity]);
  });
    
    it(@"Deselect chatroom  -> update selected", ^{
        [viewModel deselectChatRoom:mockChatRoomEntity];
        OCMVerify([viewModel.delegate didUpdateObject:mockChatRoomEntity]);
    });
    
    it(@"Delete chatroom -> business model delete -> update data", ^{
        [viewModel selectChatRoom:[OCMArg any]];
        [viewModel deleteSelected];
        OCMVerify([mockBusinessModel deleteChatRoom:[OCMArg any] completionBlock:[OCMArg any] errorBlock:[OCMArg any]]);
    });
    
    it(@"Create chatroom -> business model create -> update data", ^{
        [viewModel requestCreateNewChat:[OCMArg any]];
        OCMVerify([mockBusinessModel createChatRoom:[OCMArg any] completionBlock:[OCMArg any] errorBlock:[OCMArg any]]);
    });
});

QuickSpecEnd
