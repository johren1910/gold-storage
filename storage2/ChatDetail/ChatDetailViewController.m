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


@interface ChatDetailViewController () <IGListAdapterDataSource, UIDocumentPickerDelegate>

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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adapter = [[IGListAdapter alloc] initWithUpdater:[[IGListAdapterUpdater alloc] init] viewController:self];
    
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
    
    [self.viewModel getData:^(NSArray<ChatDetailModel *> * _Nonnull chats){
        
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

- (void) didSelect: (ChatModel*) chat {
    NSLog(@"GOOOOOD %@", chat);
}

#pragma mark - Action

- (IBAction)onStoreLocalBtnTouched:(id)sender {
    
    // Import
//    UIDocumentPickerViewController* documentPicker =
//      [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.data"]
//                                                             inMode:UIDocumentPickerModeImport];
    
    // Choose folder
    UIDocumentPickerViewController* documentPicker =
          [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.folder"]
                                                                 inMode:UIDocumentPickerModeOpen];
    
    documentPicker.delegate = self;
    
    documentPicker.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:documentPicker animated:true completion:nil];
}


#pragma mark - DocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
   //Access folder
    if ( [urls[0] startAccessingSecurityScopedResource] )
    {
        
        //Construct the url: folder + name.extension
        NSURL *destURLPath = [urls[0] URLByAppendingPathComponent:@"Test.txt"];
        
        NSString *dataToWrite = @"This text is going into the file!";
        
        NSError *error = nil;
        
        //Write the data
        if( ![dataToWrite writeToURL:destURLPath atomically:true encoding:NSUTF8StringEncoding error:&error] )
            NSLog(@"%@",[error localizedDescription]);

        
        //Read file case ---
        NSData *fileData = [NSData dataWithContentsOfURL:destURLPath options:NSDataReadingUncached error:&error];
        
        if( fileData == nil )
            NSLog(@"%@",[error localizedDescription]);
        
        [urls[0] stopAccessingSecurityScopedResource];
    }
    else
    {
        NSLog(@"startAccessingSecurityScopedResource failed");
    }
}

@end
