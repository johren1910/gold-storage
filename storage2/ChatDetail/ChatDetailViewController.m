//
//  ChatDetailViewController.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import "ChatDetailViewController.h"
@import IGListKit;
#import "ChatModel.h"
#import "ChatDetailViewModel.h"


@interface ChatDetailViewController () <IGListAdapterDataSource>

@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) ChatDetailViewModel *viewModel;

@end


@implementation ChatDetailViewController

#pragma mark - View Lifecycle

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.viewModel = [[ChatDetailViewModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:[[IGListAdapterUpdater alloc] init] viewController:self];
    
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self;
    [self getData];
}

- (instancetype)initWithViewModel:(ChatDetailViewModel *)viewModel {
    if (!self) return nil;
    
    _viewModel = viewModel;
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)getData {
    __weak ChatDetailViewController *weakself = self;
    
    [self.viewModel getData:^(NSArray<ChatDetailModel *> * _Nonnull chats){
        
        [weakself.adapter reloadDataWithCompletion:nil];
        
    } error:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.viewModel.chats;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    ChatSectionController *chatSection = [ChatSectionController new];
    chatSection.delegate = self;
    return chatSection;
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

#pragma mark - ChatSectionControllerDelegate

- (void) didSelect: (ChatModel*) chat {
    NSLog(@"GOOOOOD %@", chat);
}



@end
