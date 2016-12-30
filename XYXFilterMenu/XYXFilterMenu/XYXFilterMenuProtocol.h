//
//  XYXFilterMenuProtocol.h
//  XYXFilterMenu
//
//  Created by Teresa on 16/12/5.
//  Copyright © 2016年 Teresa. All rights reserved.
//

#ifndef XYXFilterMenuProtocol_h
#define XYXFilterMenuProtocol_h

#import "XYXFilterMenuMacro.h"

@class XYXFilterMenu,XYXIndexPath;
@class XYXAnnexViewInputModel,XYXFilterStatisticModel;

//----------------------------------------------------------------------------


@protocol XYXFilterMenuDataSource <NSObject>

@required

- (NSInteger)menu:(XYXFilterMenu *)menu numberOfRowsInColumn:(NSInteger)column;
- (NSString *)menu:(XYXFilterMenu *)menu titleForRowAtIndexPath:(XYXIndexPath *)indexPath;
- (MenuColumnType)menu:(XYXFilterMenu *)menu columnTypeOfColumn:(NSUInteger)column;

@optional

- (NSInteger)numberOfColumnsInMenu:(XYXFilterMenu *)menu;  //Default column number is one.

- (NSString *)menu:(XYXFilterMenu *)menu titleForColumnAtIndexPath:(XYXIndexPath *)indexPath;
- (NSString *)menu:(XYXFilterMenu *)menu titleForItemAtIndexPath:(XYXIndexPath *)indexPath;
- (NSString *)menu:(XYXFilterMenu *)menu titleForLeafAtIndexPath:(XYXIndexPath *)indexPath;
- (NSString *)menu:(XYXFilterMenu *)menu subTitleForCollectionSectionAtIndexPath:(XYXIndexPath *)indexPath;

- (NSInteger)menu:(XYXFilterMenu *)menu numberOfItemsAtIndexPath:(XYXIndexPath*)indexPath;
- (NSInteger)menu:(XYXFilterMenu *)menu numberOfLeafsAtIndexPath:(XYXIndexPath*)indexPath;

- (BOOL)menu:(XYXFilterMenu *)menu allowsMultipleSelectionInCollectionViewAtIndexPath:(XYXIndexPath*)indexPath;
- (CGSize)menu:(XYXFilterMenu *)menu sizeOfCollectionCellAtIndexPath:(XYXIndexPath*)indexPath;

- (CGFloat)menu:(XYXFilterMenu*)menu widthOfTableView:(UITableView*)tableView forColumnType:(MenuColumnType)columnType;

#pragma mark Annex View

-(AnnexType)menu:(XYXFilterMenu *)menu annexTypeOfIndexPath:(XYXIndexPath *)indexPath;  //Type of user-defined view which been placed at the bottom of filter
-(NSString*)menu:(XYXFilterMenu *)menu describeTitleOfAnnexIndexPath:(XYXIndexPath *)indexPath; //Describe of annex view

-(NSString*)menu:(XYXFilterMenu *)menu unitOfAnnexIndexPath:(XYXIndexPath *)indexPath; //Unit describe for refresh Menu title.

@end

//----------------------------------------------------------------------------

@protocol XYXFilterMenuDelegate <NSObject>

- (void)menu:(XYXFilterMenu *)menu didSelectRowAtIndexPath:(XYXIndexPath *)indexPath withTableFilterResult:(NSArray<XYXIndexPath *> *)tableFilterResult collectionFilterResult:(NSArray<XYXIndexPath *> *)collectionFilterResult annexValues:(NSArray<XYXAnnexViewInputModel *>*)annexValues;

- (void)menu:(XYXFilterMenu *)menu filterResultWithTableView:(NSArray<XYXIndexPath*>*)tableFilterResult collectionView:(NSArray<XYXIndexPath*>*)collectionFilterResult annexValues:(NSArray<XYXAnnexViewInputModel *>*)annexValues;

- (void)menu:(XYXFilterMenu *)menu tapIndex:(NSInteger)index;

- (void)menu:(XYXFilterMenu *)menu statisticWithStatisticModel:(XYXFilterStatisticModel*)statisticModel;


@end

#endif /* XYXFilterMenuProtocol_h */
