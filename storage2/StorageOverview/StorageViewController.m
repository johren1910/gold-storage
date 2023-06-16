//
//  StorageViewController.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import "StorageViewController.h"
@import IGListKit;


@interface StorageViewController () <IGListAdapterDataSource>

@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) StorageViewModel *viewModel;

@end


@implementation StorageViewController

#pragma mark - View Lifecycle

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.viewModel = [[StorageViewModel alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:[[IGListAdapterUpdater alloc] init] viewController:self];
    
//    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self;
}


- (void)viewWillAppear:(BOOL)animated {
    
}

#pragma mark - IGListAdapterDataSource

//- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
//    return self.viewModel.filteredChats;
//}
//
//- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
//    ChatDetailSectionController *chatSection = [ChatDetailSectionController new];
//    chatSection.delegate = self;
//    return chatSection;
//}
//
//- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
//    return nil;
//}

@end

