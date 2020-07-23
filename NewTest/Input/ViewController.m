//
//  ViewController.m
//  NewTest
//
//  Created by 10361 on 2019/9/29.
//  Copyright © 2019 10361. All rights reserved.
//

#import "ViewController.h"
#import "InputView.h"
#import "InputModel.h"
#import "FileListViewController.h"
#import "LocalFilesListViewController.h"
#import "FileListModel.h"
#import "SSHViewController.h"

@interface ViewController ()<InputViewBtnClickDelegate>

@property (nonatomic,strong) InputView *inputView;

@property (nonatomic,strong) InputModel *model;

@property (nonatomic,strong) NMSFTP *sftp;

@property (nonatomic,assign) BOOL sftpIsConnected;
@property (nonatomic,strong) MBProgressHUD *hud;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"GE CT数据连接";
    self.sftpIsConnected = NO;
    self.model = [[InputModel alloc]init];
    self.inputView = [[InputView alloc]initWithFrame:self.view.frame];
    self.inputView.delegate = self;
    self.inputView.model = self.model;
    [self.view addSubview:self.inputView];
}

- (void)clickInputViewBtn:(InputViewBtnType)senderType {
    switch (senderType) {
        case InputViewBtnTypeLink:
            // 连接到服务器
            [self linkToSFTP];
            break;
        case InputViewBtnTypeUp:
            // 上传文件到服务器
            [self upToSFTP];
            break;
        case InputViewBtnTypeDown:
            // 下载文件到本地
            [self downFromSFTP];
            break;
        case InputViewBtnTypeLook:
            // 下载文件到本地
            [self lookLocalFiles];
            break;
        default:
            break;
    }
}

#pragma mark - click funcs

- (void)linkToSFTP {
    if (self.sftpIsConnected) {
        [self.sftp disconnect];
        self.sftpIsConnected = NO;
        NSLog(@"SFTP disconnect");
    }else {
        NSString *urlStr = [NSString stringWithFormat:@"%@:%@",self.model.urlStr,self.model.portStr];
        NMSSHSession *session = [NMSSHSession connectToHost:urlStr
                                               withUsername:self.model.account];
        
        if (session.isConnected) {
            NSLog(@"Successfully created a new session");
        
            [session authenticateByPassword:self.model.password];
            
            if (session.isAuthorized) {
                NSLog(@"Successfully authorized");
            
                self.sftp = [[NMSFTP alloc]initWithSession:session];
                
                if ([self.sftp connect]) {
                    NSLog(@"SFTP connect success");
                    self.sftpIsConnected = YES;
                    [self pushToFileList];
                }else {
                    NSLog(@"SFTP connect failure");
                    self.sftpIsConnected = NO;

                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"获取服务器目录失败" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                    [alert addAction:cancel];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }else{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"用户名密码错误" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
                [alert addAction:cancel];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }else{

            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"链接服务器失败" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancel];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
}

- (void)pushToFileList {
    FileListModel *model = [[FileListModel alloc]init];
    model.fileListArray = [[self.sftp contentsOfDirectoryAtPath:rootPath] mutableCopy];
    model.sftp = self.sftp;
    model.path = rootPath;
    
    FileListViewController *fvc = [[FileListViewController alloc]init];
    fvc.model = model;
    [self.navigationController pushViewController:fvc animated:YES];
}

- (void)upToSFTP {
    NSString *pathBundle = [[NSBundle mainBundle]pathForResource:@"Test" ofType:@"txt"];
    NSData *data = [[NSData alloc]initWithContentsOfFile:pathBundle];
    if ([self.sftp writeContents:data toFileAtPath:testFilePath]) {
        NSLog(@"SFTP updata success");
        NSLog(@"%@",[self.sftp contentsOfDirectoryAtPath:testPath]);
    }else {
        NSLog(@"SFTP updata failure");
    }
}

- (void)downFromSFTP {
    SSHViewController * sshViewController = [[SSHViewController alloc]init];
    sshViewController.password = self.model.password;
    sshViewController.host = [NSString stringWithFormat:@"%@:%@",self.model.urlStr,self.model.portStr];
    sshViewController.username = self.model.account;
    
    [self.navigationController pushViewController:sshViewController animated:YES];
//    if (self.sftp.isConnected) {
//        NSData *data = [self.sftp contentsAtPath:testFilePath];
//        [[LocalFilesManager shared]createFileWith:data fileName:@"Test.txt" result:^(BOOL isSuccess) {
//            if (isSuccess) {
//                self.hud.mode = MBProgressHUDModeText;
//                self.hud.label.text = @"下载成功";
//                [self.hud showAnimated:YES];
//                [self.hud hideAnimated:YES afterDelay:1.5];
//            }else {
//                self.hud.mode = MBProgressHUDModeText;
//                self.hud.label.text = @"下载失败";
//                [self.hud showAnimated:YES];
//                [self.hud hideAnimated:YES afterDelay:1.5];
//            }
//        }];
//    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)lookLocalFiles {
    LocalFilesListViewController *lvc = [[LocalFilesListViewController alloc]init];
    [self.navigationController pushViewController:lvc animated:YES];
}

- (void)dealloc {
    [self.sftp disconnect];
    NSLog(@"SFTP disconnect");
}

- (MBProgressHUD *)hud {
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc]initWithView:self.view];
        _hud.label.text = @"下载中...";
    }
    return _hud;
}
@end
