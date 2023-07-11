//
//  FileData.m
//  storage2
//
//  Created by LAP14885 on 27/06/2023.
//

#import "FileData.h"
#import "FileHelper.h"
@implementation FileData

-(NSString*)getAbsoluteFilePath {
    return [FileHelper absolutePath:self.filePath];
}

- (id)copyWithZone:(nullable NSZone *)zone
{
  return self;
}

@end


@implementation FileDataWrapper

@end
