//
//  StorageViewController.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import "StorageViewController.h"
#import "StorageViewModel.h"
@import IGListKit;
#import "CircleGraphView.h"
#import "StorageTableCell.h"

@interface StorageViewController () <StorageViewModelDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) id<StorageViewModelType> viewModel;
@property (strong, nonatomic) IBOutlet UIView *circleGraphHolder;
@property (strong, nonatomic) IBOutlet UILabel *percentageUsedLabel;
@property (strong, nonatomic) IBOutlet UITableView *storageTable;
@property (strong, nonatomic) IBOutlet UIProgressView *percentageBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@end

@implementation StorageViewController

#pragma mark - View Lifecycle

- (instancetype)initWithViewModel:(id<StorageViewModelType>)viewModel {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"StorageView" bundle:nil];
    StorageViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"StorageViewController"];
    
    self = ivc;
    self.viewModel = viewModel;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.viewModel.delegate = self;
    [self.viewModel onViewDidLoad];
    
    [self.storageTable registerNib:[UINib nibWithNibName:@"StorageTableCell" bundle:nil]
            forCellReuseIdentifier:@"StorageTableCell"];
    [self.storageTable setDataSource:self];
    [self.storageTable setDelegate:self];
}


- (void)viewWillAppear:(BOOL)animated {
    
}

#pragma mark - StorageViewModelDelegate

- (void)didUpdateData:(StorageEntity *)entity {
    float percentage = (float)entity.appSize/(float)entity.phoneSize;
    
    NSString* informText = [NSString stringWithFormat:@"Zalo uses %.1f%% of your disk space", (percentage*100)];
    [_percentageUsedLabel setText:informText];
    _percentageBar.progress = percentage;
    _percentageBar.progressTintColor = UIColor.systemBlueColor;
    _percentageBar.trackTintColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.1];
    
    [_storageTable reloadData];
    _tableViewHeightConstraint.constant = 64 * entity.storageSpaceItems.count;
    [self _updateCircle:entity];
    
}

-(void)_updateCircle:(StorageEntity*)entity {
    for (UIView* subview in self.circleGraphHolder.subviews) {
        if([subview class]== [CircleGraphView class]) {
            [subview removeFromSuperview];
            break;
        }
    }
    
    float currentDegree = 0;
    
    NSMutableArray *circleComponents = [[NSMutableArray alloc] init];
    for (StorageSpaceItem* item in entity.storageSpaceItems) {
        
        float nextDegree = currentDegree + item.percent * 360;
        
        
        CircleGraphComponent *component = [[CircleGraphComponent alloc] initWithOpenDegree:currentDegree closeDegree:nextDegree radius:100 color:item.color];
        
        currentDegree = nextDegree;
        
        [circleComponents addObject:component];
    }
    
    CircleGraphComponent *insideCircleComponent = [[CircleGraphComponent alloc] initWithOpenDegree:0 closeDegree:360 radius:30 color:[UIColor whiteColor]];
    
    [circleComponents addObject:insideCircleComponent];
    
    CGFloat rectSize = 200;
    CGRect rect = CGRectMake(_circleGraphHolder.bounds.size.width/2 - rectSize/2, 0, rectSize, rectSize);
    
    CGPoint circleCenter = CGPointMake(rect.size.width / 2, rect.size.height / 2);
    
    CircleGraphView *circleGraphView = [[CircleGraphView alloc] initWithFrame:rect centerPoint:circleCenter lineWidth:2 circleComponents:circleComponents];
    circleGraphView.backgroundColor = [UIColor whiteColor];
    
    [self.circleGraphHolder addSubview:circleGraphView];
}

#pragma mark - Tableview DataSource source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _viewModel.currentStorageEntity.storageSpaceItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIdentifier = @"StorageTableCell";
    StorageTableCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
    
    StorageSpaceItem* item = self.viewModel.currentStorageEntity.storageSpaceItems[indexPath.row];
    [cell setItem:item];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 64;
}

@end
