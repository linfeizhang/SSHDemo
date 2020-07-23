//
//  LocalFilesListViewController.m
//  NewTest
//
//  Created by 10361 on 2019/10/8.
//  Copyright © 2019 10361. All rights reserved.
//

#import "LocalFilesListViewController.h"
#import "LookFileViewController.h"

@interface LocalFilesListViewController ()<UITableViewDelegate,UITableViewDataSource,UIDocumentInteractionControllerDelegate>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *filesList;
@property (nonatomic,strong) MBProgressHUD *hud;
@end

@implementation LocalFilesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"document";
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.hud];
}

#pragma mark - TableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filesList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellStr = @"LocalFilesListViewControllerUITableViewCell";
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellStr];
    }
    if (self.filesList[indexPath.row] != nil) {
        cell.textLabel.text = self.filesList[indexPath.row];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *fileName = self.filesList[indexPath.row];
    LocalFilesManager *manager = [LocalFilesManager shared];
    LocalFileType type = [manager getLocalFileTypeWithName:fileName];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"文件操作" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *display = [UIAlertAction actionWithTitle:@"预览" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (type == LocalFileTypeDocument) {
            [self documentDisplayWithPath:[NSString stringWithFormat:@"%@/%@",[manager getDocumentsPath],fileName]];
        }else {
            LookFileViewController *lvc = [[LookFileViewController alloc]init];
            lvc.fileName = fileName;
            lvc.type = type;
            [self.navigationController pushViewController:lvc animated:YES];
        }
    }];
    UIAlertAction *delete = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [manager deleteFileWithName:fileName result:^(BOOL isSuccess) {
            if (isSuccess) {
                self.hud.label.text = @"删除成功";
                [self.hud showAnimated:YES];
                self.filesList = [[manager getLoaclFilesList] mutableCopy];
                [self.tableView reloadData];
                [self.hud hideAnimated:YES afterDelay:1];
            }else {
                self.hud.label.text = @"删除失败";
                [self.hud showAnimated:YES];
                [self.hud hideAnimated:YES afterDelay:1.5];
            }
        }];
    }];
    
    [alert addAction:display];
    [alert addAction:delete];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

// 简易文档浏览
- (void)documentDisplayWithPath:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    interactionController.delegate = self;
    [interactionController presentPreviewAnimated:YES];
    CGRect navRect = self.navigationController.navigationBar.frame;
    navRect.size = CGSizeMake(1500.0f,40.0f);
    [interactionController presentOpenInMenuFromRect:navRect inView:self.view animated:YES];
}

#pragma mark - UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller {
    return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller {
    return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller {
    return  self.view.frame;
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

- (NSMutableArray *)filesList {
    if (_filesList == nil) {
        _filesList = [[[LocalFilesManager shared] getLoaclFilesList] mutableCopy];
    }
    return _filesList;
}

- (MBProgressHUD *)hud {
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc]initWithView:self.view];
        _hud.mode = MBProgressHUDModeText;
    }
    return _hud;
}
@end
