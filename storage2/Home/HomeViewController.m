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
#import "ChatDetailViewController.h"


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
    
    [self.viewModel getData:^(NSMutableArray<ChatModel *> * _Nonnull chats){
        
        [weakself.adapter reloadDataWithCompletion:nil];
        
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

- (void) didSelect: (ChatModel*) chat {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ChatDetailView" bundle:nil];
    ChatDetailViewController *ivc = [storyboard instantiateViewControllerWithIdentifier:@"ChatDetailViewController"];
    
    [self.navigationController pushViewController:ivc animated:true];
}
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
               
               [weakSelf.adapter reloadDataWithCompletion:nil];
           }
           
       }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler: nil]];
       [self presentViewController:alertController animated:YES completion:nil];
}



@end
