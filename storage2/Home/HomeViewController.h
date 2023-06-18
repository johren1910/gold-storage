//
//  ViewController.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <UIKit/UIKit.h>
#import "ChatRoomModel.h"
#import "HomeViewModel.h"

@interface HomeViewController : UIViewController <ChatSectionControllerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *homeCollectionView;
- (void)setViewModel:(HomeViewModel *)viewModel;
@end
