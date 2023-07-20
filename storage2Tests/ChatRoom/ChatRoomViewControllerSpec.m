//
//  ChatRoomViewControllerTests.m
//  storage2Tests
//
//  Created by LAP14885 on 20/07/2023.
//

// Objective-C

@import Quick;
@import Nimble;

#import "ChatRoomViewController.h"
#import <OCMock/OCMock.h>

QuickSpecBegin(ChatRoomViewControllerSpec)

__block ChatRoomViewController *viewController = nil;
__block ChatRoomViewModel* mockViewModel = nil;
__block id mockChatRoomEntity = nil;

beforeEach(^{
    mockViewModel = OCMClassMock([ChatRoomViewModel class]);
    mockChatRoomEntity = OCMClassMock([ChatRoomEntity class]);
    viewController = [[ChatRoomViewController alloc] initWithViewModel:mockViewModel];
});

describe(@"-viewDidLoad", ^{
  beforeEach(^{
    [viewController view];
  });

  it(@"viewModel onViewDidLoad triggered", ^{
      
      OCMVerify([mockViewModel onViewDidLoad]);
  });
});

describe(@"-ChatSectionControllerDelegate", ^{
    beforeEach(^{
        [viewController view];
    });
    
    it(@"didSelect room", ^{
        
        [viewController didSelect:mockChatRoomEntity];
        
        OCMVerify([mockViewModel.coordinatorDelegate didTapChatRoom:mockChatRoomEntity]);
    });
    
    it(@"didSelect for delete room", ^{
        
        [viewController didSelectForDelete:mockChatRoomEntity];
        
        OCMVerify([mockViewModel selectChatRoom:mockChatRoomEntity]);
    });
    
    it(@"deSelect room", ^{
        
        [viewController didDeselect:mockChatRoomEntity];
        
        OCMVerify([mockViewModel deselectChatRoom:mockChatRoomEntity]);
    });
});

QuickSpecEnd
