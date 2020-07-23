//
//  SSHViewController.h
//  NewTest
//
//  Created by zhanglinfeiMacAir on 2020/7/22.
//  Copyright © 2020 BeijingXiaoxiongBowang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSHViewController : UIViewController
@property (nonatomic, strong) NSString *host;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
- (IBAction)connect:(id)sender;
@end

NS_ASSUME_NONNULL_END
