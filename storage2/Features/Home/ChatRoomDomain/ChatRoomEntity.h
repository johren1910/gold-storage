//
//  ChatRoomEntity.h
//  storage2
//
//  Created by LAP14885 on 07/07/2023.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@import IGListDiffKit;

@interface ChatRoomEntity : NSObject <IGListDiffable, NSCopying>
@property (nonatomic) NSString* roomId;
@property (nonatomic) NSString* name;
@property (nonatomic) BOOL selected;
@property (nonatomic) double createdAt;
@end

