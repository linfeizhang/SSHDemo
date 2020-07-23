//
//  InputModel.h
//  NewTest
//
//  Created by 10361 on 2019/9/29.
//  Copyright © 2019 10361. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface InputModel : NSObject

@property (nonatomic,copy) NSString *urlStr;
@property (nonatomic,copy) NSString *portStr;
@property (nonatomic,copy) NSString *account;
@property (nonatomic,copy) NSString *password;
@end

NS_ASSUME_NONNULL_END
