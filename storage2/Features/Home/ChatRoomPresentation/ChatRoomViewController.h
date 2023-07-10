//
//  ViewController.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <UIKit/UIKit.h>
#import "ChatRoomData.h"
#import "ChatRoomViewModel.h"
#import "ZOStatePresentable.h"

@interface ChatRoomViewController : UIViewController <ChatRoomSectionControllerDelegate, ViewControllerType>

@property (strong, nonatomic) IBOutlet UICollectionView *homeCollectionView;

@end
