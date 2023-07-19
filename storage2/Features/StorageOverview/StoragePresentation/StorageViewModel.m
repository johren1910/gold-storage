//
//  StorageViewModel.m
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

#import "StorageViewModel.h"
#import "StorageEntity.h"

@interface StorageViewModel ()

@property (nonatomic) dispatch_queue_t backgroundQueue;
@end

@implementation StorageViewModel

-(instancetype)initWithBusinessModel:(id<StorageBusinessModelInterface>)storageBusinessModel {
    self = [super init];
    if (self) {
        self.currentStorageEntity = [[StorageEntity alloc] init];
        self.messageModels = [[NSMutableArray alloc] init];
        self.selectedModels = [[NSMutableArray alloc] init];
        self.backgroundQueue = dispatch_queue_create("com.storage.viewmodel.backgroundqueue", DISPATCH_QUEUE_SERIAL);
        self.storageBusinessModel = storageBusinessModel;
    }
    
    return self;
}

-(void)onViewDidLoad {
    [self _loadData];
}

-(void)_loadData {
    __weak StorageViewModel* weakself = self;
    [weakself.storageBusinessModel getPhoneSize:^(long long phoneSize) {
        
        weakself.currentStorageEntity.phoneSize = phoneSize;
        [weakself.delegate didUpdateData:weakself.currentStorageEntity];
        [weakself.delegate reloadTable];
    } errorBlock:nil];
    
    [weakself.storageBusinessModel getAppSize:^(long long appSize) {
        weakself.currentStorageEntity.appSize = appSize;
        
        [weakself.storageBusinessModel getAllMediaSize:^(NSArray* items){
            for (StorageSpaceItem* item in items) {
                item.percent = (float)item.size/(float)appSize;
                item.selected = TRUE;
            }
            
            weakself.currentStorageEntity.storageSpaceItems = items;
            
            [weakself.delegate didUpdateData:weakself.currentStorageEntity];
            [weakself.delegate reloadTable];
            [weakself.delegate didFinishUpdate];
        } errorBlock:nil];
    } errorBlock:nil];
    
    [weakself.storageBusinessModel getHeavyFiles:^(NSArray* items){
        weakself.messageModels = [items mutableCopy];
        [weakself.delegate needUpdateHeavyCollection];
    } errorBlock:nil];
}

-(void)didTouchTypeCell:(NSInteger) row {
    StorageSpaceItem* item = currentStorageEntity.storageSpaceItems[row];
    item.selected = !item.selected;
    [delegate didUpdateData:currentStorageEntity];
}

-(void)didTouchDeleteTypeBtn {
    NSMutableArray<StorageSpaceItem*>* items = [[NSMutableArray alloc] init];
    for (StorageSpaceItem* item in currentStorageEntity.storageSpaceItems) {
        if (item.selected) {
            [items addObject:item];
        }
    }
    
    __weak StorageViewModel* weakself = self;
    [_storageBusinessModel deleteAllMediaTypes:items completionBlock:^(BOOL isFinish) {
        [weakself _loadData];
    } errorBlock:nil];
}

-(void)didTouchHeavyCell:(ChatDetailEntity*)file {
    BOOL selected = true;
    if(![self.selectedModels containsObject:file]) {
        selected = true;
        [self.selectedModels addObject:file];
    } else {
        selected = false;
        [self.selectedModels removeObject:file];
    }
    
    for (ChatDetailEntity *model in messageModels) {
        if (file.messageId == model.messageId) {
            
            model.selected = selected;
            break;
        }
    }
    [self.delegate didUpdateObject:file];
}
-(void)didTouchDeleteHeavyBtn {
    
    __weak StorageViewModel* weakself = self;
    NSMutableArray<FileData*>* files = [[NSMutableArray alloc] init];
    for (ChatDetailEntity* entity in self.selectedModels) {
        [files addObject:entity.file];
    }
    
    [_storageBusinessModel deleteFiles:files completionBlock:^(BOOL isFinish) {
        [weakself.messageModels removeObjectsInArray:self.selectedModels];
        [weakself.selectedModels removeAllObjects];
        [weakself _loadData];
    } errorBlock:nil];
}

@synthesize delegate;
@synthesize currentStorageEntity;
@synthesize messageModels;
@synthesize selectedModels;

@end
