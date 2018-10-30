//
//  XYXFilterMenu.m
//  XYXFilterMenu
//
//  Created by Teresa on 16/12/5.
//  Copyright © 2016年 Teresa. All rights reserved.
//

#import "XYXFilterMenu.h"
#import "XYXFilterView.h"
#import "XYXIndexPath.h"

@interface XYXFilterMenu ()
//View
@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, strong) XYXFilterView *filterView;

//Data
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) NSInteger numOfMenu;

//Refer to Selection
@property (nonatomic, assign) BOOL show;
@property (nonatomic, assign) NSInteger currentSelectedColumn;

//Layers
@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, copy) NSArray *indicators;
@property (nonatomic, copy) NSArray *menuBgLayers;

@property (nonatomic, copy) NSString *titleTruncationMode;

///Use while you want to reset menu title after initiate.
-(void)resetMenuTitle;

@end

@implementation XYXFilterMenu


#pragma mark - Life Cycle

-(instancetype)initWithOrigin:(CGPoint)origin height:(CGFloat)height{
    if (self = [super initWithFrame:CGRectMake(origin.x, origin.y, SCREEN_WIDTH, height)]) {
        self.origin = origin;
        self.backgroundColor = self.separatorColor;
        
        UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
        [self addGestureRecognizer:tapGesture];
        
        // Initial Data
        _menuTitleMargin = 20.f;
        _menuTitleFontSize = 14.f;
        _menuTitleTruncation = MenuTitleTruncationEnd;
        _show = NO;
        _currentSelectedColumn = -1;
        _graySpace = 200;
        
        // Keyboard Watch
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
    }
    return self;
}

#pragma mark - Getter & Setter

-(UIColor *)titleColor{
    if (!_titleColor) {
        _titleColor = MENU_TITLE_DEFAULT_COLOR;
    }
    return _titleColor;
}

-(UIColor *)titleSelectedColor{
    if (!_titleSelectedColor) {
        _titleSelectedColor = MENU_TITLE_SELECTED_COLOR;
    }
    return _titleSelectedColor;
}

-(UIColor *)menuBackgroundColor{
    if (!_menuBackgroundColor) {
        _menuBackgroundColor = MENU_BG_DEFAULT_COLOR;
    }
    return _menuBackgroundColor;
}

-(UIColor *)menuBackgroundSelectedColor{
    if (!_menuBackgroundSelectedColor) {
        _menuBackgroundSelectedColor = MENU_BG_SELECTED_COLOR;
    }
    return _menuBackgroundSelectedColor;
}

-(UIColor *)separatorColor{
    if (!_separatorColor) {
        _separatorColor = SPEPARATOR_COLOR;
    }
    return _separatorColor;
}

-(XYXFilterView *)filterView{
    if (!_filterView) {
        _filterView = [[XYXFilterView alloc]init];
        _filterView.shouldMenuTitleLinkedToCellClick = self.shouldMenuTitleLinkedToCellClick;
        _filterView.dataSource = self.dataSource;
        _filterView.delegate = self.delegate;
        _filterView.defaultUnfoldHeight = CGRectGetHeight(self.backGroundView.frame) - self.graySpace - CGRectGetHeight(self.frame);
        _filterView.frame = CGRectMake(0, CGRectGetMaxY(self.frame), SCREEN_WIDTH, _filterView.defaultUnfoldHeight);
        _filterView.menu = self;
    }
    return _filterView;
}

-(UIView *)backGroundView{
    if (!_backGroundView) {
        _backGroundView = [[UIView alloc]initWithFrame:CGRectMake(_origin.x, _origin.y, SCREEN_WIDTH, SCREEN_HEIGHT - _origin.y)];
        _backGroundView.backgroundColor = self.menuBackgroundColor;
        _backGroundView.opaque = NO;
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
        [_backGroundView addGestureRecognizer:gesture];
    }
    return _backGroundView;
}

-(MenuColumnType)currentColumnType{
    return self.filterView.currentColumnType;
}

-(void)setDataSource:(id<XYXFilterMenuDataSource>)dataSource{
    if (_dataSource == dataSource) {
        return;
    }
    _dataSource = dataSource;
    
    [self initialMenu];
}

-(void)setDelegate:(id<XYXFilterMenuDelegate>)delegate{
    if (_delegate == delegate) {
        return;
    }else{
        _delegate = delegate;
    }
}
-(void)setShouldMenuTitleLinkedToCellClick:(BOOL)shouldMenuTitleLinkedToCellClick{
    _shouldMenuTitleLinkedToCellClick = shouldMenuTitleLinkedToCellClick;
    self.filterView.shouldMenuTitleLinkedToCellClick = shouldMenuTitleLinkedToCellClick;
}

-(void)setShouldTrimFilterHeightToFit:(BOOL)shouldTrimFilterHeightToFit{
    _shouldTrimFilterHeightToFit = shouldTrimFilterHeightToFit;
    self.filterView.shouldTrimFilterHeightToFit = shouldTrimFilterHeightToFit;
}

#pragma mark - Public

-(void)refreshMenuWithTitle:(NSString *)title atColum:(NSUInteger)column andFoldFilterView:(BOOL)shouldFold{

    CATextLayer *theTitle = (CATextLayer *)self.titles[column];
    theTitle.string = title;
    CGSize size = [self calculateTitleSizeWithString:title];
    CGFloat sizeWidth = (size.width < ((self.frame.size.width / _numOfMenu) - self.menuTitleMargin)) ? size.width : (self.frame.size.width / _numOfMenu - self.menuTitleMargin);
    theTitle.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    
    [(CALayer *)self.menuBgLayers[column] setBackgroundColor:self.menuBackgroundColor.CGColor];
    CAShapeLayer *indicator = (CAShapeLayer *)_indicators[column];
    CGPoint point = CGPointMake(CGRectGetMaxX(theTitle.frame),self.frame.size.height/2);
    indicator.position = CGPointMake(point.x + self.menuTitleMargin/4, point.y + 2);
    
    if (shouldFold) {
        [self animateIndicator:_indicators[_currentSelectedColumn] background:_backGroundView filterView:self.filterView title:theTitle unfold:NO complecte:^{
            _currentSelectedColumn = column;
            _show = NO;
        }];
    }
}

-(void)dismissFilterView{
    [self backgroundTapped:nil];
}

#pragma mark - Private

-(void)initialMenu{
    if ([_dataSource respondsToSelector:@selector(numberOfColumnsInMenu:)]) {
        _numOfMenu = [_dataSource numberOfColumnsInMenu:self];
    } else {
        _numOfMenu = 1;
    }
    
    CGFloat textLayerInterval = self.frame.size.width / (_numOfMenu * 2);
    CGFloat bgLayerInterval = self.frame.size.width / _numOfMenu;
    
    NSMutableArray *tempBgLayers = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    NSMutableArray *tempTitles = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    NSMutableArray *tempIndicators = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    
    for (int i = 0; i < _numOfMenu; i++) {
        //bgLayer
        CGPoint bgLayerPosition = CGPointMake((i+0.5)*bgLayerInterval, self.frame.size.height/2);
        CALayer *bgLayer = [self createBgLayerWithColor:self.menuBackgroundColor position:bgLayerPosition];
        [self.layer addSublayer:bgLayer];
        [tempBgLayers addObject:bgLayer];
        
        //title
        CGPoint titlePosition = CGPointMake( (i * 2 + 1) * textLayerInterval , self.frame.size.height / 2);
        NSString *titleString = nil;
        if ([_dataSource respondsToSelector:@selector(menu:titleForColumnAtIndexPath:)]) {
            titleString = [_dataSource menu:self titleForColumnAtIndexPath:[XYXIndexPath indexPathWithColumn:i row:0]];
        }else{
            titleString = [_dataSource menu:self titleForRowAtIndexPath:[XYXIndexPath indexPathWithColumn:i row:0]];
        }
        
        CATextLayer *title = [self createTextLayerWithNSString:titleString color:self.titleColor position:titlePosition];
        [self.layer addSublayer:title];
        [tempTitles addObject:title];
        
        //indicator
        CAShapeLayer *indicator = [self createIndicatorWithColor:self.titleColor position:CGPointMake(CGRectGetMaxX(title.frame), self.frame.size.height/2)];
        
        [self.layer addSublayer:indicator];
        [tempIndicators addObject:indicator];
    }
    self.titles = [tempTitles copy];
    self.indicators = [tempIndicators copy];
    self.menuBgLayers = [tempBgLayers copy];
}

-(void)resetMenuTitle{
    for (int column = 0; column < _numOfMenu; column++) {
        CATextLayer *text = self.titles[column];
        CATextLayer *indicator = self.indicators[column];
        
        NSString *theTitle = nil;
        if ([_dataSource respondsToSelector:@selector(menu:titleForColumnAtIndexPath:)]) {
            theTitle = [_dataSource menu:self titleForColumnAtIndexPath:[XYXIndexPath indexPathWithColumn:column row:0]];
        }else{
            theTitle = [_dataSource menu:self titleForRowAtIndexPath:[XYXIndexPath indexPathWithColumn:column row:0]];
        }
        
        CGSize size = [self calculateTitleSizeWithString:theTitle];
        CGFloat sizeWidth = (size.width < ((self.frame.size.width / _numOfMenu) - self.menuTitleMargin)) ? size.width : (self.frame.size.width / _numOfMenu - self.menuTitleMargin);
        text.bounds = CGRectMake(0, 0, sizeWidth, size.height);
        text.string = theTitle;
        indicator.position = CGPointMake(CGRectGetMaxX(text.frame) + self.menuTitleMargin/4, indicator.position.y);
    }

}

- (CALayer *)createBgLayerWithColor:(UIColor *)color position:(CGPoint)position {
    CALayer *layer = [CALayer layer];
    layer.position = position;
    layer.bounds = CGRectMake(position.x, position.y, self.frame.size.width/self.numOfMenu, self.frame.size.height-1);
    layer.backgroundColor = color.CGColor;
    return layer;
}

- (CATextLayer *)createTextLayerWithNSString:(NSString *)string color:(UIColor *)color position:(CGPoint)point {
    
    CGSize size = [self calculateTitleSizeWithString:string];
    
    CATextLayer *layer = [CATextLayer new];
    CGFloat sizeWidth = (size.width < ((self.frame.size.width / _numOfMenu) - self.menuTitleMargin)) ? size.width : (self.frame.size.width / _numOfMenu - self.menuTitleMargin);
    layer.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    layer.string = string;
    layer.fontSize = self.menuTitleFontSize;
    layer.alignmentMode = kCAAlignmentCenter;
    layer.foregroundColor = color.CGColor;
    layer.contentsScale = [[UIScreen mainScreen] scale];
    layer.position = point;
    
    switch (self.menuTitleTruncation) {
        case MenuTitleTruncationNone:
            layer.truncationMode = kCATruncationNone;
            break;
        case MenuTitleTruncationStart:
            layer.truncationMode = kCATruncationStart;
            break;
        case MenuTitleTruncationMiddle:
            layer.truncationMode = kCATruncationMiddle;
            break;
        case MenuTitleTruncationEnd:
            layer.truncationMode = kCATruncationEnd;
            break;
    }
    return layer;
}

- (CGSize)calculateTitleSizeWithString:(NSString *)string{
    CGFloat fontSize = self.menuTitleFontSize;
    NSDictionary *dic = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]};
    CGSize size = [string boundingRectWithSize:CGSizeMake(280, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    return size;
}

- (CAShapeLayer *)createIndicatorWithColor:(UIColor *)color position:(CGPoint)point {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(8, 0)];
    [path addLineToPoint:CGPointMake(4, 4)];
    [path closePath];
    
    layer.path = path.CGPath;
    layer.lineWidth = 0.8;
    layer.fillColor = color.CGColor;
        
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    layer.position = CGPointMake(point.x + self.menuTitleMargin/4, point.y + 2);
    
    return layer;
}

#pragma mark - Keyboard

-(void)keyboardWillShow:(NSNotification*)aNotification{
    
    CGRect keyboardFrameEnd = [[aNotification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat minY_keyboard = keyboardFrameEnd.origin.y;
    CGFloat maxY_filterView = CGRectGetMaxY(self.filterView.frame);
    CGFloat deltaHeight_filterView = maxY_filterView > minY_keyboard ? maxY_filterView - minY_keyboard : 0;
        
    if (deltaHeight_filterView) {
        CGFloat animateDuration = [[[aNotification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        [self.filterView animateHeight:deltaHeight_filterView withDuration:animateDuration complete:nil];
    }
}

#pragma mark - Guesture

-(void)menuTapped:(UITapGestureRecognizer *)paramSender {
    if(!self.dataSource){
        return;
    }
    [self.filterView endEditing:YES];
    
    CGPoint touchPoint = [paramSender locationInView:self];
    NSInteger tapIndex = touchPoint.x / (self.frame.size.width / self.numOfMenu);
    
    for (int i = 0; i < _numOfMenu; i++) {
        if (i != tapIndex) {
            [self animateIndicator:_indicators[i] unfold:NO complete:^{
                [self animateTitle:_titles[i] selected:NO complete:nil];
                [(CALayer *)self.menuBgLayers[i] setBackgroundColor:self.menuBackgroundColor.CGColor];
            }];
        }
    }
    
    if (tapIndex == _currentSelectedColumn && _show) {
        //Dismiss filterView.
        [self animateIndicator:_indicators[_currentSelectedColumn] background:_backGroundView filterView:self.filterView title:_titles[_currentSelectedColumn] unfold:NO complecte:^{
            _currentSelectedColumn = tapIndex;
            _show = NO;
            [(CALayer *)self.menuBgLayers[tapIndex] setBackgroundColor:self.menuBackgroundColor.CGColor];
        }];
    
    } else {
        //Change menu title if needed.
        [self.filterView refreshMenuTitleForColumnChanged];
        
        //Switch to another channel.
        _currentSelectedColumn = tapIndex;
        [self animateIndicator:_indicators[tapIndex] background:self.backGroundView filterView:self.filterView title:_titles[tapIndex] unfold:YES complecte:^{
            _show = YES;
            [(CALayer *)self.menuBgLayers[tapIndex] setBackgroundColor:self.menuBackgroundSelectedColor.CGColor];
        }];
        
        if ([self.delegate respondsToSelector:@selector(menu:tapIndex:)]) {
            [self.delegate menu:self tapIndex:tapIndex];
        }
    }
    
    self.filterView.needSearchWithinInputValues = YES;
}

-(void)backgroundTapped:(UITapGestureRecognizer *)paramSender {
    [self.filterView endEditing:YES];
    [self animateIndicator:_indicators[_currentSelectedColumn] background:self.backGroundView filterView:self.filterView title:self.titles[_currentSelectedColumn] unfold:NO complecte:^{
        _show = NO;
        [(CALayer *)self.menuBgLayers[_currentSelectedColumn] setBackgroundColor:self.menuBackgroundColor.CGColor];
        
        [self.filterView refreshMenuTitleForDismiss];
        
        self.filterView.needSearchWithinInputValues = YES;
        
        if (paramSender) {
            [self.filterView submitFilterResultsWithStatisticModel:nil];
        }

    }];
}

#pragma mark - animation method

- (void)animateIndicator:(CAShapeLayer *)indicator background:(UIView *)background filterView:(id)filterView title:(CATextLayer *)title unfold:(BOOL)unfold complecte:(void(^)())complete{
    
    [self animateIndicator:indicator unfold:unfold complete:^{
        [self animateTitle:title selected:unfold complete:^{
            [self animateBackGroundView:background show:unfold complete:^{
                [self animateFilterView:self.filterView show:unfold complete:^{
                    
                }];
            }];
        }];
    }];
    
    if (complete) {
        complete();
    }
}

- (void)animateIndicator:(CAShapeLayer *)indicator unfold:(BOOL)unfold complete:(void(^)())complete {
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.25];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0.0 :0.2 :1.0]];
    
    CAKeyframeAnimation *animate = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    animate.values = unfold ? @[ @0, @(M_PI) ] : @[ @(M_PI), @0 ];

    if (!animate.removedOnCompletion) {
        [indicator addAnimation:animate forKey:animate.keyPath];
    } else {
        [indicator addAnimation:animate forKey:animate.keyPath];
        [indicator setValue:animate.values.lastObject forKeyPath:animate.keyPath];
    }
    
    [CATransaction commit];
    
    if (unfold) {
        indicator.fillColor = self.titleSelectedColor.CGColor;
    } else {
        indicator.fillColor = self.titleColor.CGColor;
    }
    if (complete) {
        complete();
    }
}

- (void)animateTitle:(CATextLayer *)title selected:(BOOL)selected complete:(void(^)())complete {
    CGSize size = [self calculateTitleSizeWithString:title.string];
    CGFloat sizeWidth = (size.width < ((self.frame.size.width / _numOfMenu) - self.menuTitleMargin)) ? size.width : (self.frame.size.width / _numOfMenu - self.menuTitleMargin);
    title.bounds = CGRectMake(0, 0, sizeWidth, size.height);
    if (selected) {
        title.foregroundColor = self.titleSelectedColor.CGColor;
    } else {
        title.foregroundColor = self.titleColor.CGColor;
    }
    if (complete) {
        complete();
    }
}

- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(void(^)())complete {
    if (show) {
        [self.superview addSubview:view];
        [view.superview addSubview:self];
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }
    if (complete) {
        complete();
    }
}

- (void)animateFilterView:(XYXFilterView *)view show:(BOOL)show complete:(void(^)())complete {
    if (show) {
        [self.superview addSubview:view];
        [view.superview addSubview:self];

        [view configUIWith:_currentSelectedColumn showSelectedItem:YES complete:^{
            
            if (_show) {
                view.frame = CGRectMake(0, CGRectGetMinY(view.frame), SCREEN_WIDTH, view.unfoldHeight);
                
            }else{
                view.frame = CGRectMake(0, CGRectGetMinY(view.frame), SCREEN_WIDTH, 0);
                [UIView animateWithDuration:0.25 animations:^{
                    view.frame = CGRectMake(0, CGRectGetMinY(view.frame), SCREEN_WIDTH, view.unfoldHeight);
                } completion:^(BOOL finished) {
                    if (complete) {
                        complete();
                    }
                }];
            }
        }];
    }
    else {
        [UIView animateWithDuration:0.25 animations:^{
            view.frame = CGRectMake(0, CGRectGetMinY(view.frame), SCREEN_WIDTH, 0);
        } completion:^(BOOL finished) {
            [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj removeFromSuperview];
            }];
            [view removeFromSuperview];
            if (complete) {
                complete();
            }
        }];
    }
}

@end
