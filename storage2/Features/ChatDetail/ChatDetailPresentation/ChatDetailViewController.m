//
//  ChatDetailViewController.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import "ChatDetailViewController.h"
#import "ZOStatePresentable.h"

@interface ChatDetailViewController () <IGListAdapterDataSource, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, ChatDetailViewModelDelegate>

@property (nonatomic, strong) IGListAdapter *adapter;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentBar;
@property (strong, nonatomic) IBOutlet UISwitch *cheatSwitch;
@property (nonatomic, strong) id<ChatDetailViewModelType> viewModel;
@property (nonatomic, readonly) NSInteger selectedIndex;
@property (strong, nonatomic) IBOutlet UIView *collectionViewHolder;
@property (nonatomic) id<ChatDetailBuilderType> builder;
@property (nonatomic, strong) id<ZOStatePresentable> statePresenter;

@end

@implementation ChatDetailViewController

#pragma mark - View Lifecycle

-(void)setDetailBuilder:(id<ChatDetailBuilderType>)builder {
    self.builder = builder;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:[[IGListAdapterUpdater alloc] init] viewController:self];
    self.viewModel.delegate = self;
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self;
    [_segmentBar addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [self.viewModel onViewDidLoad];
    
    UINib *cellNib = [UINib nibWithNibName:@"ChatMessageCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"ChatMessageCell"];
    
    self.statePresenter = [[ZOStatePresenter alloc] init:self.collectionViewHolder loadingStateView:self.loadingStateView emptyStateView:nil errorStateView:nil];
}

- (id<ViewModelType>)getViewModel {
    return _viewModel;
}

- (void) segmentChanged: (UISegmentedControl*) sender {
    NSLog(@"SEGMENT CHANGED %ld", (long)sender.selectedSegmentIndex);
    _selectedIndex = sender.selectedSegmentIndex;
                
    [_viewModel changeSegment:_selectedIndex];
    [self.adapter performUpdatesAnimated:true completion:nil];
}

- (instancetype)initWithViewModel:(id<ChatDetailViewModelType>)viewModel {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatDetailView" bundle:nil];
    ChatDetailViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"ChatDetailViewController"];
    
    self = ivc;
    self.viewModel = viewModel;
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    
}

#pragma mark - IGListAdapterDataSource

- (NSArray<id<IGListDiffable>> *)objectsForListAdapter:(IGListAdapter *)listAdapter {
    return self.viewModel.filteredChats;
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
    [_viewModel selectChatMessage:chat];
}

- (void) didDeselect: (ChatDetailEntity*) chat {
    [_viewModel deselectChatMessage:chat];
}


- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key {
    [[self.builder getCacheService] cacheImageByKey:image withKey:key];
}

- (void) retryWithModel:(ChatDetailEntity *)model {
    [_viewModel retryWithModel:model];
}

#pragma mark - ChatDetailViewModelDelegate

- (void) didUpdateObject:(ChatDetailEntity*)model {
    __weak ChatDetailViewController *weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.adapter reloadObjects:@[model]];
    });
    
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

- (void)didUpdateData {
    __weak ChatDetailViewController *weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.adapter performUpdatesAnimated:true completion:nil];
    });
    
}

- (void)didReloadData {
    __weak ChatDetailViewController *weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakself.adapter reloadDataWithCompletion:nil];
    });
}

#pragma mark - StatePresentable
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



#pragma mark - Action

- (IBAction)onDownloadButtonTouched:(id)sender {
    [self createInputAlert];
}

- (IBAction)onDeleteButtonTouched:(id)sender {
    [_viewModel deleteSelected];
}

- (IBAction)onVideoImagesLocalBtnTouched:(id)sender {
    
    [self requestAuthorizationWithRedirectionToSettings];
}
- (IBAction)onCheatSwitchValueChanged:(id)sender {
    [_viewModel setCheat:[sender isOn]];
}

- (void) createInputAlert {
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Input link to download"
                                                                              message: @"Media link"
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Link";
        textField.text = @"https://www.adobe.com/express/feature/image/media_16ad2258cac6171d66942b13b8cd4839f0b6be6f3.png";
   
        textField.textColor = [UIColor blueColor];
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];

    __weak ChatDetailViewController *weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * namefield = textfields[0];
        NSString *name = namefield.text;
        
        [weakSelf.viewModel requestDownloadFileWithUrl:name];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler: nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *fileType = [info objectForKey: UIImagePickerControllerMediaType];
    if (CFStringCompare ((__bridge_retained CFStringRef)fileType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        NSURL *url = [info objectForKey:@"UIImagePickerControllerReferenceURL"];
        
        PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
        
        PHAsset *asset = result.firstObject;
        __weak ChatDetailViewController *weakself = self;
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            
            [weakself.viewModel requestAddImage:imageData];
        }];
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)requestAuthorizationWithRedirectionToSettings {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusAuthorized)
        {
            UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
            mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            mediaUI.allowsEditing = NO;
            mediaUI.mediaTypes =
            [UIImagePickerController availableMediaTypesForSourceType:
             UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            mediaUI.delegate = self;
            
            [self presentViewController:mediaUI animated:YES completion:NULL];
        }
        else
        {
            //No permission. Trying to normally request it
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status != PHAuthorizationStatusAuthorized)
                {
                    //User don't give us permission. Showing alert with redirection to settings
                    //Getting description string from info.plist file
                    NSString *accessDescription = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
                    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:accessDescription message:@"To give permissions tap on 'Change Settings' button" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
                    [alertController addAction:cancelAction];
                    
                    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:@"Change Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    }];
                    [alertController addAction:settingsAction];
                    
                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
                }
            }];
        }
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
