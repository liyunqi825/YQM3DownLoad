//
//  BNFileManager.m
//  M3U8DownLoadTest
//
//  Created by zengbailiang on 10/5/17.
//  Copyright © 2017 controling. All rights reserved.
//

#import "BNFileManager.h"

@interface BNFileManager()
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) dispatch_queue_t ioQueue;
@end

NSString * const BNFileManagerWriteErrorDomain = @"error.m3u8.fileManager.write";

@implementation BNFileManager

+ (instancetype)shareInstance
{
    static BNFileManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        sharedInstance.ioQueue = dispatch_queue_create("m3u8.write.serial.queue", DISPATCH_QUEUE_SERIAL);
        dispatch_async(sharedInstance.ioQueue, ^{
            sharedInstance.fileManager = [NSFileManager new];
        });
    });
    return sharedInstance;
}

- (instancetype)initWithIoQueue:(dispatch_queue_t)ioQueue
{
    self = [super init];
    if (self) {
        _ioQueue = ioQueue != nil ? ioQueue : dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(_ioQueue, ^{
            self.fileManager = [NSFileManager new];
        });
    }
    return self;
}

#pragma mark - check exit
+ (BOOL)exitItemWithPath:(NSString*)path
{
    return  [[NSFileManager defaultManager] fileExistsAtPath:path];
}

#pragma mark save/create
+ (BOOL)tryGreateDir:(NSString *)dir
{
    if([[NSFileManager defaultManager] fileExistsAtPath:dir])
    {
        return YES;
    }
    else
    {
        return [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)saveDate:(NSData*) aData pathUrl:(NSURL*)pathUrl completaionHandler:(BNFileManagerCompletaionHandler)completaionHandler
{
    dispatch_async(_ioQueue, ^{
        if ([aData writeToURL:pathUrl atomically:YES]) {
            if (completaionHandler) {
                completaionHandler(nil);
            }
        }
        else
        {
            if (completaionHandler) {
                completaionHandler([[NSError alloc]initWithDomain:BNFileManagerWriteErrorDomain code:NSURLErrorCannotCreateFile userInfo:nil]);
            }
        }
    });
}
- (void)saveDate:(NSData*) aData ToFile:(NSString *)file completaionHandler:(BNFileManagerCompletaionHandler)completaionHandler
{
    dispatch_async(_ioQueue, ^{
        if ([aData writeToFile:file atomically:YES]) {
            if (completaionHandler) {
                completaionHandler(nil);
            }
        }
        else
        {
            if (completaionHandler) {
                 completaionHandler([[NSError alloc]initWithDomain:BNFileManagerWriteErrorDomain code:NSURLErrorCannotCreateFile userInfo:nil]);
            }
        }
    });
}

- (void)moveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL completaionHandler:(BNFileManagerCompletaionHandler)completaionHandler
{
    dispatch_async(_ioQueue, ^{
        NSError *error = nil;
        [self.fileManager moveItemAtURL:srcURL toURL:dstURL error:&error];
        if (completaionHandler) {
            completaionHandler(error);
        }
    });
}

- (void)removeFileWithPath:(NSString *)path
{
    dispatch_async(_ioQueue, ^{
        [self.fileManager removeItemAtPath:path error:nil];
    });
}

- (void)tryCreateDictionaryWithPath:(NSString*)path completaionHandler:(BNFileManagerCompletaionHandler)completaionHandler
{
    if ([_fileManager fileExistsAtPath:path]) completaionHandler(nil);
    
    NSError *error = nil;
    [_fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    if (completaionHandler) {
        completaionHandler(error);
    }
}

-(NSNumber *)sizeOfItemAtPath:(NSString *)path
{
    return [self sizeOfItemAtPath:path error:nil];
}
-(NSNumber *)sizeOfItemAtPath:(NSString *)path error:(NSError **)error
{
    return (NSNumber *)[self attributeOfItemAtPath:path forKey:NSFileSize error:error];
}
-(id)attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key error:(NSError **)error
{
    return [[self attributesOfItemAtPath:path error:error] objectForKey:key];
}

-(NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError **)error
{
    return [[NSFileManager defaultManager] attributesOfItemAtPath:path error:error];
}

//遍历文件夹获得文件夹大小，返回多少M

- (float ) folderSizeAtPath:(NSString*) folderPath{
    if (![_fileManager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[_fileManager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self sizeOfItemAtPath:fileAbsolutePath].longValue;
    }
    return folderSize/(1024.0*1024.0);
}
-(float)getFreeDiskSize{

    float freeSize;

    NSError * error;

    NSDictionary * infoDic = [[NSFileManager defaultManager] attributesOfFileSystemForPath: NSHomeDirectory() error: &error];

    if (infoDic) {

        NSNumber * fileSystemFreeSize = [infoDic objectForKey: NSFileSystemFreeSize];

        freeSize = [fileSystemFreeSize floatValue]/1024.0f/1024.0f/1024.0f;

        return freeSize;

    } else {

        return 0;

    }
}
-(float)getTotalDiskSize{

    float totalSize;
    NSError * error;
    NSDictionary * infoDic = [[NSFileManager defaultManager] attributesOfFileSystemForPath: NSHomeDirectory() error: &error];
    if (infoDic) {
        NSNumber * fileSystemSizeInBytes = [infoDic objectForKey: NSFileSystemSize];
        totalSize = [fileSystemSizeInBytes floatValue]/1024.0f/1024.0f/1024.0f;
        return totalSize;
    } else {
        //NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
        return 0;
    }
}


@end
