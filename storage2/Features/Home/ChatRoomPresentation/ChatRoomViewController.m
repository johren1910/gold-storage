//
//  ViewController.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import "ChatRoomViewController.h"
@import IGListKit;
#import "ChatRoomData.h"
#import "ChatRoomCell.h"
#import "ChatRoomSectionController.h"
#import "ChatRoomViewModel.h"
#import "ChatDetailViewController.h"
#import "StorageViewController.h"
#import "Coordinator.h"
#import "ZOStatePresentable.h"


@interface ChatRoomViewController () <IGListAdapterDataSource, ChatRoomViewModelDelegate>

@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) ChatRoomViewModel *viewModel;
@property (strong, nonatomic) IBOutlet UIView *collectionViewHolder;
@property (nonatomic, strong) id<ZOStatePresentable> statePresenter;

@end

@implementation ChatRoomViewController

#pragma mark - View Lifecycle

- (instancetype)initWithViewModel:(id<ChatRoomViewModelType>)viewModel {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatRoomView" bundle:nil];
    ChatRoomViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"ChatRoomViewController"];
    
    self = ivc;
    self.viewModel = viewModel;
    self.viewModel.delegate = self;
    return self;
}

- (id<ViewModelType>)getViewModel {
    return _viewModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:[[IGListAdapterUpdater alloc] init] viewController:self];
    
    self.adapter.collectionView = self.homeCollectionView;
    self.adapter.dataSource = self;
    self.statePresenter = [[ZOStatePresenter alloc] init:self.collectionViewHolder loadingStateView:self.loadingStateView emptyStateView:nil errorStateView:nil];
    
    UINib *cellNib = [UINib nibWithNibName:@"ChatRoomCell" bundle:nil];
    
    [self.homeCollectionView registerNib:cellNib forCellWithReuseIdentifier:@"ChatRoomCell"];
    [self.viewModel onViewDidLoad];
}

- (SkeletonView*) loadingStateView {
    SkeletonView *loadingView = [[SkeletonView alloc] init];
    [loadingView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [loadingView removeConstraints:loadingView.constraints];
    return loadingView;
}

- (UIView*) emptyStateView {
    UIView *emptyView = [[UIView alloc] init];
    [emptyView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [emptyView removeConstraints:emptyView.constraints];
    return emptyView;
}

#pragma mark - IGListAdapterDataSource

- (NSMutableArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.viewModel.chats;
}

- (IGListSectionController *)listAdapter:(IGListAdapter *)listAdapter sectionControllerForObject:(id)object {
    ChatRoomSectionController *chatSection = [ChatRoomSectionController new];
    chatSection.delegate = self;
    return chatSection;
}

- (UIView *)emptyViewForListAdapter:(IGListAdapter *)listAdapter {
    return nil;
}

#pragma mark - ChatSectionControllerDelegate

- (void) didSelect: (ChatRoomEntity*) chat {
    
    [_viewModel.coordinatorDelegate didTapChatRoom:chat];
}

- (void) didSelectForDelete: (ChatRoomEntity*) chatRoom {
    [_viewModel selectChatRoom:chatRoom];
}

- (void) didDeselect: (ChatRoomEntity*) chatRoom {
    [_viewModel deselectChatRoom:chatRoom];
}

- (void) startLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.statePresenter startLoading:YES completionHandler:nil];
    });
}
- (void) endLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.statePresenter endLoading:true hasContent:true completionHandler:nil];
    });
}



#pragma mark - Action

- (IBAction)onCreateBtnTouch:(id)sender {
    [self createAlert];
}

- (IBAction)onDeleteBtnTouched:(id)sender {
    [_viewModel deleteSelected];
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
    
    __weak ChatRoomViewController *weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        NSString *name = namefield.text;
        if ([name length] != 0) {
            [weakSelf.viewModel requestCreateNewChat:name];
            
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
    __weak ChatRoomViewController *weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.adapter performUpdatesAnimated:true completion:nil];
    });
}

- (void) didUpdateObject:(ChatRoomEntity*)model {
    __weak ChatRoomViewController *weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.adapter reloadObjects:@[model]];
    });
    
   
}
- (void) didReloadData {
    __weak ChatRoomViewController *weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.adapter reloadDataWithCompletion:nil];
    });
}

@end
