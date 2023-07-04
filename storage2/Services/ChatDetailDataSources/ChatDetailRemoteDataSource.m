//
//  ChatDetailRemoteDataSource.m
//  storage2
//
//  Created by LAP14885 on 02/07/2023.
//
#import "ChatDetailRemoteDataSource.h"

@implementation ChatDetailRemoteDataSource
- (void)startDownloadWithUnit:(ZODownloadUnit*)unit{
    [_downloadManager startDownloadWithUnit:unit];
}

-(void)cancelDownloadOfUrl:(NSString*)downloadUrl {
    [_downloadManager cancelDownloadOfUrl:downloadUrl];
}

-(instancetype)init:(NSString*) baseUrl {
    if (self == [super init]) {
        
    }
    
    return self;
}

@end
