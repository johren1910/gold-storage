//
//  ChatDetailEntity.h
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//

#import <Foundation/Foundation.h>
#import "FileData.h"
#import <UIKit/UIKit.h>
@import IGListDiffKit;

@interface ChatDetailEntity : NSObject <IGListDiffable, NSCopying>
@property (nonatomic) NSString* messageId;
@property (nonatomic) FileData* file;
@property (nonatomic) UIImage* thumbnail;
@property (nonatomic) BOOL selected;
@property (nonatomic) BOOL isError;
@end
