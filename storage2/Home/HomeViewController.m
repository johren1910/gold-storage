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
#import "HomeViewModel.h"


@interface HomeViewController () <IGListAdapterDataSource>

@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) HomeViewModel *viewModel;


@end


@implementation HomeViewController

#pragma mark - View Lifecycle

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.viewModel = [[HomeViewModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:[[IGListAdapterUpdater alloc] init] viewController:self];
    
    self.adapter.collectionView = self.homeCollectionView;
    self.adapter.dataSource = self;
    [self getData];
}

- (instancetype)initWithViewModel:(HomeViewModel *)viewModel {
    if (!self) return nil;
    
    _viewModel = viewModel;
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)getData {
    __weak HomeViewController *weakself = self;
    
    [self.viewModel getData:^(NSArray<ChatModel *> * _Nonnull chats){
        
        [weakself.adapter reloadDataWithCompletion:nil];
        
    } error:^(NSError * _Nonnull error) {
        
    }];
}

#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.viewModel.chats;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    return [ChatSectionController new];
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

@end

#pragma mark -Bindings
//- (void) bindViewModel {
//    @weakify(self);
//}
