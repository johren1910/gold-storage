//
//  ChatDetailViewController.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import "ChatDetailViewController.h"

@interface ChatDetailViewController () <IGListAdapterDataSource, UIDocumentPickerDelegate, UIImagePickerControllerDelegate, ChatDetailViewModelDelegate>

@property (nonatomic, strong) IGListAdapter *adapter;
@property (nonatomic, strong) ChatDetailViewModel *viewModel;
@property (nonatomic, readonly) NSUInteger *selectedIndex;

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

- (void)didUpdateData {
    [_adapter reloadDataWithCompletion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:[[IGListAdapterUpdater alloc] init] viewController:self];
    self.viewModel.delegate = self;
    self.adapter.collectionView = self.collectionView;
    self.adapter.dataSource = self;
    [_segmentBar addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
    [self getData];
    
    UINib *cellNib = [UINib nibWithNibName:@"ChatDetailCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:@"ChatDetailCell"];
}

- (void) segmentChanged: (UISegmentedControl*) sender {
    NSLog(@"SEGMENT CHANGED %ld", (long)sender.selectedSegmentIndex);
    _selectedIndex = sender.selectedSegmentIndex;
    [_viewModel changeSegment:_selectedIndex];
    [self.adapter reloadDataWithCompletion:nil];
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
    
    [self.viewModel getData:^(NSArray<ChatMessageModel *> * _Nonnull chats){
        
        [weakself.adapter reloadDataWithCompletion:nil];
        
    } error:^(NSError * _Nonnull error) {
        
    }];
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

- (void) didSelect: (ChatRoomModel*) chat {
    NSLog(@"GOOOOOD %@", chat);
}

#pragma mark - Action

- (IBAction)onFileLocalBtnTouched:(id)sender {
    // Import
        UIDocumentPickerViewController* documentPicker =
          [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"]
                                                                 inMode:UIDocumentPickerModeImport];
    
        documentPicker.delegate = self;
    
        documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    
        [self presentViewController:documentPicker animated:true completion:nil];
}

- (IBAction)onVideoImagesLocalBtnTouched:(id)sender {
    
    [self requestAuthorizationWithRedirectionToSettings];
}


#pragma mark - DocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
    
    NSURL* url = urls.firstObject;
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    NSError *error = nil;
    
    
    __weak ChatDetailViewController *weakself = self;
    [coordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
        NSData *data = [NSData dataWithContentsOfURL:newURL];
        NSLog(@"data %@", data);
        [weakself.viewModel addFile:data];
        // Do something
    }];
    if (error) {
        // Do something else
    }
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    [self dismissViewControllerAnimated:NO completion:nil];
    if (CFStringCompare ((__bridge_retained CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo)
    {
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        [_viewModel addImage:image];
        [picker dismissViewControllerAnimated:YES completion:nil];
        [_adapter reloadDataWithCompletion:nil];
    }
}

- (void)requestAuthorizationWithRedirectionToSettings {
    dispatch_async(dispatch_get_main_queue(), ^{
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusAuthorized)
        {
            UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
            mediaUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
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
    });
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
