//
//  ChatDetailModel.h
//  storage2
//
//  Created by LAP14885 on 15/06/2023.
//

#import <Foundation/Foundation.h>

@import IGListDiffKit;
#import "MediaType.h"

@interface ChatDetailModel: NSObject <IGListDiffable, NSCopying>

@property (nonatomic,readwrite,copy) NSString* name;
@property (nonatomic,readonly,copy) NSString* chatId;
@property (nonatomic,readwrite, copy) NSString* extenion;
@property (nonatomic,readwrite, copy) NSDate* timeCreated;
@property (nonatomic,readwrite) float size;
@property (nonatomic,readwrite) MediaType type;
@property (nonatomic,readwrite) NSUInteger* duration;
@property (nonatomic,readwrite) NSData* data;
@property (nonatomic,readwrite) UIImage* image;


+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithName:(NSString *)name chatId:(NSString *)chatId type:(MediaType)type NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithName:(NSString *)name chatId:(NSString *)chatId NS_DESIGNATED_INITIALIZER;

@end


