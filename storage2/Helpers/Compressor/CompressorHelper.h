//
//  CompressorHelper.h
//  storage2
//
//  Created by LAP14885 on 21/06/2023.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CompressQuality) {
    Thumbnail = 1,
    Usable
};


@interface CompressorHelper: NSObject
-(void)compressImage:(UIImage *)image quality:(CompressQuality)quality completionBlock: (void (^)(UIImage* compressedImage))block;
@end
