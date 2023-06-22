//
//  ViewController.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import "HomeViewController.h"
@import IGListKit;
#import "ChatRoomModel.h"
#import "ChatRoomCell.h"
#import "ChatSectionController.h"
#import "HomeViewModel.h"
#import "ChatDetailViewController.h"
#import "StorageViewController.h"
#import "Coordinator.h"
#import "ZOStatePresentable.h"


@interface HomeViewController () <IGListAdapterDataSource, HomeViewModelDelegate, ZOStatePresentable>

@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) HomeViewModel *viewModel;
@property (strong, nonatomic) IBOutlet UIView *collectionViewHolder;
@property (nonatomic, strong) ZOStatePresenter* statePresenter;

@end

@implementation HomeViewController

@synthesize emptyStateView;
@synthesize errorStateView;
@synthesize loadingStateView;
@synthesize stateContainerView;

#pragma mark - View Lifecycle

- (void)setViewModel:(HomeViewModel *)viewModel {
    _viewModel = viewModel;
    _viewModel.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:[[IGListAdapterUpdater alloc] init] viewController:self];
    
    self.adapter.collectionView = self.homeCollectionView;
    self.adapter.dataSource = self;
    self.statePresenter = [[ZOStatePresenter alloc] init:self.collectionViewHolder loadingStateView:self.loadingStateView emptyStateView:nil errorStateView:nil];
    
    UINib *cellNib = [UINib nibWithNibName:@"ChatRoomCell" bundle:nil];
    
    [self.homeCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"ChatRoomCell"];
    [self getData];
}

- (UIView*) loadingStateView {
    UIView *loadingView = [[UIView alloc] init];
    [loadingView setBackgroundColor: UIColor.lightGrayColor];
    [loadingView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [loadingView removeConstraints:loadingView.constraints];

    //TODO: - Add Skeleton loading shimmer animation
    
    return loadingView;
}

- (void)viewWillAppear:(BOOL)animated {
    
}

- (void)getData {
    __weak HomeViewController *weakself = self;
    [self.statePresenter startLoading:YES completionHandler:nil];
    [self.viewModel getData:^(NSMutableArray<ChatRoomModel *> * _Nonnull chats){
        BOOL hasContent = (chats.count == 0);
        [weakself.statePresenter endLoading:YES hasContent:hasContent completionHandler:nil];

        [weakself.adapter performUpdatesAnimated:true completion:nil];

    } error:^(NSError * _Nonnull error) {

    }];
}

#pragma mark - IGListAdapterDataSource

- (NSMutableArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
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

- (void) didSelect: (ChatRoomModel*) chat {
    
    [_viewModel.coordinatorDelegate didTapChatRoom:chat];
}

#pragma mark - Action

- (IBAction)onCreateBtnTouch:(id)sender {
    [self createAlert];
}

- (void) createAlert {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Create new chat"
                                                                              message: @"Input chat name:"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Name";
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    
    __weak HomeViewController *weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        NSString *name = namefield.text;
        if ([name length] != 0) {
            [weakSelf.viewModel createNewChat:name];
            
            [weakSelf.adapter performUpdatesAnimated:true completion:nil];
        }
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler: nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (IBAction)onSettingBtnTouched:(id)sender {
    
    [_viewModel.coordinatorDelegate didTapSetting];
}

#pragma mark - HomeViewModelDelegate
- (void) didUpdateData {
    [self.adapter performUpdatesAnimated:true completion:nil];
}

@end
