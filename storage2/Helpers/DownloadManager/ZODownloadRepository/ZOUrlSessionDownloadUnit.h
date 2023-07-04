//
//  ZOUrlSessionDownloadUnit.h
//  storage2
//
//  Created by LAP14885 on 04/07/2023.
//

#import "ZODownloadUnit.h"

@interface ZOUrlSessionDownloadUnit : ZODownloadUnit <NSCopying>
/// [This property is] hold the task of the according requestUrl
@property (nonatomic, strong) NSURLSessionDownloadTask *task;
-(instancetype)initWithUnit:(ZODownloadUnit*)unit;
@end
