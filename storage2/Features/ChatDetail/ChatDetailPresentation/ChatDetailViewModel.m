//
//  ChatDetailViewModel.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

#import "ChatDetailViewModel.h"
#import "ChatMessageData.h"
#import "ChatDetailEntity.h"
#import "FileType.h"
#import <objc/runtime.h>

@interface ChatDetailViewModel ()
@property (retain,nonatomic) NSMutableArray<ChatDetailEntity *> *messageModels;
@property (retain,nonatomic) NSMutableArray<ChatDetailEntity *> *selectedModels;
@property (nonatomic, copy) ChatRoomEntity *chatRoom;
@property (nonatomic) BOOL isCheatOn;
@property (nonatomic) dispatch_queue_t backgroundQueue;
@end

@implementation ChatDetailViewModel

-(instancetype) initWithChatRoom:(ChatRoomEntity*)chatRoom andBusinessModel:(id<ChatDetailBusinessModelInterface>)chatDetailBusinessModel {
    self = [super init];
    if (self) {
        self.messageModels = [[NSMutableArray alloc] init];
        self.selectedModels = [[NSMutableArray alloc] init];
        self.backgroundQueue = dispatch_queue_create("com.chatdetai.viewmodel.backgroundqueue", DISPATCH_QUEUE_SERIAL);
        self.isCheatOn = FALSE;
        self.chatDetailBusinessModel = chatDetailBusinessModel;
    }
    _chatRoom = chatRoom;
    
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.messageModels = [[NSMutableArray alloc] init];;
        if ([[UICollectionView class] instancesRespondToSelector:@selector(setPrefetchingEnabled:)]) {
            [[UICollectionView appearance] setPrefetchingEnabled:NO];
        }
    }
    
    return self;
}

@synthesize delegate;

- (void) onViewDidLoad {
    [self _loadData];
}

- (void)_loadData {
    __weak ChatDetailViewModel *weakself = self;
    [_chatDetailBusinessModel getChatDetailsOfRoomId:_chatRoom.roomId completionBlock:^(NSArray<ChatDetailEntity*>* entities) {
        
        for (ChatDetailEntity* entity in entities) {
            if (entity.state == Downloading) {
                [weakself _requestDownloadForEntity:entity];
            }
        }
        
        weakself.messageModels = [entities mutableCopy];
        weakself.filteredChats = weakself.messageModels;
        [weakself.delegate didUpdateData];
    } errorBlock:^(NSError* error) {
        
    }];
}

-(void)_requestDownloadForEntity:(ChatDetailEntity*) entity {
    
    __weak ChatDetailViewModel* weakself = self;
    [_chatDetailBusinessModel resumeDownloadForEntity:entity OfRoom:_chatRoom completionBlock:^(ChatDetailEntity* entity){
        __block NSUInteger index = 0;
        [weakself.messageModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([((ChatDetailEntity *)obj).messageId isEqualToString:entity.messageId]) {
                index = idx;
                *stop = YES;
            }

        }];
        
        [weakself.messageModels replaceObjectAtIndex:index withObject:entity];
        weakself.filteredChats = weakself.messageModels;

        [weakself.delegate didUpdateData];
    } errorBlock:^(NSError* error) {
        
    }];
}

- (ChatDetailEntity *)itemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.filteredChats.count) {
        return nil;
    }
    
    return self.filteredChats[indexPath.row];
}

- (void)changeSegment: (NSInteger) index {
    if (index == 0) {
        self.filteredChats = _messageModels;
        [self.delegate didUpdateData];
        return;
    }
    
    NSString *predicateString = @"file.type =[c] %ld";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString, index];
    
    if (index == 1) {
         predicate = [NSPredicate predicateWithFormat:predicateString, Picture];
    } else if (index == 2) {
         predicate = [NSPredicate predicateWithFormat:predicateString, Video];
    }
    
    NSArray *filteredArray = [_messageModels filteredArrayUsingPredicate:predicate];
    self.filteredChats = filteredArray;
}

- (NSUInteger) numberOfSections {
    return 1;
}

- (NSArray<ChatDetailEntity*>*) items {
    return self.filteredChats;
}

- (void)requestDownloadFileWithUrl:(NSString *)url {
    if (_isCheatOn) {
        NSString* link1 = @"https://getsamplefiles.com/download/mp4/sample-5.mp4";
        NSString* link2 = @"https://joy1.videvo.net/videvo_files/video/free/2016-05/large_watermarked/Mykonos_2_preview.mp4";
        NSString* link3 = @"https://joy1.videvo.net/videvo_files/video/free/2016-08/large_watermarked/VID_20160517_175443_preview.mp4";
        NSString* link4 = @"https://freetestdata.com/wp-content/uploads/2022/02/Free_Test_Data_7MB_MP4.mp4";
        NSString* link5 = @"https://joy1.videvo.net/videvo_files/video/free/2013-11/large_watermarked/SUPER8MMSTOCKEMULTIONNicholasLever_preview.mp4";
        NSString* link6 = @"https://joy1.videvo.net/videvo_files/video/free/2015-08/large_watermarked/Dream_lake_1_preview.mp4";
        NSString* link7 = @"https://joy1.videvo.net/videvo_files/video/free/2015-08/large_watermarked/Surfer1_preview.mp4";
        NSString* link8 = @"https://freetestdata.com/wp-content/uploads/2022/02/Free_Test_Data_5.05MB_MOV.mov";
        NSString* link9 = @"https://freetestdata.com/wp-content/uploads/2022/02/Free_Test_Data_2MB_MP4.mp4";
        NSString* link10 = @"https://freetestdata.com/wp-content/uploads/2021/10/Free_Test_Data_1MB_MOV.mov";
        
        NSString* link11 = @"https://www.adobe.com/express/feature/image/media_16ad2258cac6171d66942b13b8cd4839f0b6be6f3.png";
        NSString* link12 = @"https://uhdwallpapers.org/uploads/cache/4193401285/bmw-ce-04_400x225-mm-90.jpg";
        NSString* link13 = @"https://kinsta.com/wp-content/uploads/2020/08/tiger-jpg.jpg";
        NSString* link14 = @"https://images8.alphacoders.com/468/thumb-1920-468739.jpg";
        NSString* link15 = @"https://images.hdqwalls.com/download/kimetsu-no-yaiba-anime-4k-yn-1920x1080.jpg";
        NSString* link16 = @"https://c4.wallpaperflare.com/wallpaper/952/536/1006/winter-4k-pc-desktop-wallpaper-preview.jpg";
        NSString* link17 = @"https://w0.peakpx.com/wallpaper/147/852/HD-wallpaper-anime-dragon-ball-z-animr.jpg";
        NSString* link18 = @"https://images.hdqwalls.com/wallpapers/the-valley-minimal-4k-9y.jpg";
        NSString* link19 = @"https://images.hdqwalls.com/wallpapers/2022-marvels-spider-man-pc-4k-f2.jpg";
        NSString* link20 = @"https://cdn.wallpaperhub.app/cloudcache/f/0/3/f/8/a/f03f8a91e5396f8bb7cebaf7410d9a619e14ed7f.jpg";
        

        NSArray<NSString*>* rand = @[link1,link2,link3,link4,link5,link6,link7,link8,link9,link10,link11,link12,link13,link14,link15,link16,link17,link18,link19,link20];
        dispatch_async(_backgroundQueue, ^{
            for (int i=0; i<100; i++) {
                NSLog(@"LOG 1");
                uint32_t rnd = arc4random_uniform(rand.count);
                NSString *chosenUrl = [rand objectAtIndex:rnd];
                
                [self _downloadFileWithUrl:chosenUrl];
            }
        });
    } else {
        [self _downloadFileWithUrl:url];
    }
}

- (void)_downloadFileWithUrl:(NSString *)url {
    
    __weak ChatDetailViewModel* weakself = self;
    [_chatDetailBusinessModel requestDownloadFileWithUrl:url forRoom:_chatRoom completionBlock:^(ChatDetailEntity* entity, BOOL isDownloaded) {
        if (!isDownloaded && entity) {
            [weakself.messageModels insertObject:entity atIndex:0];
            weakself.filteredChats = weakself.messageModels;
            [weakself.delegate didUpdateData];
            return;
        }
        
        if (isDownloaded) {
            __block NSUInteger index = 0;
            [weakself.messageModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([((ChatDetailEntity *)obj).messageId isEqualToString:entity.messageId]) {
                    index = idx;
                    *stop = YES;
                }

            }];
            
            [weakself.messageModels replaceObjectAtIndex:index withObject:entity];
            weakself.filteredChats = weakself.messageModels;
            [weakself.delegate didUpdateData];
        }
    } errorBlock:^(NSError *error){
        
    }];
}

- (void) selectChatMessage:(ChatDetailEntity *) chat {
    [_selectedModels addObject:chat];
    for (ChatDetailEntity *model in _messageModels) {
        if (chat.messageId == model.messageId) {
            
            model.selected = TRUE;
            break;
        }
    }
    self.filteredChats = self.messageModels;
    
    [self.delegate didUpdateObject:chat];
}
- (void) deselectChatMessage:(ChatDetailEntity *) chat {
    [_selectedModels removeObject:chat];
    for (ChatDetailEntity *model in _messageModels) {
        if (chat.messageId == model.messageId) {
            
            model.selected = FALSE;
            break;
        }
    }
    self.filteredChats = self.messageModels;
    [self.delegate didUpdateObject:chat];
}

- (void)deleteSelected {
    __weak ChatDetailViewModel* weakself = self;
    [_chatDetailBusinessModel deleteChatEntities:self.selectedModels completionBlock:^(BOOL isSuccess){
        if (isSuccess) {
            for (ChatDetailEntity* entity in weakself.selectedModels) {
                [weakself.messageModels removeObject:entity];
            }
            weakself.filteredChats = weakself.messageModels;
            [weakself.selectedModels removeAllObjects];
            [weakself.delegate didUpdateData];
        }
    }];
}

- (void)_fakeUpload100Images:(NSData *)data {
    __weak ChatDetailViewModel* weakself = self;
    
    dispatch_async(_backgroundQueue, ^{
        for (int i=0; i<100; i++) {
            [weakself _addImage:data];
        }
    });
    
}

- (void)setCheat:(BOOL)isOn {
    _isCheatOn = isOn;
}

- (void)requestAddImage:(NSData *)data {
    if (self.isCheatOn) {
        [self _fakeUpload100Images:data];
        return;
    } else {
        [self _addImage:data];
    }
}

- (void)_addImage:(NSData*) data {
    __weak ChatDetailViewModel *weakself = self;
    dispatch_async(_backgroundQueue, ^{
        [weakself.chatDetailBusinessModel saveImageWithData:data ofRoomId:weakself.chatRoom.roomId completionBlock:^(ChatDetailEntity* entity){

            [weakself.messageModels insertObject:entity atIndex:0];
            weakself.filteredChats = weakself.messageModels;
            [weakself.delegate didUpdateData];
        } errorBlock:^(NSError* error) {
            
        }];
    });
    
}

- (void) updateRamCache: (UIImage*)image withKey:(NSString*)key {
    for (ChatDetailEntity* entity in _messageModels) {
        if ([entity.file.checksum isEqualToString:key]){
            entity.thumbnail = image;
        }
    }
    [_chatDetailBusinessModel updateRamCache:image withKey:key];
}
@synthesize filteredChats;

@end
