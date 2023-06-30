//
//  FileHelper.h
//  storage2
//
//  Created by LAP14885 on 16/06/2023.
//

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>

@interface ZOMediaInfo : NSObject
@property (nonatomic) UIImage* thumbnail;
@property (nonatomic) int duration;

@end

@interface FileHelper : NSObject

+(NSString *)documentsPathForFileName:(NSString *)name;

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

+(BOOL)removeItemAtPath:(NSString *)path;

+(ZOMediaInfo *)getMediaInfoOfFilePath:(NSString *)filePath;

+(NSString *)sizeFormattedOfFileAtPath:(NSString *)path;

+(NSNumber *)sizeOfFileAtPath:(NSString *)path;

+(NSURL *)urlForItemAtPath:(NSString *)path;

+(NSDictionary *)metadataOfImageAtPath:(NSString *)path;

+(BOOL *)copyItemAtPath:(NSURL *)path toPath:(NSURL*)dstPath error:(NSError **)error;

+(NSString *)pathForTemporaryDirectoryWithPath:(NSString *)path;

+(BOOL)existsItemAtPath:(NSString *)path;

+(NSString *)pathForCachesDirectoryWithPath:(NSString *)path;

+(BOOL)createDirectoriesForPath:(NSString *)path;

+(NSString *)pathForDocumentsDirectoryWithPath:(NSString *)path;

+(BOOL *)moveItemAtPath:(NSString *)path toPath:(NSString*)dstPath error:(NSError **)error;

+(NSString *)pathForApplicationSupportDirectoryWithPath:(NSString *)path;
@end

