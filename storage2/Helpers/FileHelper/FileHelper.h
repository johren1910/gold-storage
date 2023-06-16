//
//  FileHelper.h
//  storage2
//
//  Created by LAP14885 on 16/06/2023.
//

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>

@interface FileHelper : NSObject

+(id)attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key;
+(NSDictionary *)attributesOfItemAtPath:(NSString *)path;

+(BOOL)createDirectoriesForFileAtPath:(NSString *)path;

+(BOOL)createFileAtPath:(NSString *)path;

+(BOOL)createFileAtPath:(NSString *)path withContent:(NSObject *)content;


+(BOOL)clearCachesDirectory;
+(BOOL)clearTemporaryDirectory;

+(NSString *)pathForApplicationSupportDirectory;

+(NSString *)pathForCachesDirectory;

+(NSString *)pathForDocumentsDirectory;

+(NSString *)pathForTemporaryDirectory;

+(NSData *)readFileAtPathAsData:(NSString *)path;

+(UIImage *)readFileAtPathAsImage:(NSString *)path;

+(NSMutableArray *)readFileAtPathAsMutableArray:(NSString *)path;

+(BOOL)removeItemAtPath:(NSString *)path;

+(NSString *)sizeFormattedOfFileAtPath:(NSString *)path;

+(NSNumber *)sizeOfFileAtPath:(NSString *)path;

+(NSURL *)urlForItemAtPath:(NSString *)path;

+(NSDictionary *)metadataOfImageAtPath:(NSString *)path;
@end

