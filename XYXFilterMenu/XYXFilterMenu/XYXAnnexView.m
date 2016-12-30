//
//  XYXAnnexView.m
//  XYXFilterMenu
//
//  Created by Teresa on 16/12/30.
//  Copyright © 2016年 Teresa. All rights reserved.
//

#import "XYXAnnexView.h"
#import "XYXFilterMenuMacro.h"

#pragma mark - AnnexView

@implementation AnnexInputView

-(instancetype)init{
    if (self = [super init]) {
        [self configureUI];
    }
    return self;
}

-(void)configureUI{
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44.f);
    self.backgroundColor = ANNEX_BG_COLOR;
    self.clipsToBounds = YES;
    
    CGFloat labelWidth = 80.f;
    CGFloat fieldWidth = 63.f;
    CGFloat fieldHeight = self.frame.size.height - Annex_SpaceGap;
    CGFloat buttonWidth = 57.f;
    
    self.minField.frame = CGRectMake(self.separatorLineView.frame.origin.x - fieldWidth - Annex_SpaceGap,
                                     Annex_SpaceGap/2, fieldWidth, fieldHeight);
    self.maxField.frame = CGRectMake(self.separatorLineView.frame.origin.x + self.separatorLineView.frame.size.width +Annex_SpaceGap,Annex_SpaceGap/2, fieldWidth, fieldHeight);
    self.describeLabel.frame = CGRectMake(Annex_SpaceGap/2, Annex_SpaceGap/2, labelWidth, fieldHeight);
    self.confirmButton.frame = CGRectMake(SCREEN_WIDTH - buttonWidth - Annex_SpaceGap, Annex_SpaceGap/2, buttonWidth, self.frame.size.height-Annex_SpaceGap);
}

-(UIView *)separatorLineView{
    if (!_separatorLineView) {
        CGFloat width = 22.f;
        CGFloat height = 0.5f;
        _separatorLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, height)];
        _separatorLineView.center = CGPointMake(self.center.x, self.center.y);
        _separatorLineView.backgroundColor = SPEPARATOR_COLOR;
        [self addSubview:_separatorLineView];
    }
    return _separatorLineView;
}

-(UILabel *)describeLabel{
    if (!_describeLabel) {
        _describeLabel = [[UILabel alloc]init];
        _describeLabel.textColor = ANNEX_DETAIL_TEXT_COLOR;
        _describeLabel.font = [UIFont systemFontOfSize:14];
        _describeLabel.adjustsFontSizeToFitWidth = YES;
        _describeLabel.minimumScaleFactor = 0.8;
        [self addSubview:_describeLabel];
    }
    return _describeLabel;
}

-(UITextField *)minField{
    if (!_minField) {
        _minField = [[UITextField alloc]init];
        _minField.placeholder = NSLocalizedStringFromTableInBundle(@"ANNEX_VIEW_MIN", @"Root", FILTER_BUNDLE, @"最小");
        _minField.delegate = self;
        _minField.textAlignment = NSTextAlignmentCenter;
        _minField.font = [UIFont systemFontOfSize:Annex_TextField_FontSize];
        _minField.backgroundColor = ANNEX_TEXTFIELD_BG_COLOR;
        _minField.keyboardType = UIKeyboardTypeNumberPad;
        _minField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self addSubview:_minField];
    }
    return _minField;
}

-(UITextField *)maxField{
    if (!_maxField) {
        _maxField = [[UITextField alloc]init];
        _maxField.placeholder = NSLocalizedStringFromTableInBundle(@"ANNEX_VIEW_MAX", @"Root", FILTER_BUNDLE, @"最大");
        _maxField.delegate = self;
        _maxField.textAlignment = NSTextAlignmentCenter;
        _maxField.font = [UIFont systemFontOfSize:Annex_TextField_FontSize];
        _maxField.backgroundColor = ANNEX_TEXTFIELD_BG_COLOR;
        _maxField.keyboardType = UIKeyboardTypeNumberPad;
        _maxField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [self addSubview:_maxField];
    }
    return _maxField;
}

-(UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton setTitle:NSLocalizedStringFromTableInBundle(@"ANNEX_VIEW_CONFIRM", @"Root", FILTER_BUNDLE, @"确定") forState:UIControlStateNormal];
        [_confirmButton.titleLabel setFont:[UIFont systemFontOfSize:Annex_Button_FontSize]];
        [_confirmButton setTitleColor:ANNEX_CONFIRM_TEXT_COLOR forState:UIControlStateNormal];
        [_confirmButton setBackgroundColor:ANNEX_CONFIRM_BG_COLOR];
        [_confirmButton addTarget:self action:@selector(clickConfirm:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_confirmButton];
    }
    return _confirmButton;
}

-(void)clickConfirm:(UIButton*)sender{
    if (_confirmBtnClicked) {
        _confirmBtnClicked();
    }
}

-(void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 227.0/255, 227.0/255, 227.0/255, 1);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, rect.size.width,0);
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width,rect.size.height);
    CGContextStrokePath(context);
}

@end

@implementation AnnexConfirmView

-(instancetype)init{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44.f);
        self.backgroundColor = ANNEX_BG_COLOR;
        [self configureUI];
        self.clipsToBounds = YES;
    }
    return self;
}

-(void)configureUI{
    CGFloat gap = Annex_SpaceGap;
    CGFloat buttonWidth = (SCREEN_WIDTH - 3*gap)/2;
    CGFloat buttonHeight = CGRectGetHeight(self.frame) - gap;
    
    self.cancelButton.frame = CGRectMake(gap, gap/2, buttonWidth, buttonHeight);
    self.confirmButton.frame = CGRectMake(2*gap + buttonWidth, gap/2, buttonWidth, buttonHeight);
}

-(UIButton *)confirmButton{
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmButton.titleLabel setFont:[UIFont systemFontOfSize:Annex_Button_FontSize]];
        [_confirmButton setBackgroundColor:ANNEX_CONFIRM_BG_COLOR];
        [_confirmButton setTitle:NSLocalizedStringFromTableInBundle(@"ANNEX_VIEW_CONFIRM", @"Root", FILTER_BUNDLE, @"确定") forState:UIControlStateNormal];
        [_confirmButton setTitleColor:ANNEX_CONFIRM_TEXT_COLOR forState:UIControlStateNormal];
        [_confirmButton addTarget:self action:@selector(clickConfirm:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_confirmButton];
    }
    return _confirmButton;
}

-(UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:Annex_Button_FontSize]];
        [_cancelButton setTitle:NSLocalizedStringFromTableInBundle(@"ANNEX_VIEW_CANCEL", @"Root", FILTER_BUNDLE, @"重置") forState:UIControlStateNormal];
        [_cancelButton setTitleColor:ANNEX_CANCEL_TEXT_COLOR forState:UIControlStateNormal];
        [_cancelButton setBackgroundColor: ANNEX_CANCEL_BG_COLOR];
        [_cancelButton.layer setBorderColor:ANNEX_CANCEL_TEXT_COLOR.CGColor];
        [_cancelButton.layer setBorderWidth:0.4];
        [_cancelButton addTarget:self action:@selector(clickCancel:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
    }
    return _cancelButton;
}

-(void)clickConfirm:(UIButton*)sender{
    if (_confirmBtnClicked) {
        _confirmBtnClicked();
    }
}

-(void)clickCancel:(UIButton*)sender{
    if (_cancelBtnClicked) {
        _cancelBtnClicked();
    }
}

-(void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 227.0/255, 227.0/255, 227.0/255, 1);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, rect.size.width,0);
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width,rect.size.height);
    CGContextStrokePath(context);
}

@end
