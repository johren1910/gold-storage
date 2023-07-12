//
//  StorageBuilder.m
//  storage2
//
//  Created by LAP14885 on 11/07/2023.
//

#import <Foundation/Foundation.h>
#import "StorageBuilder.h"
#import "AppEnvironment.h"
#import "StorageManager.h"
#import "CacheService.h"
#import "DatabaseService.h"
#import "ZODownloadManagerType.h"
#import "ChatMessageProvider.h"
#import "FileDataProvider.h"
#import "ChatDetailViewController.h"

@interface StorageBuilder ()
@property (nonatomic) AppEnvironment* environment;
@end

@implementation StorageBuilder

-(instancetype) init:(AppEnvironment*)environment {
    if (self == [super init]) {
        self.environment = environment;
    }
    return self;
}

-(id<StorageManagerType>)getStorageManager {
    return _environment.storageManager;
}

-(id<FileDataProviderType>)getFileProvider {
    FileDataProvider* fileDataProvider = [[FileDataProvider alloc] initWithStorageManager:[self getStorageManager]];
    return fileDataProvider;
}

-(id<StorageRepositoryInterface>) getStorageDataRepository {
    StorageDataRepository* dataRepository = [[StorageDataRepository alloc] initWithFileDataProvider:[self getFileProvider] andStorageManager:[self getStorageManager]];
    return dataRepository;
}
-(id<StorageBusinessModelInterface>) getStorageBusinessModel {
    StorageBusinessModel* storageBusinessModel = [[StorageBusinessModel alloc] initWithRepository:[self getStorageDataRepository]];
    return storageBusinessModel;
}
-(id<StorageViewModelType>) getStorageViewModel {
    StorageViewModel* storageViewModel = [[StorageViewModel alloc] initWithBusinessModel:[self getStorageBusinessModel]];
    return storageViewModel;
}
-(id<ViewControllerType>) getStorageViewController {
    StorageViewController* storageViewController = [[StorageViewController alloc] initWithViewModel:[self getStorageViewModel]];
    return storageViewController;
}

@end

