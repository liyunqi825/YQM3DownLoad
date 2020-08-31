//
//  BNM3U8Manager.h
//  m3u8Demo
//
//  Created by Bennie on 6/14/19.
//  Copyright © 2019 Bennie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BNM3U8DownloadOperation.h"

NS_ASSUME_NONNULL_BEGIN

//typedef NS_OPTIONS(NSUInteger, BNM3U8DownloadSupportNetOption) {
//    BNM3U8DownloadSupportNetOptionNone = 0,
//    BNM3U8DownloadSupportNetOptionWifi = 1 <<0,
//    BNM3U8DownloadSupportNetOptionMobile = 1 << 1,
//    BNM3U8DownloadSupportNetOptionAll = BNM3U8DownloadSupportNetOptionWifi | BNM3U8DownloadSupportNetOptionMobile,
//};

///rootPath 对应的是local http service 的 root path
typedef void(^BNM3U8DownloadResultBlock)(NSError * _Nullable error, NSString * _Nullable localPlayUrl,NSString *url);
typedef void(^BNM3U8DownloadProgressBlock)(CGFloat progress,NSString *url);

@interface BNM3U8ManagerConfig : NSObject
@property (nonatomic, copy) NSString *downloadDstRootPath;
@property (nonatomic, assign) NSInteger videoMaxConcurrenceCount;
/*允许下载的网络类型支持（移动网络，wifi）*/
//@property (nonatomic, assign) BNM3U8DownloadSupportNetOption netOption;
@end

@interface BNM3U8Manager : NSObject

+ (instancetype)shareInstance;

///设置配置，不可以重新赋值
- (void)fillConfig:(BNM3U8ManagerConfig*)config;

-(NSString *)getRootPath;

/*下载队列中添加
 创建operation  添加到queue中。 系统控制执行
 */
- (void)downloadVideoWithConfig:(BNM3U8DownloadConfig *)config progressBlock:(BNM3U8DownloadProgressBlock)progressBlock resultBlock:(BNM3U8DownloadResultBlock)resultBlock;

- (void)cannel:(NSString *)url;

- (void)cancelAll;

- (void)suspend;

- (void)resume;

/*是否存在任务*/
-(bool)hasTask:(NSString *)url;

-(NSString *)folderByUrl:(NSString *)url;

-(void)removeFolderByUrl:(NSString *)url;
@end

NS_ASSUME_NONNULL_END

