//
//  XYXAnnexView.h
//  XYXFilterMenu
//
//  Created by Teresa on 16/12/30.
//  Copyright © 2016年 Teresa. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AnnexBlock)();

@interface AnnexInputView : UIView<UITextFieldDelegate>

@property (nonatomic,strong)UILabel *describeLabel;
@property (nonatomic,strong)UITextField *minField;
@property (nonatomic,strong)UIView *separatorLineView;
@property (nonatomic,strong)UITextField *maxField;
@property (nonatomic,strong)UIButton *confirmButton;

@property (nonatomic,copy)AnnexBlock confirmBtnClicked;

@end

@interface AnnexConfirmView : UIView

@property (nonatomic,strong)UIButton *cancelButton;
@property (nonatomic,strong)UIButton *confirmButton;

@property (nonatomic,copy)AnnexBlock confirmBtnClicked;
@property (nonatomic,copy)AnnexBlock cancelBtnClicked;

@end
