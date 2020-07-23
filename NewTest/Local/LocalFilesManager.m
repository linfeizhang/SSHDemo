//
//  LocalFilesManager.m
//  NewTest
//
//  Created by 10361 on 2019/10/8.
//  Copyright © 2019 10361. All rights reserved.
//

#import "LocalFilesManager.h"

@implementation LocalFilesManager

static NSArray *documentExtensions = nil;
static NSArray *imageExtensions = nil;
static NSArray *videoExtensions = nil;
static NSArray *audioExtensions = nil;
static NSArray *zipExtensions = nil;
static id _instance = nil;

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    if (_instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [super allocWithZone:zone];
        });
    }
    return _instance;
}

+ (void)load {
    documentExtensions = @[@"doc", @"docx",@"xls", @"xlsx", @"xlsm", @"xlt", @"xltx", @"xltm",@"ppt", @"pptx",@"txt", @"pdf", @"pages", @"numbers", @"key"];
    imageExtensions= @[@"tif", @"tiff", @"gif", @"jpeg", @"jpg", @"png", @"heic", @"webp"];
    videoExtensions = @[@"avi", @"rmvb", @"rm", @"3gp", @"asf", @"swf", @"mpg", @"mpeg", @"mpe", @"wmv", @"mp4", @"mkv", @"vob", @"flv", @"mpeg4", @"ts", @"mov"];
    audioExtensions = @[@"mp3", @"wma", @"wav", @"acm", @"aif", @"aifc", @"aiff", @"m4a"];
    zipExtensions = @[@"rar", @"zip", @"arj", @"z", @"7z"];
}

- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}

// 获取沙盒路径
- (NSString *)getHomePath {
    NSString *homePath = NSHomeDirectory();
    return homePath;
}

// 获取Documents路径
- (NSString *)getDocumentsPath {
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = docPaths.firstObject;
    return documentPath;
}

// 获取Library路径
- (NSString *)getLibraryPath {
    NSArray *libPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryPath = libPaths.firstObject;
    return libraryPath;
}

// 获取Cache路径
- (NSString *)getCachePath {
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = cachePaths.firstObject;
    return cachePath;
}
// 获取Tmp路径
- (NSString *)getTmpPath {
    NSString *tmpPath = NSTemporaryDirectory();
    return tmpPath;
}

// 创建文件夹
- (void)createFolder {
    NSString *docPath = [self getDocumentsPath];
    NSString *folderName = [docPath stringByAppendingPathComponent:@"note"];
    NSFileManager *manager = [NSFileManager defaultManager];
    // 创建文件夹
    // path 文件路径
    // withIntermediateDirectories: YES 如果文件夹存在可以覆盖 NO 不可覆盖
    BOOL isSuccess = [manager createDirectoryAtPath:folderName withIntermediateDirectories:YES attributes:nil error:nil];
    if (isSuccess){
        NSLog(@"文件夹创建成功！");
    }else {
        NSLog(@"文件夹创建失败！");
    }
}

// 创建文件
- (void)createFileWith:(NSData *)data fileName:(NSString *)fileName result:(void(^)(BOOL isSuccess))result {
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self getDocumentsPath],fileName];
    NSLog(@"\n\n\n\n-----%@\n\n\n\n",filePath);
    result?result([manager createFileAtPath:filePath contents:data attributes:nil]):nil;
}

// 删除文件
- (void)deleteFileWithName:(NSString *)fileName result:(void(^)(BOOL isSuccess))result{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[self getDocumentsPath],fileName];
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isExit = [self fileExist:filePath];
    if (isExit){
        result?result([manager removeItemAtPath:filePath error:nil]):nil;
    }
}

// 检测文件是否存在
- (BOOL)fileExist:(NSString *)filePath {
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return YES;
    }else {
        return NO;
    }
}

// 写入文件内容
- (void)writeFile {
    NSString *docPath = [self getDocumentsPath];
    NSString *mtestPath = [docPath stringByAppendingPathComponent:@"note"];
    NSString *filePath = [mtestPath stringByAppendingPathComponent:@"note.txt"];
    NSString *content = @"我的笔记";
    BOOL isSuccess = [content writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (isSuccess){
        NSLog(@"写入文件成功!");
    }else {
        NSLog(@"写入文件失败!");
    }
}

// 追加内容
- (void)addFile {
    NSString *docPath = [self getDocumentsPath];
    NSString *mtestPath = [docPath stringByAppendingPathComponent:@"note"];
    NSString *filePath = [mtestPath stringByAppendingPathComponent:@"note.txt"];
    // 打开文件、准备更新
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    // 将节点跳转到文件的末尾
    [fileHandle seekToEndOfFile];
    NSString *string = @"这是要添加的内容";
    NSData *stringData = [string dataUsingEncoding:NSUTF8StringEncoding];
    // 写入内容
    [fileHandle writeData:stringData];
    // 最后要关闭文件
    [fileHandle closeFile];
}


//获取文件内容
- (NSData *)getFileData:(NSString *)filePath {
    NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    NSData *fileData = [handle readDataToEndOfFile];
    [handle closeFile];
    return fileData;
}

//获取文件大小
- (long long)getFileSizeWithPath:(NSString *)path {
    unsigned long long fileLength = 0;
    NSNumber *fileSize;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:nil];
    if ((fileSize = [fileAttributes objectForKey:NSFileSize])) {
        fileLength = [fileSize unsignedLongLongValue]; //单位是 B
    }
    return fileLength / 1000; //换算为K
}

//获取文件创建时间
- (NSString *)getFileCreatDateWithPath:(NSString *)path {
    NSString *date = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:nil];
    date = [fileAttributes objectForKey:NSFileCreationDate];
    return date;
}

//获取文件更改日期
- (NSString *)getFileChangeDateWithPath:(NSString *)path {
    NSString *date = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:path error:nil];
    date = [fileAttributes objectForKey:NSFileModificationDate];
    return date;
}

// 获取本地文件列表
- (NSArray *)getLoaclFilesList {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm subpathsAtPath:[self getDocumentsPath]];
    return files;
}

// 获取文件类型
- (LocalFileType)getLocalFileTypeWithName:(NSString *)fileName {
    NSString *type = [fileName pathExtension];
    if ([imageExtensions containsObject:type]) {
        return LocalFileTypeImage;
    }else if ([documentExtensions containsObject:type]) {
        return LocalFileTypeDocument;
    }else if ([videoExtensions containsObject:type]) {
        return LocalFileTypeVideo;
    }else if ([zipExtensions containsObject:type]) {
        return LocalFileTypeZip;
    }else if ([audioExtensions containsObject:type]) {
        return LocalFileTypeAudio;
    }else {
        return LocalFileTypeOther;
    }
}


@end
