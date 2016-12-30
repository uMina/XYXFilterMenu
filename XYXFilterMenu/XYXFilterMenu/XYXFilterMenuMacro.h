//
//  XYXFilterMenuMacro.h
//  XYXFilterMenu
//
//  Created by Teresa on 16/12/8.
//  Copyright © 2016年 Teresa. All rights reserved.
//

#ifndef XYXFilterMenuMacro_h
#define XYXFilterMenuMacro_h

#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#endif
#ifndef SCREEN_HEIGHT
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#endif

#define FILTER_BUNDLE [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"FilterMenuResources" ofType:@"bundle"]]

#pragma mark - Colors

#define ANNEX_BG_COLOR [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]
#define ANNEX_DETAIL_TEXT_COLOR [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1.0]
#define ANNEX_TEXTFIELD_BG_COLOR [UIColor colorWithRed:248.0/255 green:248.0/255 blue:248.0/255 alpha:1.0]
#define ANNEX_CONFIRM_BG_COLOR [UIColor orangeColor]
#define ANNEX_CONFIRM_TEXT_COLOR [UIColor whiteColor]
#define ANNEX_CANCEL_BG_COLOR [UIColor colorWithRed:238.0/255 green:238.0/255 blue:238.0/255 alpha:1.0]
#define ANNEX_CANCEL_TEXT_COLOR [UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1.0]

#define SPEPARATOR_COLOR [UIColor colorWithRed:227.0/255 green:227.0/255 blue:227.0/255 alpha:1.0]

#define COLLECTION_CELL_DEFAULT_COLOR [UIColor whiteColor]
#define COLLECTION_CELL_SELECTED_COLOR [UIColor colorWithRed:59.0/255 green:148.0/255 blue:239.0/255 alpha:1.0]
#define COLLECTION_CELL_TEXT_DEFAULT_COLOR [UIColor colorWithRed:153.0/255 green:153.0/255 blue:153.0/255 alpha:1.0]
#define COLLECTION_CELL_TEXT_SELECTED_COLOR [UIColor whiteColor]

#define TABLEVIEW_CELL_DEFAULT_BG_COLOR [UIColor whiteColor]
#define TABLEVIEW_CELL_SELECTED_BG_COLOR [UIColor whiteColor]
#define TABLEVIEW_CELL_TEXT_DEFAULT_COLOR [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1.0]
#define TABLEVIEW_CELL_TEXT_SELECTED_COLOR [UIColor colorWithRed:59.0/255 green:148.0/255 blue:239.0/255 alpha:1.0]

#define MENU_TITLE_DEFAULT_COLOR [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1.0]  //Dark gray
#define MENU_TITLE_SELECTED_COLOR [UIColor colorWithRed:59.0/255 green:148.0/255 blue:239.0/255 alpha:1.0]  //Bright blue
#define MENU_BG_DEFAULT_COLOR [UIColor whiteColor]
#define MENU_BG_SELECTED_COLOR [UIColor whiteColor]

#pragma mark - Size

#define COLLECTION_CELL_DEFAULT_SIZE CGSizeMake((SCREEN_WIDTH-50)/4, 30)

static const CGFloat TableView_Cell_Height = 43.0;
static const CGFloat TableView_Cell_FontSize = 14.0;
static const CGFloat CollectionView_Cell_FontSize = 14.0;
static const CGFloat Annex_Button_FontSize = 14.0;
static const CGFloat Annex_TextField_FontSize = 14.0;
static const CGFloat Annex_SpaceGap = 10.f;

static const NSUInteger XYXFilterMenuTag = 300;
static const NSUInteger XYXFirstTableViewTag = 301;
static const NSUInteger XYXSecondTableViewTag = 302;
static const NSUInteger XYXThirdTableViewTag = 303;

#pragma mark - Enum

typedef NS_ENUM(NSUInteger,AnnexType){
    AnnexTypeNone,         //No annex view
    AnnexTypeMinMaxInput,  //Input View
    AnnexTypeConfirm       //reset－confirm View
};

typedef NS_ENUM(NSUInteger,MenuTitleTruncationMode) {
    MenuTitleTruncationNone,
    MenuTitleTruncationStart,
    MenuTitleTruncationMiddle,
    MenuTitleTruncationEnd
};

typedef NS_ENUM(NSUInteger,MenuColumnType){
    MenuColumnTypeTableViewOne,
    MenuColumnTypeTableViewTwo,
    MenuColumnTypeTableViewThree,
    MenuColumnTypeCollectionView
};

#endif /* XYXFilterMenuMacro_h */
