//
//  ChatMessageModel.h
//  storage2
//
//  Created by LAP14885 on 21/06/2023.
//

#import <Foundation/Foundation.h>

@import IGListDiffKit;
#import "FileType.h"
#import "ChatMessageData.h"
#import <UIKit/UIKit.h>

@interface ChatMessageModel: NSObject <IGListDiffable, NSCopying>

@property (nonatomic,readwrite,copy) ChatMessageData* messageData;
@property (nonatomic,readwrite) UIImage* thumbnail;
@property (nonatomic) BOOL selected;

// TODO: Migrate to messageState
@property (nonatomic) BOOL isError;

- (instancetype)initWithMessageData:(ChatMessageData *)messageData thumbnail:(UIImage *)thumbnail NS_DESIGNATED_INITIALIZER;
@end

