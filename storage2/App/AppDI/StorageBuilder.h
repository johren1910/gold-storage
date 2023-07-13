//
//  StorageBuilder.h
//  storage2
//
//  Created by LAP14885 on 11/07/2023.
//

#import "AppEnvironment.h"
#import "StorageViewModel.h"
#import "StorageDataRepository.h"
#import "StorageRepositoryInterface.h"
#import "StorageBusinessModel.h"
#import "StorageViewModel.h"
#import "StorageViewController.h"

@protocol StorageBuilderType
-(id<StorageManagerType>) getStorageManager;
-(id<FileDataProviderType>)getFileProvider;
-(id<StorageRepositoryInterface>) getStorageDataRepository;
-(id<StorageBusinessModelInterface>) getStorageBusinessModel;
-(id<StorageViewModelType>) getStorageViewModel;
-(id<ViewControllerType>) getStorageViewController;
@end

@interface StorageBuilder : NSObject <StorageBuilderType>
-(instancetype) init:(id<AppEnvironmentType>)environment;
@end
