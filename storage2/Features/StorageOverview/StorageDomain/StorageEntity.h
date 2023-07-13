//
//  StorageEntity.h
//  storage2
//
//  Created by LAP14885 on 11/07/2023.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FileType.h"

@interface StorageSpaceItem : NSObject
@property (nonatomic) UIColor* color;
@property (nonatomic) FileType fileType;
@property (nonatomic) float percent;
@property (nonatomic) long long size;
@property (nonatomic) BOOL selected;
@end

@interface StorageEntity : NSObject <NSCopying>
@property (nonatomic) long long phoneSize;
@property (nonatomic) long long appSize;
@property (nonatomic) NSArray<StorageSpaceItem*>* storageSpaceItems;
@end

