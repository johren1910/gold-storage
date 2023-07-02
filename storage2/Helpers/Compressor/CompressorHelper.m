//
//  CompressorHelper.m
//  storage2
//
//  Created by LAP14885 on 21/06/2023.
//

#import "CompressorHelper.h"
static  dispatch_queue_t compressQueue;
@interface CompressorHelper ()
@end

@implementation CompressorHelper

+(void)prepareCompressor {
    compressQueue = dispatch_queue_create("com.compressor.queue", DISPATCH_QUEUE_SERIAL);
}

+(void)compressImage:(UIImage *)image quality:(CompressQuality)quality completionBlock: (void (^)(UIImage* compressedImage))completionBlock {
   
    dispatch_async(compressQueue, ^{

        NSData *imgData = UIImageJPEGRepresentation(image, 1);
        NSLog(@"Size of Image(bytes):%ld",(unsigned long)[imgData length]);

        float actualHeight = image.size.height;
        float actualWidth = image.size.width;
        float maxHeight = 600.0;
        float maxWidth = 800.0;
        float imgRatio = actualWidth/actualHeight;
        float maxRatio = maxWidth/maxHeight;
        float compressionQuality = 1;
        switch (quality) {
            case Thumbnail:
                maxHeight = 600.0;
                maxWidth = 800.0;
                compressionQuality = 0.2;
                break;
            case Usable:
                maxHeight = 900;
                maxWidth = 1200.0;
                compressionQuality = 0.4;
                break;

            default:
                break;
        }

        if (actualHeight > maxHeight || actualWidth > maxWidth){
            if(imgRatio < maxRatio){
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio){
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else{
                actualHeight = maxHeight;
                actualWidth = maxWidth;
            }
        }

        CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        [image drawInRect:rect];
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        NSData *imageData = UIImageJPEGRepresentation(img, compressionQuality);
        UIGraphicsEndImageContext();

        NSLog(@"Size of Image(bytes):%ld",(unsigned long)[imageData length]);

        completionBlock([UIImage imageWithData:imageData]);
    });
}
@end

