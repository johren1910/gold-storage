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
        [weakself.storageBusinessModel getAppSize:^(long long appSize) {
            weakself.currentStorageEntity.phoneSize = phoneSize;
            weakself.currentStorageEntity.appSize = appSize;
            
            // TEST
            StorageSpaceItem *item1 = [[StorageSpaceItem alloc] init];
            item1.color = UIColor.yellowColor;
            item1.name = @"Misc";
            item1.percent = 0.2;
            item1.space = @"204 MB";
            
            StorageSpaceItem *item2 = [[StorageSpaceItem alloc] init];
            item2.color = UIColor.blueColor;
            item2.name = @"Videos";
            item2.percent = 0.6;
            item2.space = @"600 MB";
            
            StorageSpaceItem *item3 = [[StorageSpaceItem alloc] init];
            item3.color = UIColor.greenColor;
            item3.name = @"Pictures";
            item3.percent = 0.2;
            item3.space = @"204 MB";
            weakself.currentStorageEntity.storageSpaceItems = @[item1, item2, item3];
            // TEST
            
            [weakself.delegate didUpdateData:weakself.currentStorageEntity];
        } errorBlock:nil];
    } errorBlock:nil];
}


@synthesize delegate;
@synthesize currentStorageEntity;

@end
