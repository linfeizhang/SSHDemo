//
//  FileListModel.h
//  NewTest
//
//  Created by 10361 on 2019/10/8.
//  Copyright © 2019 10361. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileListModel : NSObject

@property (nonatomic,strong) NSMutableArray *fileListArray;
@property (nonatomic,strong) NMSFTP *sftp;
@property (nonatomic,strong) NSString *path;

@end

NS_ASSUME_NONNULL_END
