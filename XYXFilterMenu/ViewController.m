//
//  ViewController.m
//  XYXFilterMenu
//
//  Created by Teresa on 16/12/5.
//  Copyright © 2016年 Teresa. All rights reserved.
//

#import "ViewController.h"
#import "XYXFilterMenuHeader.h"

@interface ViewController ()<XYXFilterMenuDataSource,XYXFilterMenuDelegate>

@property(nonatomic,copy)NSArray *menuDefaultTitles;

@end

@implementation ViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.menuDefaultTitles = @[@"MenuA",@"MenuB",@"MenuC",@"MenuD"];
    
    XYXFilterMenu *menu = [[XYXFilterMenu alloc]initWithOrigin:CGPointMake(0,64) height:44];
    [self.view addSubview: menu];
    menu.dataSource = self;
    menu.delegate = self;
    menu.shouldMenuTitleLinkedToCellClick = NO;
    menu.shouldTrimFilterHeightToFit = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getter & Setter

#pragma mark - Public

#pragma mark - Private

#pragma mark - DataSource

-(MenuColumnType)menu:(XYXFilterMenu *)menu columnTypeOfColumn:(NSUInteger)column{
    switch (column) {
        case 0:
            return MenuColumnTypeTableViewThree;
        case 1:
            return MenuColumnTypeTableViewTwo;
            break;
        case 2:
            return MenuColumnTypeTableViewOne;
        default:
            return MenuColumnTypeCollectionView;
    }
}

-(NSInteger)numberOfColumnsInMenu:(XYXFilterMenu *)menu{
    return self.menuDefaultTitles.count;
}

-(NSInteger)menu:(XYXFilterMenu *)menu numberOfRowsInColumn:(NSInteger)column{
    if (column == 1) {
        return 3;
    }
    if (column == 3) {
        return 4;
    }
    return 16;
}

-(NSInteger)menu:(XYXFilterMenu *)menu numberOfItemsAtIndexPath:(XYXIndexPath *)indexPath{
    if (indexPath.column == 1 && indexPath.row == 1) {
        return 5;
    }
    if (indexPath.column == 3) {
        return 5;
    }
    return 20;
}

-(NSInteger)menu:(XYXFilterMenu *)menu numberOfLeafsAtIndexPath:(XYXIndexPath *)indexPath{
    return 20;
}

-(NSString *)menu:(XYXFilterMenu *)menu titleForColumnAtIndexPath:(XYXIndexPath *)indexPath{
    return self.menuDefaultTitles[indexPath.column];
}

-(NSString *)menu:(XYXFilterMenu *)menu titleForRowAtIndexPath:(XYXIndexPath *)indexPath{
    NSString *title = nil;
    switch (indexPath.column) {
        case 0:{
            title = [NSString stringWithFormat:@"col_A_row_%ld",indexPath.row];
        }
            break;
        case 1:{
            title = [NSString stringWithFormat:@"col_B_row_%ld",indexPath.row];
        }
            break;
        case 3:{
            switch (indexPath.row) {
                case 0:{
                    title = @"Long Section Title";
                }
                    break;
                case 1:{
                    title = @"Normal Title";
                }
                    break;
                default:{
                    title = @"Short";
                }
                    break;
            }
        }
            break;
        default:{
            title = [NSString stringWithFormat:@"Other_row_%ld",indexPath.row];
        }
            break;
    }
    return title;
}

-(NSString *)menu:(XYXFilterMenu *)menu titleForItemAtIndexPath:(XYXIndexPath *)indexPath{
    NSString *title = nil;
    switch (indexPath.column) {
        case 0:
        case 1:{
            title = [NSString stringWithFormat:@"row_%ld_item_%ld",indexPath.row,indexPath.item];
        }
            break;
        default:{
            if (indexPath.column == 3) {
                title = [NSString stringWithFormat:@"%ld_item_%ld",indexPath.row,indexPath.item];
            }else{
                title = [NSString stringWithFormat:@"Other_item_%ld",indexPath.item];
            }
        }
            break;
    }
    return title;
}

-(NSString *)menu:(XYXFilterMenu *)menu titleForLeafAtIndexPath:(XYXIndexPath *)indexPath{
    NSString *title = [NSString stringWithFormat:@"item_%ld_leaf_%ld",indexPath.item,indexPath.leaf];
    return title;
}
-(NSString *)menu:(XYXFilterMenu *)menu subTitleForCollectionSectionAtIndexPath:(XYXIndexPath *)indexPath{
    NSString *title = nil;
    switch (indexPath.row) {
        case 0:
            title = @"This section could be multiple selected.";
            break;
        case 1:
            title = nil;
            break;
        default:
            title = @"Single Choice";
            break;
    }
    return title;
}

-(CGSize)menu:(XYXFilterMenu *)menu sizeOfCollectionCellAtIndexPath:(XYXIndexPath *)indexPath{
    if (indexPath.row == 0 && indexPath.item == 4) {
        return CGSizeMake(COLLECTION_CELL_DEFAULT_SIZE.width *2 , COLLECTION_CELL_DEFAULT_SIZE.height);
    }
    return COLLECTION_CELL_DEFAULT_SIZE;
}

- (CGFloat)menu:(XYXFilterMenu*)menu widthOfTableView:(UITableView*)tableView forColumnType:(MenuColumnType)columnType{
    CGFloat width = 0.0;
    if (columnType == MenuColumnTypeTableViewTwo) {
        if (tableView.tag == XYXFirstTableViewTag) {
            width = SCREEN_WIDTH/4 +5;
        }else if (tableView.tag == XYXSecondTableViewTag) {
            width = SCREEN_WIDTH/4 *3 -5;
        }
    }
    return width;
}

#pragma mark AnnexView

-(AnnexType)menu:(XYXFilterMenu *)menu annexTypeOfIndexPath:(XYXIndexPath *)indexPath{
    MenuColumnType mc = (MenuColumnType)indexPath.column;
    switch (mc) {
        case 0:{
            return AnnexTypeNone;
        }
        case 1:{
            if (indexPath.row == 0) {
                return AnnexTypeMinMaxInput;
            }else if (indexPath.row == 1) {
                return AnnexTypeNone;
            }else{
                return AnnexTypeMinMaxInput;
            }
        }
        case 2:{
            return AnnexTypeMinMaxInput;
        }
        case 3:{
            return AnnexTypeConfirm;
        }
    }
    return AnnexTypeNone;
}

-(NSString *)menu:(XYXFilterMenu *)menu describeTitleOfAnnexIndexPath:(XYXIndexPath *)indexPath{
    
    NSString *result = nil;
    switch (indexPath.column) {
        case 0:
            result = @"Custom(UA)";
            break;
            
        case 1:
            if (indexPath.row == 0) {
                result = @"Custom(UB)";
            }else{
                result = @"Custom(UC)";
            }
            break;
        
        default:
            result = @"Custom";
            break;
    }
    return result;
}

-(NSString *)menu:(XYXFilterMenu *)menu unitOfAnnexIndexPath:(XYXIndexPath *)indexPath{
    NSString *unitString = nil;
    
    switch (indexPath.column) {
        case 0:{
            unitString = @"UA";
        }
            break;
        case 1:{
            if (indexPath.row == 0) {
                unitString = @"UB";
            }else{
                unitString = @"UC";
            }
        }
            break;
        default:
            unitString = @"kk";
            break;
    }
    return unitString;
}

-(BOOL)menu:(XYXFilterMenu *)menu allowsMultipleSelectionInCollectionViewAtIndexPath:(XYXIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return YES;
    }
    return NO;
}

#pragma mark - Delegate

- (void)menu:(XYXFilterMenu *)menu didSelectRowAtIndexPath:(XYXIndexPath *)indexPath withTableFilterResult:(NSArray<XYXIndexPath *> *)tableFilterResult collectionFilterResult:(NSArray<XYXIndexPath *> *)collectionFilterResult annexValues:(NSArray<XYXAnnexViewInputModel*> *)annexValues{
    if (menu.currentColumnType != MenuColumnTypeCollectionView) {
        return;
    }
    NSLog(@"\nDidSelectRowAtIndexPath With Result: \ntableFilterResult = %@\ncollectionFilterResult = %@\nannexValue = %@",tableFilterResult,collectionFilterResult,annexValues);
    
}

-(void)menu:(XYXFilterMenu *)menu filterResultWithTableView:(NSArray<XYXIndexPath *> *)tableFilterResult collectionView:(NSArray<XYXIndexPath *> *)collectionFilterResult annexValues:(NSArray<XYXAnnexViewInputModel *> *)annexValues{
    
    NSLog(@"\nFilter Result: \ntableFilterResult = %@\ncollectionFilterResult = %@\nannexValue = %@",tableFilterResult,collectionFilterResult,annexValues);
}

-(void)menu:(XYXFilterMenu *)menu tapIndex:(NSInteger)index{
    NSString *stringToStastic = nil;
    switch (index) {
        case 0:
            stringToStastic = @"MenuA";
            break;
        case 1:
            stringToStastic = @"MenuB";
            break;
        case 2:
            stringToStastic = @"MenuC";
            break;
        case 3:
            stringToStastic = @"MenuD";
            break;
        default:
            break;
    }
    
    [self statisticWithString:stringToStastic];
}

-(void)menu:(XYXFilterMenu *)menu statisticWithStatisticModel:(XYXFilterStatisticModel *)statisticModel{
    
    if (!statisticModel) {
        return;
    }
    
//    NSLog(@"statisticModel = %@",statisticModel);
    __block NSString *stringToStatistic = nil;
    if (statisticModel.titleForTableView) {
        if ([statisticModel.titleForTableView isEqualToString:NSLocalizedString(@"TITILE_UNLIMITED", @"不限")]) {
            NSString * prefix = @"";
            MenuColumnType columnType = statisticModel.indexPath.column;
            switch (columnType) {
                case MenuColumnTypeTableViewTwo:{
                    prefix = [NSString stringWithFormat:@"col_B_row_%ld",statisticModel.indexPath.row];
                }
                    break;
                case MenuColumnTypeTableViewThree:{
                    prefix = [NSString stringWithFormat:@"row_%ld_item_%ld",statisticModel.indexPath.row,statisticModel.indexPath.item];
                }
                    break;
                default:
                    break;
            }
            if (prefix.length > 0) {
                stringToStatistic = [NSString stringWithFormat:@"%@%@",prefix,NSLocalizedString(@"TITILE_UNLIMITED", @"不限")];
            }
        }
        else{
            stringToStatistic = statisticModel.titleForTableView;
        }
        
    }
    else if (statisticModel.titlesForCollectionView.count) {
        [statisticModel.titlesForCollectionView enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self statisticWithString:obj];
        }];
        return;
    }
    else if (statisticModel.prefixForAnnexView) {
        
        switch (statisticModel.indexPath.column) {
            case 1:{
                if (statisticModel.indexPath.row == 0) {
                    NSString * prefix = [NSString stringWithFormat:@"col_B_row_%ld",statisticModel.indexPath.row];
                    stringToStatistic = [NSString stringWithFormat:@"%@ %@",prefix,NSLocalizedString(@"TITILE_USERDEFINE", @"自定义")];
                }else if(statisticModel.indexPath.row == 1){
                    NSString * prefix = [NSString stringWithFormat:@"row_%ld_item_%ld",statisticModel.indexPath.row,statisticModel.indexPath.item];
                    stringToStatistic = [NSString stringWithFormat:@"%@ %@",prefix,NSLocalizedString(@"TITILE_USERDEFINE", @"自定义")];
                }
            }
                break;
            case 2:{
                stringToStatistic = [NSString stringWithFormat:@"MenuC %@",NSLocalizedString(@"TITILE_USERDEFINE", @"自定义")];
                
            }
                break;
            default:
                break;
        }
    }
    [self statisticWithString:stringToStatistic];
}

-(void)statisticWithString:(NSString*)string{
    if (string.length) {
        NSLog(@"stringToStastic = %@.",string);
    }else{
        NSLog(@"Attention: Null String.");
    }
}

@end
