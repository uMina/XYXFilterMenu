//
//  XYXIndexPath.h
//  XYXFilterMenu
//
//  Created by Teresa on 16/12/5.
//  Copyright © 2016年 Teresa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XYXIndexPath : NSObject

@property (nonatomic, assign) NSInteger column;
@property (nonatomic, assign) NSInteger row;
@property (nonatomic, assign) NSInteger item;
@property (nonatomic, assign) NSInteger leaf;

-(instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row;
-(instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row item:(NSInteger)item;
-(instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row item:(NSInteger)item leaf:(NSInteger)leaf;

+ (instancetype)indexPathWithColumn:(NSInteger)col row:(NSInteger)row;
+ (instancetype)indexPathWithColumn:(NSInteger)col row:(NSInteger)row item:(NSInteger)item;
+ (instancetype)indexPathWithColumn:(NSInteger)col row:(NSInteger)row item:(NSInteger)item leaf:(NSInteger)leaf;

@end
