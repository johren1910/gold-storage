//
//  ZODownloadUnit.h
//  storage2
//
//  Created by LAP14885 on 17/07/2023.
//

#import "ZODownloadItem.h"
#import "ZODownloadRepositoryInterface.h"

@protocol ZODownloadUnitType
@property (nonatomic) id<ZODownloadItemType> downloadItem;
@property (nonatomic) id<ZODownloadRepositoryInterface> downloadRepository;
-(instancetype)initWithItem:(id<ZODownloadItemType>)item andRepository:(id<ZODownloadRepositoryInterface>)downloadRepository;
-(void)setRepository:(id<ZODownloadRepositoryInterface>)downloadRepository;
    
-(void)start:(void(^)(NSString* filePath))completionBlock errorBlock:(void(^)(NSError* error))errorBlock progressBlock:(void(^)(CGFloat progress, NSUInteger speed, NSUInteger remainingSeconds))progressBlock;
-(void)pause;
-(void)cancle;
-(void)resume;
/// [This function  is] compare priority of the unit to
- (NSComparisonResult)compare:(id<ZODownloadItemType>)object;
@end

@interface ZODOwnloadUnit : NSObject <ZODownloadUnitType>

@end
