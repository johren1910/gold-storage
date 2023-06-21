//
//  StorageViewController.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import "StorageViewController.h"
@import IGListKit;
#import "CircleGraphView.h"

@interface StorageViewController () <IGListAdapterDataSource>

@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) StorageViewModel *viewModel;
@property (strong, nonatomic) IBOutlet UIView *circleGraphHolder;

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
    
    CircleGraphComponent *component1 = [[CircleGraphComponent alloc] initWithOpenDegree:0 closeDegree:30 radius:100 color:[UIColor redColor]];
    
    CircleGraphComponent *component2 = [[CircleGraphComponent alloc] initWithOpenDegree:30 closeDegree:300 radius:100 color:[UIColor blueColor]];
    
    CircleGraphComponent *component3 = [[CircleGraphComponent alloc] initWithOpenDegree:300 closeDegree:360 radius:100 color:[UIColor greenColor]];
    
    NSArray *circleComponents = [[NSArray alloc] initWithObjects:component1, component2, component3, nil];
    
    CGFloat rectSize = 200;
    CGRect rect = CGRectMake(_circleGraphHolder.bounds.size.width/2 - rectSize/2, 0, rectSize, rectSize);
    
    CGPoint circleCenter = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    
    CircleGraphView *circleGraphView = [[CircleGraphView alloc] initWithFrame:rect centerPoint:circleCenter lineWidth:2 circleComponents:circleComponents];
    circleGraphView.backgroundColor = [UIColor whiteColor];
    
    [self.circleGraphHolder addSubview:circleGraphView];
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

