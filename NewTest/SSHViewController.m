//
//  SSHViewController.m
//  NewTest
//
//  Created by zhanglinfeiMacAir on 2020/7/22.
//  Copyright © 2020 BeijingXiaoxiongBowang. All rights reserved.
//

#import "SSHViewController.h"

@interface SSHViewController ()<NMSSHSessionDelegate,NMSSHChannelDelegate,UITextViewDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
//@property (strong, nonatomic) NMSSHSession * session;

@property (nonatomic, strong) dispatch_queue_t sshQueue;
@property (nonatomic, strong) NMSSHSession *session;
@property (nonatomic, assign) dispatch_once_t onceToken;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) NSMutableString *lastCommand;
@property (nonatomic, assign) BOOL keyboardInteractive;
@property (strong, nonatomic) NSString * currentTime;
@property (nonatomic,strong) MBProgressHUD *hud;

@end

@implementation SSHViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.keyboardInteractive = self.password == nil;
    self.currentTime = [self getCurrentTime];
    self.textField.enabled = NO;
    self.textField.delegate = self;
    self.textView.editable = NO;
    self.textView.selectable = NO;
    self.lastCommand = [[NSMutableString alloc] init];

    self.sshQueue = dispatch_queue_create("NMSSH.queue", DISPATCH_QUEUE_SERIAL);
    [self.view addSubview:self.hud];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillShow:)
//                                                 name:UIKeyboardWillShowNotification
//                                               object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(keyboardWillHide:)
//                                                 name:UIKeyboardWillHideNotification
//                                               object:nil];

    dispatch_once(&_onceToken, ^{
        [self connect:self];
    });
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self disconnect];
}
- (IBAction)submit:(id)sender {
    [self.textField resignFirstResponder];
    [self appendToTextView:self.textField.text];
    NSError * error;
    [self.session.channel write:[NSString stringWithFormat:@"%@ \n",self.textField.text] error:&error timeout:@20];
}
- (IBAction)save:(id)sender {
    //terminal
    //在某个范围内搜索文件夹的路径.
    //directory:获取哪个文件夹
    //domainMask:在哪个路径下搜索
    //expandTilde:是否展开路径.
    
    [self.hud showAnimated:YES];
    self.hud.mode = MBProgressHUDModeText;
    self.hud.label.text = @"保存日志...";
    //这个方法获取出的结果是一个数组.因为有可以搜索到多个路径.
    NSArray *docPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //在这里,我们指定搜索的是Cache目录,所以结果只有一个,取出Cache目录
    NSString *documentPath = docPaths.firstObject;
    
    //拼接文件路径
    NSString *filePathName = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"terminal_%@_log.txt",self.currentTime]];

    BOOL res = [self.textView.text writeToFile:filePathName atomically:YES encoding:NSUTF8StringEncoding error:nil];

    [self.hud hideAnimated:NO afterDelay:0.5];
    self.hud.mode = MBProgressHUDModeText;
    self.hud.label.text = @"保存成功";
    [self.hud showAnimated:YES];
    [self.hud hideAnimated:YES afterDelay:1.5];
    NSLog(@"-----%d",res);
}
-(NSString *)getCurrentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];//yyyy-MM-dd-hh-mm-ss
    [formatter setDateFormat:@"yyyyMMddhhmmss"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}

- (IBAction)connect:(id)sender {
    [self.textField resignFirstResponder];
    dispatch_async(self.sshQueue, ^{
        self.session = [NMSSHSession connectToHost:self.host withUsername:self.username];
        self.session.delegate = self;

        if (!self.session.connected) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self appendToTextView:@"Connection error"];
            });

            return;
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [self appendToTextView:[NSString stringWithFormat:@"ssh %@@%@\n", self.session.username, self.host]];
        });

        if (self.keyboardInteractive) {
            [self.session authenticateByKeyboardInteractive];
        }
        else {
            [self.session authenticateByPassword:self.password];
        }

        if (!self.session.authorized) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self appendToTextView:@"Authentication error\n"];
                self.textField.enabled = NO;
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.textField.enabled = YES;
            });

            self.session.channel.delegate = self;
            self.session.channel.requestPty = YES;

            NSError *error;
            [self.session.channel startShell:&error];

            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self appendToTextView:error.localizedDescription];
                    self.textField.enabled = NO;
                });
            }
        }
    });

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.textView resignFirstResponder];
}

- (void)disconnect{
    dispatch_async(self.sshQueue, ^{
        [self.session disconnect];
    });
}

- (void)appendToTextView:(NSString *)text {
    self.textView.text = [NSString stringWithFormat:@"%@%@", self.textView.text, text];
    [self.textView scrollRangeToVisible:NSMakeRange([self.textView.text length] - 1, 1)];
}

- (void)performCommand {
    if (self.semaphore) {
        self.password = [self.lastCommand substringToIndex:MAX(0, self.lastCommand.length - 1)];
        dispatch_semaphore_signal(self.semaphore);
    }
    else {
        NSString *command = [self.lastCommand copy];
        dispatch_async(self.sshQueue, ^{
            [[self.session channel] write:command error:nil timeout:@10];
        });
    }

    [self.lastCommand setString:@""];
}

- (void)channel:(NMSSHChannel *)channel didReadData:(NSString *)message {
    NSLog(@"%@",message);
    NSString *msg = [message copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendToTextView:msg];
    });
}

- (void)channel:(NMSSHChannel *)channel didReadError:(NSString *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendToTextView:[NSString stringWithFormat:@"[ERROR] %@", error]];
    });
}

- (void)channelShellDidClose:(NMSSHChannel *)channel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendToTextView:@"\nShell closed\n"];
        self.textField.enabled = NO;
    });
}

- (NSString *)session:(NMSSHSession *)session keyboardInteractiveRequest:(NSString *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendToTextView:request];
        self.textField.enabled = YES;
    });

    self.semaphore = dispatch_semaphore_create(0);
    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    self.semaphore = nil;

    return self.password;
}

- (void)session:(NMSSHSession *)session didDisconnectWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self appendToTextView:[NSString stringWithFormat:@"\nDisconnected with error: %@", error.localizedDescription]];

        self.textField.enabled = NO;
    });
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
//- (void)textViewDidChange:(UITextView *)textView {
//    [textView scrollRangeToVisible:NSMakeRange([textView.text length] - 1, 1)];
//}

//- (void)textViewDidChangeSelection:(UITextView *)textView {
//    if (textView.selectedRange.location < textView.text.length - self.lastCommand.length - 1) {
//        textView.selectedRange = NSMakeRange([textView.text length], 0);
//    }
//}
//
//- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    if (text.length == 0) {
//
//        if ([self.lastCommand length] > 0) {
//            [self.lastCommand replaceCharactersInRange:NSMakeRange(self.lastCommand.length-1, 1) withString:@""];
//            return YES;
//        }
//        else {
//            return NO;
//        }
//    }
//
//    [self.lastCommand appendString:text];
//
//    if ([text isEqualToString:@"\n"]) {
//        [self performCommand];
//    }
//
//    return YES;
//}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];

    CGRect ownFrame = [[[[UIApplication sharedApplication] delegate] window] convertRect:self.textView.frame fromView:self.textView.superview];

    CGRect coveredFrame = CGRectIntersection(ownFrame, keyboardFrame);
    coveredFrame = [[[[UIApplication sharedApplication] delegate] window] convertRect:coveredFrame toView:self.textView.superview];

    self.textView.contentInset = UIEdgeInsetsMake(self.textView.contentInset.top, 0, coveredFrame.size.height, 0);
    self.textView.scrollIndicatorInsets = self.textView.contentInset;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.textView.contentInset = UIEdgeInsetsMake(self.textView.contentInset.top, 0, 0, 0);
    self.textView.scrollIndicatorInsets = self.textView.contentInset;
}

- (MBProgressHUD *)hud {
    if (_hud == nil) {
        _hud = [[MBProgressHUD alloc]initWithView:self.view];
        _hud.label.text = @"保存日志...";
        
    }
    return _hud;
}

@end
