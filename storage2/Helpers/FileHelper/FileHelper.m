//
//  FileHelper.m
//  storage2
//
//  Created by LAP14885 on 16/06/2023.
//

#import "FileHelper.h"

@implementation FileHelper

+(NSMutableArray *)absoluteDirectories
{
    static NSMutableArray *directories = nil;
    static dispatch_once_t token;

    dispatch_once(&token, ^{

        directories = [NSMutableArray arrayWithObjects:
                                [self pathForApplicationSupportDirectory],
                                [self pathForCachesDirectory],
                                [self pathForDocumentsDirectory],
                                [self pathForLibraryDirectory],
                                [self pathForMainBundleDirectory],
                                [self pathForTemporaryDirectory],
                                nil];

        [directories sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {

            return (((NSString *)obj1).length > ((NSString *)obj2).length) ? 0 : 1;

        }];
    });

    return directories;
}


+(NSString *)absoluteDirectoryForPath:(NSString *)path
{
    [self assertPath:path];

    if([path isEqualToString:@"/"])
    {
        return nil;
    }

    NSMutableArray *directories = [self absoluteDirectories];

    for(NSString *directory in directories)
    {
        NSRange indexOfDirectoryInPath = [path rangeOfString:directory];

        if(indexOfDirectoryInPath.location == 0)
        {
            return directory;
        }
    }

    return nil;
}


+(NSString *)absolutePath:(NSString *)path
{
    [self assertPath:path];

    NSString *defaultDirectory = [self absoluteDirectoryForPath:path];

    if(defaultDirectory != nil)
    {
        return path;
    }
    else {
        return [self pathForDocumentsDirectoryWithPath:path];
    }
}


+(void)assertPath:(NSString *)path
{
    NSAssert(path != nil, @"Invalid path. Path cannot be nil.");
    NSAssert(![path isEqualToString:@""], @"Invalid path. Path cannot be empty string.");
}


+(id)attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key
{
    return [[self attributesOfItemAtPath:path] objectForKey:key];
}


+(id)attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key error:(NSError **)error
{
    return [[self attributesOfItemAtPath:path error:error] objectForKey:key];
}


+(NSDictionary *)attributesOfItemAtPath:(NSString *)path
{
    return [self attributesOfItemAtPath:path error:nil];
}


+(NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error
{
    return [[NSFileManager defaultManager] attributesOfItemAtPath:[self absolutePath:path] error:error];
}

+(BOOL)createDirectoriesForFileAtPath:(NSString *)path
{
    return [self createDirectoriesForFileAtPath:path error:nil];
}


+(BOOL)createDirectoriesForFileAtPath:(NSString *)path error:(NSError **)error
{
    NSString *pathLastChar = [path substringFromIndex:(path.length - 1)];

    if([pathLastChar isEqualToString:@"/"])
    {
        [NSException raise:@"Invalid path" format:@"file path can't have a trailing '/'."];

        return NO;
    }

    return [self createDirectoriesForPath:[[self absolutePath:path] stringByDeletingLastPathComponent] error:error];
}


+(BOOL)createDirectoriesForPath:(NSString *)path
{
    return [self createDirectoriesForPath:path error:nil];
}


+(BOOL)createDirectoriesForPath:(NSString *)path error:(NSError **)error
{
    return [[NSFileManager defaultManager] createDirectoryAtPath:[self absolutePath:path] withIntermediateDirectories:YES attributes:nil error:error];
}


+(BOOL)createFileAtPath:(NSString *)path
{
    return [self createFileAtPath:path withContent:nil overwrite:NO error:nil];
}


+(BOOL)createFileAtPath:(NSString *)path error:(NSError **)error
{
    return [self createFileAtPath:path withContent:nil overwrite:NO error:error];
}


+(BOOL)createFileAtPath:(NSString *)path overwrite:(BOOL)overwrite
{
    return [self createFileAtPath:path withContent:nil overwrite:overwrite error:nil];
}


+(BOOL)createFileAtPath:(NSString *)path overwrite:(BOOL)overwrite error:(NSError **)error
{
    return [self createFileAtPath:path withContent:nil overwrite:overwrite error:error];
}


+(BOOL)createFileAtPath:(NSString *)path withContent:(NSObject *)content
{
    return [self createFileAtPath:path withContent:content overwrite:NO error:nil];
}


+(BOOL)createFileAtPath:(NSString *)path withContent:(NSObject *)content error:(NSError **)error
{
    return [self createFileAtPath:path withContent:content overwrite:NO error:error];
}


+(BOOL)createFileAtPath:(NSString *)path withContent:(NSObject *)content overwrite:(BOOL)overwrite
{
    return [self createFileAtPath:path withContent:content overwrite:overwrite error:nil];
}


+(BOOL)createFileAtPath:(NSString *)path withContent:(NSObject *)content overwrite:(BOOL)overwrite error:(NSError **)error
{
    if(![self existsItemAtPath:path] || (overwrite && [self removeItemAtPath:path error:error] && [self isNotError:error]))
    {
        if([self createDirectoriesForFileAtPath:path error:error])
        {
            BOOL created = [[NSFileManager defaultManager] createFileAtPath:[self absolutePath:path] contents:nil attributes:nil];

            if(content != nil)
            {
                [self writeFileAtPath:path content:content error:error];
            }

            return (created && [self isNotError:error]);
        }
        else {
            return NO;
        }
    }
    else {
        return NO;
    }
}

+(NSArray *)listItemsInDirectoryAtPath:(NSString *)path deep:(BOOL)deep
{
    NSString *absolutePath = [self absolutePath:path];
    NSArray *relativeSubpaths = (deep ? [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:absolutePath error:nil] : [[NSFileManager defaultManager] contentsOfDirectoryAtPath:absolutePath error:nil]);

    NSMutableArray *absoluteSubpaths = [[NSMutableArray alloc] init];

    for(NSString *relativeSubpath in relativeSubpaths)
    {
        NSString *absoluteSubpath = [absolutePath stringByAppendingPathComponent:relativeSubpath];
        [absoluteSubpaths addObject:absoluteSubpath];
    }

    return [NSArray arrayWithArray:absoluteSubpaths];
}

+(NSArray *)listFilesInDirectoryAtPath:(NSString *)path
{
    return [self listFilesInDirectoryAtPath:path deep:NO];
}


+(NSArray *)listFilesInDirectoryAtPath:(NSString *)path deep:(BOOL)deep
{
    NSArray *subpaths = [self listItemsInDirectoryAtPath:path deep:deep];

    return [subpaths filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {

        NSString *subpath = (NSString *)evaluatedObject;

        return [self isFileItemAtPath:subpath];
    }]];
}

+(BOOL)removeFilesInDirectoryAtPath:(NSString *)path
{
    return [self removeItemsAtPaths:[self listFilesInDirectoryAtPath:path] error:nil];
}

+(BOOL)removeItemsAtPaths:(NSArray *)paths
{
    return [self removeItemsAtPaths:paths error:nil];
}


+(BOOL)removeItemsAtPaths:(NSArray *)paths error:(NSError **)error
{
    BOOL success = YES;

    for(NSString *path in paths)
    {
        success &= [self removeItemAtPath:[self absolutePath:path] error:error];
    }

    return success;
}

+(BOOL)clearCachesDirectory
{
    return [self removeFilesInDirectoryAtPath:[self pathForCachesDirectory]];
}


+(BOOL)clearTemporaryDirectory
{
    return [self removeFilesInDirectoryAtPath:[self pathForTemporaryDirectory]];
}


+(BOOL)existsItemAtPath:(NSString *)path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self absolutePath:path]];
}


+(BOOL)isDirectoryItemAtPath:(NSString *)path
{
    return [self isDirectoryItemAtPath:path error:nil];
}


+(BOOL)isDirectoryItemAtPath:(NSString *)path error:(NSError **)error
{
    return ([self attributeOfItemAtPath:path forKey:NSFileType error:error] == NSFileTypeDirectory);
}

+(BOOL)isFileItemAtPath:(NSString *)path
{
    return [self isFileItemAtPath:path error:nil];
}


+(BOOL)isFileItemAtPath:(NSString *)path error:(NSError **)error
{
    return ([self attributeOfItemAtPath:path forKey:NSFileType error:error] == NSFileTypeRegular);
}


+(BOOL)isNotError:(NSError **)error
{
    //the first check prevents EXC_BAD_ACCESS error in case methods are called passing nil to error argument
    //the second check prevents that the methods returns always NO just because the error pointer exists (so the first condition returns YES)
    return ((error == nil) || ((*error) == nil));
}

+(NSString *)pathForApplicationSupportDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;

    dispatch_once(&token, ^{

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);

        path = [paths lastObject];
    });

    return path;
}


+(NSString *)pathForApplicationSupportDirectoryWithPath:(NSString *)path
{
    return [[FileHelper pathForApplicationSupportDirectory] stringByAppendingPathComponent:path];
}


+(NSString *)pathForCachesDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;

    dispatch_once(&token, ^{

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);

        path = [paths lastObject];
    });

    return path;
}


+(NSString *)pathForCachesDirectoryWithPath:(NSString *)path
{
    return [[FileHelper pathForCachesDirectory] stringByAppendingPathComponent:path];
}

+ (NSString *)documentsPathForFileName:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];

    return [documentsPath stringByAppendingPathComponent:name];
}

+(NSString *)pathForDocumentsDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;

    dispatch_once(&token, ^{

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

        path = [paths lastObject];
    });

    return path;
}


+(NSString *)pathForDocumentsDirectoryWithPath:(NSString *)path
{
    return [[FileHelper pathForDocumentsDirectory] stringByAppendingPathComponent:path];
}


+(NSString *)pathForLibraryDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;

    dispatch_once(&token, ^{

        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);

        path = [paths lastObject];
    });

    return path;
}


+(NSString *)pathForLibraryDirectoryWithPath:(NSString *)path
{
    return [[FileHelper pathForLibraryDirectory] stringByAppendingPathComponent:path];
}


+(NSString *)pathForMainBundleDirectory
{
    return [NSBundle mainBundle].resourcePath;
}


+(NSString *)pathForMainBundleDirectoryWithPath:(NSString *)path
{
    return [[FileHelper pathForMainBundleDirectory] stringByAppendingPathComponent:path];
}

+(NSString *)pathForTemporaryDirectory
{
    static NSString *path = nil;
    static dispatch_once_t token;

    dispatch_once(&token, ^{

        path = NSTemporaryDirectory();
    });

    return path;
}


+(NSString *)pathForTemporaryDirectoryWithPath:(NSString *)path
{
    return [[FileHelper pathForTemporaryDirectory] stringByAppendingPathComponent:path];
}

+(NSString *)readFileAtPathAsString:(NSString *)path
{
    return [self readFileAtPath:path error:nil];
}


+(NSString *)readFileAtPathAsString:(NSString *)path error:(NSError **)error
{
    return [NSString stringWithContentsOfFile:[self absolutePath:path] encoding:NSUTF8StringEncoding error:error];
}


+(NSString *)readFileAtPath:(NSString *)path
{
    return [self readFileAtPathAsString:path error:nil];
}


+(NSString *)readFileAtPath:(NSString *)path error:(NSError **)error
{
    return [self readFileAtPathAsString:path error:error];
}


+(NSArray *)readFileAtPathAsArray:(NSString *)path
{
    return [NSArray arrayWithContentsOfFile:[self absolutePath:path]];
}


+(NSData *)readFileAtPathAsData:(NSString *)path
{
    return [self readFileAtPathAsData:path error:nil];
}


+(NSData *)readFileAtPathAsData:(NSString *)path error:(NSError **)error
{
    return [NSData dataWithContentsOfFile:[self absolutePath:path] options:NSDataReadingMapped error:error];
}



+(UIImage *)readFileAtPathAsImage:(NSString *)path
{
    return [self readFileAtPathAsImage:path error:nil];
}


+(UIImage *)readFileAtPathAsImage:(NSString *)path error:(NSError **)error
{
    NSData *data = [self readFileAtPathAsData:path error:error];

    if([self isNotError:error])
    {
        return [UIImage imageWithData:data];
    }

    return nil;
}

+(BOOL)removeItemAtPath:(NSString *)path
{
    return [self removeItemAtPath:path error:nil];
}


+(BOOL)removeItemAtPath:(NSString *)path error:(NSError **)error
{
    return [[NSFileManager defaultManager] removeItemAtPath:[self absolutePath:path] error:error];
}

+(NSString *)sizeFormatted:(NSNumber *)size
{

    double convertedValue = [size doubleValue];
    int multiplyFactor = 0;

    NSArray *tokens = @[@"bytes", @"KB", @"MB", @"GB", @"TB"];

    while(convertedValue > 1024){
        convertedValue /= 1024;

        multiplyFactor++;
    }

    NSString *sizeFormat = ((multiplyFactor > 1) ? @"%4.2f %@" : @"%4.0f %@");

    return [NSString stringWithFormat:sizeFormat, convertedValue, tokens[multiplyFactor]];
}


+(NSString *)sizeFormattedOfFileAtPath:(NSString *)path
{
    return [self sizeFormattedOfFileAtPath:path error:nil];
}


+(NSString *)sizeFormattedOfFileAtPath:(NSString *)path error:(NSError **)error
{
    NSNumber *size = [self sizeOfFileAtPath:path error:error];

    if(size != nil && [self isNotError:error])
    {
        return [self sizeFormatted:size];
    }

    return nil;
}


+(NSString *)sizeFormattedOfItemAtPath:(NSString *)path
{
    return [self sizeFormattedOfItemAtPath:path error:nil];
}


+(NSString *)sizeFormattedOfItemAtPath:(NSString *)path error:(NSError **)error
{
    NSNumber *size = [self sizeOfItemAtPath:path error:error];

    if(size != nil && [self isNotError:error])
    {
        return [self sizeFormatted:size];
    }

    return nil;
}



+(NSNumber *)sizeOfFileAtPath:(NSString *)path
{
    return [self sizeOfFileAtPath:path error:nil];
}

+(NSNumber *)sizeOfItemAtPath:(NSString *)path
{
    return [self sizeOfItemAtPath:path error:nil];
}


+(NSNumber *)sizeOfItemAtPath:(NSString *)path error:(NSError **)error
{
    return (NSNumber *)[self attributeOfItemAtPath:path forKey:NSFileSize error:error];
}


+(NSNumber *)sizeOfFileAtPath:(NSString *)path error:(NSError **)error
{
    if([self isFileItemAtPath:path error:error])
    {
        if([self isNotError:error])
        {
            return [self sizeOfItemAtPath:path error:error];
        }
    }

    return nil;
}

+(NSURL *)urlForItemAtPath:(NSString *)path
{
    return [NSURL fileURLWithPath:[self absolutePath:path]];
}


+(BOOL)writeFileAtPath:(NSString *)path content:(NSObject *)content
{
    return [self writeFileAtPath:path content:content error:nil];
}


+(BOOL)writeFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError **)error
{
    if(content == nil)
    {
        [NSException raise:@"Invalid content" format:@"content can't be nil."];
    }

    [self createFileAtPath:path withContent:nil overwrite:YES error:error];

    NSString *absolutePath = [self absolutePath:path];

    if([content isKindOfClass:[NSMutableArray class]])
    {
        [((NSMutableArray *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSArray class]])
    {
        [((NSArray *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSMutableData class]])
    {
        [((NSMutableData *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSData class]])
    {
        [((NSData *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSMutableDictionary class]])
    {
        [((NSMutableDictionary *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSDictionary class]])
    {
        [((NSDictionary *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSJSONSerialization class]])
    {
        [((NSDictionary *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSMutableString class]])
    {
        [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[NSString class]])
    {
        [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[UIImage class]])
    {
        [UIImagePNGRepresentation((UIImage *)content) writeToFile:absolutePath atomically:YES];
    }
    else if([content isKindOfClass:[UIImageView class]])
    {
        return [self writeFileAtPath:absolutePath content:((UIImageView *)content).image error:error];
    }
    else if([content conformsToProtocol:@protocol(NSCoding)])
    {
        [NSKeyedArchiver archiveRootObject:content toFile:absolutePath];
    }
    else {
        [NSException raise:@"Invalid content type" format:@"content of type %@ is not handled.", NSStringFromClass([content class])];

        return NO;
    }

    return YES;
}


+(NSDictionary *)metadataOfImageAtPath:(NSString *)path
{
    if([self isFileItemAtPath:path])
    {
        //http://blog.depicus.com/getting-exif-data-from-images-on-ios/

        NSURL *url = [self urlForItemAtPath:path];
        CGImageSourceRef sourceRef = CGImageSourceCreateWithURL((CFURLRef)url, NULL);
        NSDictionary *metadata = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, NULL));

        return metadata;
    }

    return nil;
}

@end
