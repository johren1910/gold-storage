//
//  HomeViewModel.h
//  storage
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>
#import "ChatRoomModel.h"
#import "ChatRoomSectionController.h"
#import "DatabaseManager.h"

@protocol HomeViewModelDelegate

- (void) didUpdateData;
- (void) didUpdateObject:(ChatRoomModel*)model;
- (void) didReloadData;

@end

@protocol HomeViewModelCoordinatorDelegate <NSObject>

-(void)didTapSetting;
-(void)didTapChatRoom: (ChatRoomModel*) chatRoom;

@end

@interface HomeViewModel : NSObject
- (void) selectChatRoom:(ChatRoomModel *) chatRoom;
- (void) deselectChatRoom:(ChatRoomModel *) chatRoom;
- (void)getData:(void (^)(NSMutableArray<ChatRoomModel *> *chats))successCompletion error:(void (^)(NSError *error))errorCompletion;

- (ChatRoomModel *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger) numberOfSections;
- (void)createNewChat: (NSString *) name;

@property (strong,nonatomic) NSMutableArray<ChatRoomModel *> *chats;

@property (nonatomic, weak) id <HomeViewModelDelegate>  delegate;
@property (nonatomic, strong) id <HomeViewModelCoordinatorDelegate>  coordinatorDelegate;
@property (nonatomic, strong) id<DatabaseManagerType> databaseManager;

@end
