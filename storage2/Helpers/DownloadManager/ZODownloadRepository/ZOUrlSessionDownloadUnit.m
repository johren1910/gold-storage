//
//  ZOUrlSessionDownloadUnit.m
//  storage2
//
//  Created by LAP14885 on 04/07/2023.
//

#import <Foundation/Foundation.h>
#import "ZOUrlSessionDownloadUnit.h"

@implementation ZOUrlSessionDownloadUnit

-(id)copyWithZone:(NSZone *)zone
{
    ZOUrlSessionDownloadUnit *clone = [super copyWithZone:zone];
    clone.task = nil;
    return clone;
}

-(instancetype)initWithUnit:(ZODownloadUnit*)unit {
    if (self == [super init]) {
        self.startDate = unit.startDate;
        self.completionBlock = unit.completionBlock;
        self.errorBlock = unit.errorBlock;
        self.priority = unit.priority;
        self.requestUrl = unit.requestUrl;
        self.destinationDirectoryPath = unit.destinationDirectoryPath;
        self.otherCompletionBlocks = unit.otherCompletionBlocks;
        self.otherErrorBlocks = unit.otherErrorBlocks;
        self.isBackgroundSession = unit.isBackgroundSession;
        self.downloadError = unit.downloadError;
        self.resumeData = unit.resumeData;
        self.downloadState = unit.downloadState;
        self.maxRetryCount = unit.maxRetryCount;
        self.currentRetryAttempt = unit.currentRetryAttempt;
        self.downloadId = unit.downloadId;
    }
    return self;
}

@end
