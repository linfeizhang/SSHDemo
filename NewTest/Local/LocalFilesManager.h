//
//  LocalFilesManager.h
//  NewTest
//
//  Created by 10361 on 2019/10/8.
//  Copyright © 2019 10361. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,LocalFileType) {
    LocalFileTypeImage = 1,
    LocalFileTypeDocument,
    LocalFileTypeVideo,
    LocalFileTypeAudio,
    LocalFileTypeZip,
    LocalFileTypeOther = -1,
};

NS_ASSUME_NONNULL_BEGIN

@interface LocalFilesManager : NSObject

+ (instancetype)shared;

// 获取沙盒路径
- (NSString *)getHomePath ;

// 获取Documents路径
- (NSString *)getDocumentsPath ;

// 获取Library路径
- (NSString *)getLibraryPath ;

// 获取Cache路径
- (NSString *)getCachePath ;

// 获取Tmp路径
- (NSString *)getTmpPath ;

// 创建文件夹
- (void)createFolder ;

// 创建文件
- (void)createFileWith:(NSData *)data fileName:(NSString *)fileName result:(void(^)(BOOL isSuccess))result;

// 删除文件
- (void)deleteFileWithName:(NSString *)fileName result:(void(^)(BOOL isSuccess))result ;

// 检测文件是否存在
- (BOOL)fileExist:(NSString *)filePath ;

// 写入文件内容
- (void)writeFile ;

// 追加内容
- (void)addFile ;

// 获取文件内容
- (NSData *)getFileData:(NSString *)filePath ;

// 获取文件大小
- (long long)getFileSizeWithPath:(NSString *)path ;

// 获取文件创建时间
- (NSString *)getFileCreatDateWithPath:(NSString *)path ;

// 获取文件更改日期
- (NSString *)getFileChangeDateWithPath:(NSString *)path ;

// 获取本地文件列表
- (NSArray *)getLoaclFilesList ;

// 获取文件类型
- (LocalFileType) getLocalFileTypeWithName:(NSString *)fileName;
@end

NS_ASSUME_NONNULL_END
