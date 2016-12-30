//
//  XYXFilterModel.m
//  XYXFilterMenu
//
//  Created by Teresa on 16/12/30.
//  Copyright © 2016年 Teresa. All rights reserved.
//

#import "XYXFilterModel.h"

@implementation XYXAnnexViewInputModel

-(BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    XYXAnnexViewInputModel *newObject = (XYXAnnexViewInputModel*)object;
    if (newObject.minValue == self.minValue &&
        newObject.maxValue == self.maxValue &&
        newObject.indexPath == self.indexPath) {
        return YES;
    }else{
        return NO;
    }
}

-(NSString *)description{
    return [NSString stringWithFormat:@"(%ld,%ld) at %@",self.minValue,self.maxValue,self.indexPath];
}

@end

@implementation XYXFilterStatisticModel

-(void)setTitleForTableView:(NSString *)titleForTableView{
    _titleForTableView = titleForTableView;
    _titlesForCollectionView = @[];
    _prefixForAnnexView = nil;
}
-(void)setTitlesForCollectionView:(NSArray *)titlesForCollectionView{
    _titlesForCollectionView = titlesForCollectionView;
    _titleForTableView = nil;
    _prefixForAnnexView = nil;
}
-(void)setPrefixForAnnexView:(NSString *)prefixForAnnexView{
    _prefixForAnnexView = prefixForAnnexView;
    _titleForTableView = nil;
    _titlesForCollectionView = @[];
}

-(NSString *)description{
    return [NSString stringWithFormat:@"<%@,%lu>:\ntitleForTableView = %@\ntitlesForCollectionView = %@\nprefixForAnnexView = %@",NSStringFromClass(self.class),(unsigned long)self.hash,self.titleForTableView,self.titlesForCollectionView,self.prefixForAnnexView];
}

@end
