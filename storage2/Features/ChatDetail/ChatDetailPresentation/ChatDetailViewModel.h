//
//  ChatDetailViewModel.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//
#import <Foundation/Foundation.h>
#import "ChatDetailSectionController.h"
#import "ChatRoomEntity.h"
#import "ChatDetailUseCase.h"

@protocol ChatDetailViewModelDelegate <NSObject>

- (void) didUpdateData;
- (void) didUpdateObject:(ChatDetailEntity*)model;
- (void) didReloadData;

@end

@interface ChatDetailViewModel : NSObject

@property (nonatomic) id<ChatDetailUseCaseInterface> chatDetailUsecase;
- (ChatDetailEntity *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger) numberOfSections;
- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key;
- (void) onViewDidLoad;

#pragma mark - Actions
- (void)selectChatMessage:(ChatDetailEntity *) chat;
- (void)deselectChatMessage:(ChatDetailEntity *) chat;
- (void)retryWithModel:(ChatDetailEntity *)model;
- (void)deleteSelected;
- (void)setCheat:(BOOL)isOn;
- (void)changeSegment: (NSInteger) index;

- (void)requestAddImage:(NSData *)data;
- (void)requestDownloadFileWithUrl:(NSString *)url;

@property (nonatomic, weak) id <ChatDetailViewModelDelegate> delegate;
@property (copy,nonatomic) NSArray<ChatDetailEntity *> *filteredChats;

-(instancetype) initWithChatRoom:(ChatRoomEntity*)chatRoom andUsecase:(id<ChatDetailUseCaseInterface>)chatDetailUsecase;
@end
