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
- (void) reloadTable;
- (void) didFinishUpdate;
- (void) needUpdateHeavyCollection;
- (void) didUpdateObject:(ChatDetailEntity* )model;

@end

@protocol StorageViewModelType <ViewModelType>
- (void) onViewDidLoad;
@property (nonatomic, weak) id <StorageViewModelDelegate> delegate;
-(instancetype)initWithBusinessModel:(id<StorageBusinessModelInterface>)storageBusinessModel;
@property (nonatomic) StorageEntity* currentStorageEntity;
-(void)didTouchTypeCell:(NSInteger)row;
-(void)didTouchDeleteTypeBtn;

-(void)didTouchHeavyCell:(ChatDetailEntity*)file;
-(void)didTouchDeleteHeavyBtn;

@property (retain,nonatomic) NSMutableArray<ChatDetailEntity *> *messageModels;
@property (retain,nonatomic) NSMutableArray<ChatDetailEntity *> *selectedModels;
@end

@interface StorageViewModel : NSObject <StorageViewModelType>
@property (nonatomic) id<StorageBusinessModelInterface> storageBusinessModel;
@end

