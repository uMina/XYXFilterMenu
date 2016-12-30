//
//  XYXFilterModel.h
//  XYXFilterMenu
//
//  Created by Teresa on 16/12/30.
//  Copyright © 2016年 Teresa. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XYXIndexPath;

@interface XYXAnnexViewInputModel : NSObject

@property(nonatomic,assign) NSUInteger minValue;
@property(nonatomic,assign) NSUInteger maxValue;
@property(nonatomic,strong) XYXIndexPath *indexPath;

@end

/*
 Among 'titleForTableView', 'titlesForCollectionView', 'prefixForAnnexView', once one of them gets a value, the other two will be nil.
 */

@interface XYXFilterStatisticModel : NSObject

@property(nonatomic,strong) NSString *titleForTableView;
@property(nonatomic,strong) NSArray<NSString*> *titlesForCollectionView;
@property(nonatomic,strong) NSString *prefixForAnnexView;
@property(nonatomic,strong) XYXIndexPath *indexPath;

@end
