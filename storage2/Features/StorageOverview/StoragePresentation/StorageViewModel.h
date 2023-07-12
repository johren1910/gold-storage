//
//  StorageViewModel.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//
#import <Foundation/Foundation.h>
#import "DIInterface.h"
#import "StorageBusinessModel.h"
#import "StorageEntity.h"

@protocol StorageViewModelDelegate <NSObject>

- (void) didUpdateData:(StorageEntity*)entity;

@end

@protocol StorageViewModelType <ViewModelType>
- (void) onViewDidLoad;
@property (nonatomic, weak) id <StorageViewModelDelegate> delegate;
-(instancetype)initWithBusinessModel:(id<StorageBusinessModelInterface>)storageBusinessModel;
@property (nonatomic) StorageEntity* currentStorageEntity;
@end

@interface StorageViewModel : NSObject <StorageViewModelType>
@property (nonatomic) id<StorageBusinessModelInterface> storageBusinessModel;
@end

