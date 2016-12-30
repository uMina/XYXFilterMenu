//
//  XYXIndexPath.m
//  XYXFilterMenu
//
//  Created by Teresa on 16/12/5.
//  Copyright © 2016年 Teresa. All rights reserved.
//

#import "XYXIndexPath.h"

@implementation XYXIndexPath

-(instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row item:(NSInteger)item leaf:(NSInteger)leaf{
    self = [super init];
    if (self) {
        _column = column;
        _row = row;
        _item = item;
        _leaf = leaf;
    }
    return self;
}

-(instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row item:(NSInteger)item{
    self = [self initWithColumn:column row:row item:item leaf:-1];
    return self;
}

-(instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row{
    self = [self initWithColumn:column row:row item:-1 leaf:-1];
    return self;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"(column:%ld,row:%ld,item:%ld,leaf:%ld)",self.column,self.row,self.item,self.leaf];
}

+ (instancetype)indexPathWithColumn:(NSInteger)col row:(NSInteger)row{
    XYXIndexPath *indexPath = [[self alloc] initWithColumn:col row:row];
    return indexPath;
}

+ (instancetype)indexPathWithColumn:(NSInteger)col row:(NSInteger)row item:(NSInteger)item{
    XYXIndexPath *indexPath = [[self alloc] initWithColumn:col row:row item:item];
    return indexPath;
}

+ (instancetype)indexPathWithColumn:(NSInteger)col row:(NSInteger)row item:(NSInteger)item leaf:(NSInteger)leaf{
    XYXIndexPath *indexPath = [[self alloc] initWithColumn:col row:row item:item leaf:leaf];
    return indexPath;
}

-(BOOL)isEqual:(id)object{
    if (![object isKindOfClass:[self class]]) {
        return NO;
    }
    XYXIndexPath *newObject = (XYXIndexPath*)object;
    if (newObject.column == self.column &&
        newObject.row == self.row &&
        newObject.item == self.item &&
        newObject.leaf == self.leaf) {
        return YES;
    }else{
        return NO;
    }
}

@end
