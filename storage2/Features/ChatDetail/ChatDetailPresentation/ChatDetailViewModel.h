//
//  ChatDetailViewModel.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//
#import <Foundation/Foundation.h>
#import "ChatDetailSectionController.h"
#import "ChatRoomModel.h"
#import "StorageManagerType.h"
#import "ZODownloadManager.h"
#import "ChatDetailUseCase.h"

@protocol ChatDetailViewModelDelegate <NSObject>

- (void) didUpdateData;
- (void) didUpdateObject:(ChatDetailEntity*)model;
- (void) didReloadData;

@end

@interface ChatDetailViewModel : NSObject

@property (nonatomic) id<ChatDetailUseCaseInterface> chatDetailUsecase;

- (void) selectChatMessage:(ChatDetailEntity *) chat;
- (void) deselectChatMessage:(ChatDetailEntity *) chat;
- (void) onViewDidLoad;
- (void)changeSegment: (NSInteger) index;
- (ChatDetailEntity *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger) numberOfSections;
- (void)requestAddImage:(NSData *)data;
- (void)requestDownloadFileWithUrl:(NSString *)url;
- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key;
- (void)deleteSelected;
- (void)setCheat:(BOOL)isOn;

- (void)retryWithModel:(ChatDetailEntity *)model;

@property (nonatomic, weak) id <ChatDetailViewModelDelegate> delegate;
@property (copy,nonatomic) NSArray<ChatDetailEntity *> *filteredChats;
@property (nonatomic, strong) id<StorageManagerType> storageManager;
@property (nonatomic, strong) id<ZODownloadManagerType> downloadManager;

-(instancetype) initWithChatRoom:(ChatRoomModel*)chatRoom andUsecase:(id<ChatDetailUseCaseInterface>)chatDetailUsecase;
@end
