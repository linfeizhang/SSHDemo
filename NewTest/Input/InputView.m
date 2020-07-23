//
//  InputView.m
//  SSHTEST
//
//  Created by 10361 on 2019/9/26.
//  Copyright © 2019 10361. All rights reserved.
//

#import "InputView.h"
#import <Masonry/Masonry.h>

@interface InputView ()

@property (nonatomic ,strong) UITextField *accountTF;
@property (nonatomic ,strong) UITextField *passwordTF;
@property (nonatomic ,strong) UITextField *portTF;
@property (nonatomic ,strong) UITextField *urlTF;
@property (nonatomic ,strong) UIButton *linkBtn;
@property (nonatomic ,strong) UIButton *lookLocalBtn;
@property (nonatomic ,strong) UIButton *downloadBtn;
@property (nonatomic ,strong) UIButton *uploadBtn;

@end

@implementation InputView

#pragma mark - func sender

- (void)clickButton:(UIButton *)sender {
    [self uploadData];
    [[NSUserDefaults standardUserDefaults]setObject:_accountTF.text forKey:@"USERNAME"];
    [[NSUserDefaults standardUserDefaults]setObject:_passwordTF.text forKey:@"PASSWORD"];
    [[NSUserDefaults standardUserDefaults]setObject:_portTF.text forKey:@"PORT"];
    [[NSUserDefaults standardUserDefaults]setObject:_urlTF.text forKey:@"URL"];
    if ([_delegate respondsToSelector:@selector(clickInputViewBtn:)]) {
        switch (sender.tag) {
            case 0:
                [_delegate clickInputViewBtn:InputViewBtnTypeUp];
                break;
            case 1:
                [_delegate clickInputViewBtn:InputViewBtnTypeDown];
                break;
            case 2:
                [_delegate clickInputViewBtn:InputViewBtnTypeLink];
                break;
            case 3:
                [_delegate clickInputViewBtn:InputViewBtnTypeLook];
                break;
            default:
                break;
        }
    }
}

- (void)uploadData {
    [self endEditing:YES];
    if (self.model != nil) {
        self.model.urlStr = self.urlTF.text;
        self.model.portStr = self.portTF.text;
        self.model.account = self.accountTF.text;
        self.model.password = self.passwordTF.text;
    }
}

#pragma mark - UI

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
    [self addSubview:self.urlTF];
    [self.urlTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(84);
        make.height.mas_equalTo(45);
    }];
    
    [self addSubview:self.portTF];
    [self.portTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.urlTF);
        make.top.equalTo(self.urlTF.mas_bottom).offset(10);
    }];
    
    [self addSubview:self.accountTF];
    [self.accountTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.urlTF);
        make.top.equalTo(self.portTF.mas_bottom).offset(10);
    }];
    
    [self addSubview:self.passwordTF];
    [self.passwordTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(self.accountTF);
        make.top.equalTo(self.accountTF.mas_bottom).offset(10);
    }];
    
    
    CGFloat btnOffect = kScreenWidth/16;
    CGFloat btnWidth = kScreenWidth/4;
    
//    [self addSubview:self.uploadBtn];
//    [self.uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(btnOffect);
//        make.height.mas_equalTo(50);
//        make.top.mas_equalTo(kScreenHeight-150);
//        make.width.mas_equalTo(btnWidth);
//    }];

    [self addSubview:self.lookLocalBtn];
    [self.lookLocalBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.height.mas_equalTo(50);
        make.bottom.mas_equalTo(-50);
        make.width.mas_equalTo(btnWidth);
    }];
    
    [self addSubview:self.downloadBtn];
    [self.downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(30);
        make.height.mas_equalTo(50);
        make.bottom.mas_equalTo(-150);
        make.width.mas_equalTo(btnWidth);
    }];

    [self addSubview:self.linkBtn];
    [self.linkBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-30);
        make.height.mas_equalTo(50);
        make.bottom.mas_equalTo(-50);
        make.width.mas_equalTo(btnWidth);
    }];
    
}

#pragma mark - getter

- (UITextField *)accountTF {
    if (_accountTF == nil) {
        _accountTF = [[UITextField alloc]init];
        _accountTF.placeholder = @"账号";
        _accountTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _accountTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _accountTF.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"USERNAME"];
        _accountTF.textColor = [UIColor blackColor];
        _accountTF.backgroundColor = [UIColor grayColor];
    }
    return _accountTF;
}

- (UITextField *)passwordTF {
    if (_passwordTF == nil) {
        _passwordTF = [[UITextField alloc]init];
        _passwordTF.placeholder = @"密码";
        _passwordTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _passwordTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _passwordTF.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"PASSWORD"];
        _passwordTF.textColor = [UIColor blackColor];
        _passwordTF.backgroundColor = [UIColor grayColor];
    }
    return _passwordTF;
}

- (UITextField *)portTF {
    if (_portTF == nil) {
        _portTF = [[UITextField alloc]init];
        _portTF.placeholder = @"端口";
        _portTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _portTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _portTF.textColor = [UIColor blackColor];
        _portTF.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"PORT"];
        _portTF.backgroundColor = [UIColor grayColor];
    }
    return _portTF;
}

- (UITextField *)urlTF {
    if (_urlTF == nil) {
        _urlTF = [[UITextField alloc]init];
        _urlTF.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"URL"];
        _urlTF.placeholder = @"主机";
        _urlTF.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _urlTF.autocorrectionType = UITextAutocorrectionTypeNo;
        _urlTF.textColor = [UIColor blackColor];
        _urlTF.backgroundColor = [UIColor grayColor];
    }
    return _urlTF;
}

- (UIButton *)uploadBtn {
    if (_uploadBtn == nil) {
        _uploadBtn = [[UIButton alloc]init];
        _uploadBtn.backgroundColor = [UIColor grayColor];
        _uploadBtn.tag = 0;
        [_uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
        [_uploadBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _uploadBtn;
}

- (UIButton *)downloadBtn {
    if (_downloadBtn == nil) {
        _downloadBtn = [[UIButton alloc]init];
        _downloadBtn.backgroundColor = [UIColor grayColor];
        _downloadBtn.tag = 1;
        [_downloadBtn setTitle:@"下载" forState:UIControlStateNormal];
        [_downloadBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_downloadBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadBtn;
}

- (UIButton *)linkBtn {
    if (_linkBtn == nil) {
        _linkBtn = [[UIButton alloc]init];
        _linkBtn.backgroundColor = [UIColor grayColor];
        _linkBtn.tag = 2;
        [_linkBtn setTitle:@"连接" forState:UIControlStateNormal];
        [_linkBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_linkBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _linkBtn;
}

- (UIButton *)lookLocalBtn {
    if (_lookLocalBtn == nil) {
        _lookLocalBtn = [[UIButton alloc]init];
        _lookLocalBtn.tag = 3;
        _lookLocalBtn.backgroundColor = [UIColor grayColor];
        [_lookLocalBtn setTitle:@"查看" forState:UIControlStateNormal];
        [_lookLocalBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [_lookLocalBtn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lookLocalBtn;
}

@end
