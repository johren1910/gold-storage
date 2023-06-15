//
//  ChatDetailModel.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

@import IGListDiffKit;

@interface ChatDetailModel: NSObject <IGListDiffable, NSCopying>

@property (nonatomic,readonly,copy) NSString* name;
@property (nonatomic,readonly,copy) NSString* chatId;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithName:(NSString *)name chatId:(NSString *)chatId NS_DESIGNATED_INITIALIZER;

@end


