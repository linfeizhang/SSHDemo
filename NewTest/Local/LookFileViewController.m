//
//  LookFileViewController.m
//  NewTest
//
//  Created by 10361 on 2019/10/9.
//  Copyright © 2019 10361. All rights reserved.
//

#import "LookFileViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface LookFileViewController ()

@property (nonatomic,copy) NSString *filePath;

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,strong) AVPlayer *avPlayer;

@end

@implementation LookFileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.fileName != nil) {
        self.title = self.fileName;
    }
    [self classifiedDisplay];
}

- (void)classifiedDisplay {
    switch (self.type) {
        case LocalFileTypeImage:
            [self imageDisplay];
            break;
        case LocalFileTypeAudio:
        case LocalFileTypeVideo:
            [self videoDisplay];
            break;
        default:
            [self showUnknowAlert];
            break;
    }
}

// 简易的图片浏览
- (void)imageDisplay {
    [self.view addSubview:self.imageView];
    self.imageView.image = [UIImage imageWithData:[[LocalFilesManager shared] getFileData:self.filePath]];
}

// 简易的视频播放
- (void)videoDisplay {
    NSURL *mediaUrl = [NSURL fileURLWithPath:self.filePath];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:mediaUrl];
    self.avPlayer = [[AVPlayer alloc]initWithPlayerItem:item];
    self.avPlayer.volume = 1;
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
    layer.frame = CGRectMake(0, kScreenHeight/2-250/2, kScreenWidth, 250);
    [self.view.layer addSublayer:layer];
    [self.avPlayer play];
}

- (void)showUnknowAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"暂时不支持这个类型的文件浏览" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:nil];
    [alert addAction:sure];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - getter

- (NSString *)filePath {
    if (_filePath == nil) {
        if (self.fileName != nil) {
            _filePath = [NSString stringWithFormat:@"%@/%@",[[LocalFilesManager shared] getDocumentsPath],self.fileName];
        }else {
            _filePath = @"";
        }
    }
    return _filePath;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight-64)];
        _imageView.backgroundColor = [UIColor blackColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}
@end
