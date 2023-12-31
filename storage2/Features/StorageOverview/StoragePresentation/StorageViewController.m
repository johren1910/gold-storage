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

#import "ChatDetailSectionController.h"

@interface StorageViewController () <StorageViewModelDelegate, UITableViewDelegate, UITableViewDataSource,
    IGListAdapterDataSource, ChatDetailSectionControllerDelegate>
@property (nonatomic, strong) id<StorageViewModelType> viewModel;
@property (strong, nonatomic) IBOutlet UIView *circleGraphHolder;
@property (strong, nonatomic) IBOutlet UILabel *percentageUsedLabel;
@property (strong, nonatomic) IBOutlet UITableView *storageTable;
@property (strong, nonatomic) IBOutlet UIProgressView *percentageBar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (strong, nonatomic) IBOutlet UIButton *clearBtn;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) IGListAdapter *adapter;
@property (strong, nonatomic) IBOutlet UIButton *deleteHeavyFileBtn;
@property (strong, nonatomic) IBOutlet IGListCollectionView *heavyCollectionView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *heavyCollectionViewHeight;
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
    
    self.adapter = [[IGListAdapter alloc] initWithUpdater:[[IGListAdapterUpdater alloc] init] viewController:self];
    self.adapter.collectionView = self.heavyCollectionView;
    self.adapter.dataSource = self;
    
    UINib *cellNib = [UINib nibWithNibName:@"ChatMessageCell" bundle:nil];
    [self.heavyCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"ChatMessageCell"];
    
    [self.storageTable registerNib:[UINib nibWithNibName:@"StorageTableCell" bundle:nil]
            forCellReuseIdentifier:@"StorageTableCell"];
    [self.storageTable setDataSource:self];
    [self.storageTable setDelegate:self];
    
    self.activityIndicator.hidesWhenStopped = YES;
    
    [self.deleteHeavyFileBtn setTitle:@"Clear Selected File" forState:normal];
    [self.deleteHeavyFileBtn setEnabled:false];
    self.heavyCollectionView.scrollEnabled = false;
}


- (void)viewWillAppear:(BOOL)animated {
    
}

#pragma mark - StorageViewModelDelegate

- (void)didUpdateData:(StorageEntity *)entity {
    __weak StorageViewController* weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (entity.appSize && entity.phoneSize) {
            float percentage = (float)entity.appSize/(float)entity.phoneSize;
            
            NSString* informText = [NSString stringWithFormat:@"Zalo uses %.2f%% of your disk space", (percentage*100)];
            [weakself.percentageUsedLabel setText:informText];
            weakself.percentageBar.progress = percentage;
            weakself.percentageBar.progressTintColor = UIColor.systemBlueColor;
            weakself.percentageBar.trackTintColor = [UIColor.systemBlueColor colorWithAlphaComponent:0.1];
        }
        
        if (entity.storageSpaceItems) {
            weakself.tableViewHeightConstraint.constant = 64 * entity.storageSpaceItems.count;
            [weakself _updateCircle:entity];
            
            long long totalSelectedSize = 0;
            NSInteger selectedCount = 0;
            for (StorageSpaceItem* item in entity.storageSpaceItems) {
                if(item.selected) {
                    totalSelectedSize += item.size;
                    selectedCount+=1;
                }
            }
            
            if (selectedCount == entity.storageSpaceItems.count) {
                [weakself.clearBtn setTitle:[NSString stringWithFormat:@"Clear Entire Data %@", [FileHelper sizeStringFormatterFromBytes:totalSelectedSize]] forState:normal];
            } else {
                [weakself.clearBtn setTitle:[NSString stringWithFormat:@"Clear Selected %@", [FileHelper sizeStringFormatterFromBytes:totalSelectedSize]] forState:normal];
            }
            
            if (totalSelectedSize == 0) {
                [weakself.clearBtn setEnabled:false];
                [weakself.clearBtn setTitle:@"Clear Selected" forState:normal];
            } else {
                [weakself.clearBtn setEnabled:true];
            }
        }
        
        
    });
}

- (void) reloadTable {
    
    __weak StorageViewController* weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.storageTable reloadData];
    });
    
}
                   
-(void)didFinishUpdate {
    __weak StorageViewController* weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.activityIndicator stopAnimating];
    });
}
                   
-(void)needUpdateHeavyCollection {
    __weak StorageViewController* weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.adapter performUpdatesAnimated:true completion:nil];
    });
}
                   
-(void)didUpdateObject:(ChatDetailEntity*)model {
    __weak StorageViewController *weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.adapter reloadObjects:@[model]];
        
        if (weakself.viewModel.selectedModels.count == 0) {
            
            [weakself.deleteHeavyFileBtn setEnabled:false];
            [weakself.deleteHeavyFileBtn setTitle:@"Clear Selected" forState:normal];
        } else {
            [weakself.deleteHeavyFileBtn setEnabled:true];
            
            double totalSize = 0;
            for (ChatDetailEntity* entity in weakself.viewModel.selectedModels) {
                totalSize += (entity.file.size * 1000 * 1000);
            }
            
            [weakself.deleteHeavyFileBtn setTitle:[NSString stringWithFormat:@"Clear Selected %@", [FileHelper sizeStringFormatterFromBytes:totalSize]] forState:normal];
        }
    });
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
        if (item == [entity.storageSpaceItems lastObject]) {
            nextDegree = 360;
        }
        
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    StorageTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell didTouch];
    NSInteger row = [indexPath row];
    [_viewModel didTouchTypeCell:row];
}

- (IBAction)onDeleteBtnTouched:(id)sender {
    [ self.activityIndicator startAnimating];
    [_viewModel didTouchDeleteTypeBtn];
}
                   
- (IBAction)onHeavyDeleteBtnTouched:(id)sender {
        [ self.activityIndicator startAnimating];
        [_viewModel didTouchDeleteHeavyBtn];
}
#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
        __weak StorageViewController* weakself = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            double rowHeight = weakself.heavyCollectionView.bounds.size.width/3;
            
            long row = weakself.viewModel.messageModels.count/3 + 1;
            double height = rowHeight * row;
            weakself.heavyCollectionViewHeight.constant = height;
            
        });
    return self.viewModel.messageModels;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    ChatDetailSectionController *chatSection = [ChatDetailSectionController new];
    chatSection.delegate = self;
    return chatSection;
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}
                   
#pragma mark - ChatDetailSectionControllerDelegate

- (void) didSelect: (ChatDetailEntity*) chat {
    [_viewModel didTouchHeavyCell:chat];
    
}

- (void) didDeselect: (ChatDetailEntity*) chat {
    [_viewModel didTouchHeavyCell:chat];
        
}


- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key {
    
}

- (void) retryWithModel:(ChatDetailEntity *)model {
    
}

@end
