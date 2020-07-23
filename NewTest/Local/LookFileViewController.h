//
//  LookFileViewController.h
//  NewTest
//
//  Created by 10361 on 2019/10/9.
//  Copyright © 2019 10361. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LookFileViewController : UIViewController

@property (nonatomic,copy) NSString *fileName;

@property (nonatomic,assign) LocalFileType type;

@end

NS_ASSUME_NONNULL_END
