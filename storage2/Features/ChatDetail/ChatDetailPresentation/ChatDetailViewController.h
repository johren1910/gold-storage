//
//  ChatDetailViewController.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <UIKit/UIKit.h>
#import "ChatDetailEntity.h"
#import "ChatDetailViewModel.h"
@import IGListKit;
#import "ChatRoomEntity.h"
#import "FileType.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "FileHelper.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "ChatDetailBuilder.h"

@interface ChatDetailViewController : UIViewController <ChatDetailSectionControllerDelegate, ViewControllerType>

-(void)setDetailBuilder:(id<ChatDetailBuilderType>)builder;
@end

