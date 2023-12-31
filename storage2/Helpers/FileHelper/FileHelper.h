//
//  FileHelper.h
//  storage2
//
//  Created by LAP14885 on 16/06/2023.
//

#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>
#import <UIKit/UIKit.h>
#import "FileType.h"

@interface ZOMediaInfo : NSObject
@property (nonatomic) UIImage* thumbnail;
@property (nonatomic) int duration;

@end

@interface FileHelper : NSObject

+(NSString*) getDefaultDirectoryByFileType:(FileType)fileType;

+(NSString *)documentsPathForFileName:(NSString *)name;

+(id)attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key;

+(NSDictionary *)attributesOfItemAtPath:(NSString *)path;

+(BOOL)createDirectoriesForFileAtPath:(NSString *)path;

+(BOOL)createFileAtPath:(NSString *)path;

+(BOOL)createFileAtPath:(NSString *)path withContent:(NSObject *)content;

+(FileType)getFileExtension:(NSString *)path;

+(NSString *)absolutePath:(NSString *)path;

+(BOOL)clearCachesDirectory;
+(BOOL)clearTemporaryDirectory;

+(NSString *)pathForApplicationSupportDirectory;

+(NSString *)pathForCachesDirectory;

+(NSString *)pathForDocumentsDirectory;

+(NSString *)pathForTemporaryDirectory;

+(NSData *)readFileAtPathAsData:(NSString *)path;

+(UIImage *)readFileAtPathAsImage:(NSString *)path;

+(BOOL)removeItemAtPath:(NSString *)path;
+(BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error;

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

#pragma mark - Storage Space

+(unsigned long long)getApplicationSize;

+(unsigned long long)getPictureFolderSize;

+(unsigned long long)getVideoFolderSize;

+(unsigned long long)getDatabaseSize;

+(unsigned long long)getOtherExceptSupportSize;

+(UInt64)usedDiskSpaceInBytes;

+(UInt64)freeDiskSpaceInBytes;

+(UInt64)totalDiskSpaceInBytes;

+(NSString*)sizeStringFormatterFromBytes:(UInt64)bytes;

@end

