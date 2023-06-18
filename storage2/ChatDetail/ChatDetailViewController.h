//
//  ChatDetailViewController.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <UIKit/UIKit.h>
#import "ChatMessageModel.h"
#import "ChatDetailViewModel.h"
#import "ChatDetailViewController.h"
@import IGListKit;
#import "ChatRoomModel.h"
#import "ChatDetailViewModel.h"
#import "MediaType.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "FileHelper.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface ChatDetailViewController : UIViewController <ChatDetailSectionControllerDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentBar;

//- (instancetype)initWithViewModel:(HomeViewModel *)viewModel;
@end

