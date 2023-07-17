//
//  ZODownloadUnit.m
//  storage2
//
//  Created by LAP14885 on 25/06/2023.
//

#import "ZODownloadItem.h"

@implementation ZODownloadItem

-(instancetype)init {
    if (self == [super init]){
        downloadId = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (NSComparisonResult)compare:(id<ZODownloadItemType>)object {
    if (priority > object.priority) {
        return NSOrderedDescending;
    } else if (priority < object.priority) {
        return NSOrderedAscending;
    } else {
        return NSOrderedSame;
    }
}

- (BOOL)isEqual:(ZODownloadItem*)object {
    if (object == self)
        return YES;
    if (!object || ![object isKindOfClass:[self class]])
        return NO;
    return (downloadId == object.downloadId);
}

-(id)copyWithZone:(NSZone *)zone
{
    ZODownloadItem *clone = [[[self class] allocWithZone:zone] init];
    // other statements
    return clone;
}

@synthesize completionBlock;
@synthesize currentRetryAttempt;
@synthesize destinationDirectoryPath;
@synthesize downloadError;
@synthesize downloadId;
@synthesize downloadState;
@synthesize errorBlock;
@synthesize isBackgroundSession;
@synthesize maxRetryCount;
@synthesize otherCompletionBlocks;
@synthesize otherErrorBlocks;
@synthesize priority;
@synthesize progressBlock;
@synthesize requestUrl;
@synthesize resumeData;
@synthesize startDate;
@synthesize tempFilePath;

@end

