//
//  ChatDetailViewController.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <UIKit/UIKit.h>
#import "ChatDetailModel.h"
#import "ChatDetailViewModel.h"

@interface ChatDetailViewController : UIViewController <ChatSectionControllerDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentBar;

//- (instancetype)initWithViewModel:(HomeViewModel *)viewModel;
@end

