//
//  XYXFilterView.h
//  XYXFilterMenu
//
//  Created by Teresa on 16/12/8.
//  Copyright © 2016年 Teresa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYXFilterMenuMacro.h"
#import "XYXFilterMenuProtocol.h"

@class AnnexInputView, AnnexConfirmView;
@class XYXFilterMenu;
@class XYXFilterStatisticModel;

@interface XYXFilterView : UIView<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, assign) CGFloat defaultUnfoldHeight;
@property (nonatomic, assign) CGFloat unfoldHeight;
@property (nonatomic, copy) UITableView *firstTableView;
@property (nonatomic, copy) UITableView *secondTableView;
@property (nonatomic, copy) UITableView *thirdTableView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) AnnexConfirmView *annexConfirmView;
@property (nonatomic, strong) AnnexInputView *annexInputView;

@property (nonatomic, strong) NSMutableArray<XYXIndexPath*> *selectedTableViewIndexPaths;
@property (nonatomic, strong) NSMutableArray<XYXIndexPath*> *selectedCollectionViewIndexPaths;
@property (nonatomic, strong) NSMutableArray <XYXAnnexViewInputModel*>*inputAnnexValues;

@property (nonatomic, assign) BOOL shouldMenuTitleLinkedToCellClick;
@property (nonatomic, assign) BOOL shouldTrimFilterHeightToFit;

@property (nonatomic, weak) XYXFilterMenu *menu;
@property (nonatomic, weak) id <XYXFilterMenuDataSource> dataSource;
@property (nonatomic, weak) id <XYXFilterMenuDelegate> delegate;

@property (nonatomic,assign) MenuColumnType currentColumnType;
@property (nonatomic,assign) BOOL needSearchWithinInputValues;

-(void)configUIWith:(NSUInteger)selectedColumn showSelectedItem:(BOOL)showSelectedItem complete:(void (^)())complete;

-(void)animateHeight:(CGFloat)height withDuration:(NSTimeInterval)duration complete:(void (^)())complete;

-(void)revertCollectionViewData;

-(void)refreshMenuTitleForDismiss;

-(void)refreshMenuTitleForColumnChanged;

-(void)submitFilterResultsWithStatisticModel:(XYXFilterStatisticModel*)statisticModel;

@end

#pragma mark - TableView Cell

@interface XYXFilterTableViewCell : UITableViewCell

+(NSString *)reuseIdentifier;

@end

#pragma mark - CollectionView Cell

@interface XYXFilterCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *textLabel;

+(NSString *)reuseIdentifier;

@end

@interface XYXFilterDefaultHeaderView : UICollectionReusableView

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *subtitleLabel;
@property (strong, nonatomic) UIView *lineView;

+(NSString *)reuseIdentifier;

@end

#pragma mark - AccessoryView

@interface AccessoryView : NSObject

+(UIImageView*)normalAccessoryView;
+(UIImageView*)selectedAccessoryView;

@end
