//
//  InputView.h
//  SSHTEST
//
//  Created by 10361 on 2019/9/26.
//  Copyright © 2019 10361. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, InputViewBtnType) {
    InputViewBtnTypeLink = 0,
    InputViewBtnTypeUp,
    InputViewBtnTypeDown,
    InputViewBtnTypeLook,
};

@protocol InputViewBtnClickDelegate <NSObject>

- (void)clickInputViewBtn:(InputViewBtnType)senderType;

@end



@interface InputView : UIView

@property (nonatomic,strong) InputModel *model;

@property (nonatomic,weak) id <InputViewBtnClickDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
