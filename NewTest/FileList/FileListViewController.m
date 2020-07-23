//
//  FileListViewController.m
//  NewTest
//
//  Created by 10361 on 2019/10/8.
//  Copyright © 2019 10361. All rights reserved.
//

#import "FileListViewController.h"
#import "LocalFilesManager.h"

@interface FileListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) MBProgressHUD *hud;
@end

@implementation FileListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [self getTitleFromPath];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.hud];
}

#pragma mark - funcs

- (void)pushToNextDirectoryWithName:(NSString *)directoryName{
    FileListViewController *fvc = [[FileListViewController alloc]init];
    NSString *path = [NSString stringWithFormat:@"%@%@",self.model.path,directoryName];
    FileListModel *model = [[FileListModel alloc]init];
    model.fileListArray = [[self.model.sftp contentsOfDirectoryAtPath:path] mutableCopy];
    model.sftp = self.model.sftp;
    model.path = path;
    fvc.model = model;
    [self.navigationController pushViewController:fvc animated:YES];
}

- (void)downloadFileWithFileName:(NSString *)fileName {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"下载文件？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if (self.model.sftp.isConnected) {
            [self.hud showAnimated:YES];
            NSData *data = [self.model.sftp contentsAtPath:[NSString stringWithFormat:@"%@%@",self.model.path,fileName]];
            [[LocalFilesManager shared]createFileWith:data fileName:fileName result:^(BOOL isSuccess) {
                if (isSuccess) {
                    [self.hud hideAnimated:NO afterDelay:0.5];
                    self.hud.mode = MBProgressHUDModeText;
                    self.hud.label.text = @"下载成功";
                    [self.hud showAnimated:YES];
                    [self.hud hideAnimated:YES afterDelay:1.5];
                }else {
                    [self.hud hideAnimated:NO afterDelay:0.5];
                    self.hud.label.text = @"下载失败";
                    self.hud.mode = MBProgressHUDModeText;
                    [self.hud showAnimated:YES];
                    [self.hud hideAnimated:YES afterDelay:1.5];
                }
            }];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancel];
    [alert addAction:sure];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSString *)calculateFileSizeAndUnit:(NSNumber *)size {
    double number = [size doubleValue];
    NSString *sizeText = @"";
    if (number >= pow(10, 9)) {
        sizeText = [NSString stringWithFormat:@"%.2fGB", number/pow(10, 9)];
    } else if (number >= pow(10, 6)) {
        sizeText = [NSString stringWithFormat:@"%.2fMB", number/pow(10, 6)];
    } else if (number >= pow(10, 3)) {
        sizeText = [NSString stringWithFormat:@"%.2fKB", number/pow(10, 3)];
    } else {
        sizeText = [NSString stringWithFormat:@"%.2fB", number];
    }
    return sizeText;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NMSFTPFile *file = self.model.fileListArray[indexPath.row];
    if (file.isDirectory) {
        [self pushToNextDirectoryWithName:file.filename];
    }else {
        [self downloadFileWithFileName:file.filename];
    }
}

#pragma mark - TableViewDataSource

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString *cellStr = @"FileListViewControllerUITableViewCell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellStr];
    }
    if ((self.model.fileListArray!= nil) && (self.model.fileListArray[indexPath.row] != nil)) {
        NMSFTPFile *file = self.model.fileListArray[indexPath.row];
        cell.textLabel.text = file.filename;
        if (file.isDirectory) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else {
            cell.detailTextLabel.text = [self calculateFileSizeAndUnit:file.fileSize];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.model) {
        return self.model.fileListArray.count;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - getter

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectZero];
        _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    }
    return _tableView;
}

- (NSString *)getTitleFromPath {
    if (self.model) {
        NSMutableArray *array = [[self.model.path componentsSeparatedByString:@"/"] mutableCopy];
        [array removeLastObject];
        return [array lastObject];
    }
    return @"";
}

- (MBProgressHUD *)hud {
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc]initWithView:self.view];
        _hud.label.text = @"下载中...";
        
    }
    return _hud;
}
@end
