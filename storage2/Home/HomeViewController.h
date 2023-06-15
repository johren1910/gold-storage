//
//  ViewController.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <UIKit/UIKit.h>
#import "ChatModel.h"
#import "HomeViewModel.h"

@interface HomeViewController : UIViewController <ChatSectionControllerDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *homeCollectionView;
- (instancetype)initWithViewModel:(HomeViewModel *)viewModel;
@end
