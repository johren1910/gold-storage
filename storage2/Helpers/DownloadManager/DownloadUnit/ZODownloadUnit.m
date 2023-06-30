//
//  ZODownloadUnit.m
//  storage2
//
//  Created by LAP14885 on 25/06/2023.
//

#import "ZODownloadUnit.h"

@implementation ZODownloadUnit

-(instancetype)init {
    if (self == [super init]){
        _downloadId = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (NSComparisonResult)compare:(ZODownloadUnit *)object {
    if (_priority > object.priority) {
        return NSOrderedDescending;
    } else if (_priority < object.priority) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}

- (BOOL)isEqual:(ZODownloadUnit*)object {
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    return (_downloadId == object.downloadId);
}

@end

