//
//  ViewController.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import "HomeViewController.h"
@import IGListKit;
#import "ChatModel.h"
#import "ChatCell.h"
#import "ChatSectionController.h"


@interface HomeViewController () <IGListAdapterDataSource>

@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, copy) NSArray<ChatModel *> *chats;
@property (nonatomic, strong, readonly) HomeViewModel *viewModel;


@end


@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.chats = @[[[ChatModel alloc] initWithName:@"nice name" chatId:@"1"],
                   [[ChatModel alloc] initWithName:@"anothoer name" chatId:@"2"],
                   [[ChatModel alloc] initWithName:@"nice bye" chatId:@"3"],
                   [[ChatModel alloc] initWithName:@"nice ba" chatId:@"4"],
                   [[ChatModel alloc] initWithName:@"nice bubo" chatId:@"5"]
    ];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:[[IGListAdapterUpdater alloc] init] viewController:self];
    
    self.adapter.collectionView = self.homeCollectionView;
    self.adapter.dataSource = self;
}

- (instancetype)initWithViewModel:(HomeViewModel *)viewModel {
    if (!self) return nil;
    
    _viewModel = viewModel;
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
}

#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.chats;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    return [ChatSectionController new];
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

@end
