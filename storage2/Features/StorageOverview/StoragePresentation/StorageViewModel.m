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
        } errorBlock:nil];
    } errorBlock:nil];
}

-(void)didTouchCell:(NSInteger) row {
    StorageSpaceItem* item = currentStorageEntity.storageSpaceItems[row];
    item.selected = !item.selected;
    [delegate didUpdateData:currentStorageEntity];
}

-(void)didTouchDeleteBtn {
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

@synthesize delegate;
@synthesize currentStorageEntity;

@end
