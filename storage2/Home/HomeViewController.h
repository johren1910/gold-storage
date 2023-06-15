//
//  ViewController.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <UIKit/UIKit.h>
#import "ChatModel.h"
#import "HomeViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : UIViewController

@property (strong, nonatomic) IBOutlet UICollectionView *homeCollectionView;
- (instancetype)initWithViewModel:(HomeViewModel *)viewModel;
@end

NS_ASSUME_NONNULL_END
