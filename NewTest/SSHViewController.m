//
//  SSHViewController.m
//  NewTest
//
//  Created by zhanglinfeiMacAir on 2020/7/22.
//  Copyright © 2020 BeijingXiaoxiongBowang. All rights reserved.
//

#import "SSHViewController.h"

@interface SSHViewController ()

@end

@implementation SSHViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)GesysLogPath:(id)sender {
    NMSSHSession *session = [NMSSHSession connectToHost:@"10.5.0.24:22"
                                           withUsername:@"zhanglinfeimacair"];

    if (session.isConnected) {
        [session authenticateByPassword:@"inhand"];

        if (session.isAuthorized) {
            NSLog(@"Authentication succeeded");
            NSError *error = nil;
            NSString *response = [session.channel execute:@"cd ./Desktop/demo && scp *.* test/" error:&error];
            NSLog(@"List of my sites: %@", response);


            [session disconnect];
        }
    }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
