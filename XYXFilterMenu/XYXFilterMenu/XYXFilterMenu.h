//
//  XYXFilterMenu.h
//  XYXFilterMenu
//
//  Created by Teresa on 16/12/5.
//  Copyright © 2016年 Teresa. All rights reserved.
//

/*
 *  TableView type column always been single choice. 
 *  CollectionView type column could either be single or multiple choice.
 */

#import <UIKit/UIKit.h>
#import "XYXFilterMenuProtocol.h"
#import "XYXFilterMenuMacro.h"

@interface XYXFilterMenu : UIView

@property (nonatomic, weak) id <XYXFilterMenuDataSource> dataSource;
@property (nonatomic, weak) id <XYXFilterMenuDelegate> delegate;

@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *titleSelectedColor;
@property (nonatomic, strong) UIColor *menuBackgroundColor;
@property (nonatomic, strong) UIColor *menuBackgroundSelectedColor;
@property (nonatomic, strong) UIColor *separatorColor;

@property (nonatomic, assign) CGFloat menuTitleMargin;
@property (nonatomic, assign) CGFloat menuTitleFontSize;
@property (nonatomic, assign) CGFloat graySpace;
@property (nonatomic, assign) MenuTitleTruncationMode menuTitleTruncation;

@property (nonatomic, assign, readonly)MenuColumnType currentColumnType;

@property (nonatomic, assign) BOOL shouldMenuTitleLinkedToCellClick;
/*  Value to confirm filterView's height. Default will be NO.
 *  If NO, filterView's height will make sure the gray space's height is what you set.
 *  If YES,filterView's height might be trimmed for less tableView's data. And the gray space's height might bigger than your set.
 */
@property (nonatomic, assign) BOOL shouldTrimFilterHeightToFit;

-(instancetype)initWithOrigin:(CGPoint)origin height:(CGFloat)height;

-(void)refreshMenuWithTitle:(NSString*)title atColum:(NSUInteger)column andFoldFilterView:(BOOL)shouldFold;

-(void)dismissFilterView;

@end
