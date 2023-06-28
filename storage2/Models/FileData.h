//
//  FileData.h
//  storage2
//
//  Created by LAP14885 on 27/06/2023.
//

#import <Foundation/Foundation.h>

#import "FileType.h"

@interface FileData: NSObject <NSCopying>

@property (nonatomic,readwrite,copy) NSString* fileId;
@property (nonatomic,readwrite,copy) NSString* messageId;
@property (nonatomic,readwrite,copy) NSString* fileName;
@property (nonatomic,readwrite,copy) NSString* filePath;
@property (nonatomic,readwrite,copy) NSString* checksum;
@property (nonatomic,readwrite) double createdAt;
@property (nonatomic,readwrite) double size;
@property (nonatomic,readwrite) double duration;
@property (nonatomic,readwrite) double lastModified;
@property (nonatomic,readwrite) double lastAccessed;
@property (nonatomic,readwrite) FileType type;

@property (nonatomic,readwrite) NSData* tempData;
@end
