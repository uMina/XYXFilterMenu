//
//  XYXFilterView.m
//  XYXFilterMenu
//
//  Created by Teresa on 16/12/8.
//  Copyright © 2016年 Teresa. All rights reserved.
//

#import "XYXFilterView.h"
#import "XYXFilterMenu.h"
#import "XYXIndexPath.h"
#import "XYXFilterModel.h"
#import "XYXAnnexView.h"

@interface XYXFilterView()

@property (nonatomic,strong) UIView *currentAnnexView;
@property (nonatomic,assign) NSInteger currentSelectedColumn;
@property (nonatomic,assign) CGFloat detalHeightForKeyboard;

@end

@implementation XYXFilterView

-(instancetype)init{
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
        self.needSearchWithinInputValues = NO;
    }
    return self;
}

#pragma mark - Getter & Setter

-(UITableView *)firstTableView{
    if (!_firstTableView) {
        _firstTableView = [self createTableView];
        _firstTableView.tag = XYXFirstTableViewTag;
    }
    return _firstTableView;
}

-(UITableView *)secondTableView{
    if (!_secondTableView) {
        _secondTableView = [self createTableView];
        _secondTableView.tag = XYXSecondTableViewTag;
    }
    return _secondTableView;
}

-(UITableView *)thirdTableView{
    if (!_thirdTableView) {
        _thirdTableView = [self createTableView];
        _thirdTableView.tag = XYXThirdTableViewTag;
    }
    return _thirdTableView;
}

-(UITableView*)createTableView{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    tableView.rowHeight = TableView_Cell_Height;
    tableView.separatorColor = SPEPARATOR_COLOR;
    tableView.separatorInset = UIEdgeInsetsZero;
    tableView.backgroundColor = TABLEVIEW_CELL_DEFAULT_BG_COLOR;
    tableView.tableFooterView = [[UIView alloc]init];
    tableView.dataSource = self;
    tableView.delegate = self;
    return tableView;
}

-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = COLLECTION_CELL_DEFAULT_COLOR;
        _collectionView.allowsMultipleSelection = YES;
        
        [_collectionView registerClass:[XYXFilterCollectionViewCell class] forCellWithReuseIdentifier:[XYXFilterCollectionViewCell reuseIdentifier]];
        [_collectionView registerClass:[XYXFilterDefaultHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[XYXFilterDefaultHeaderView reuseIdentifier]];
    }
    return _collectionView;
}

-(AnnexInputView *)annexInputView{
    if (!_annexInputView) {
        _annexInputView = [[AnnexInputView alloc]init];
        
        __block typeof(_annexInputView) weakAnnexView = _annexInputView;
        __block typeof(self) weakSelf = self;
        _annexInputView.confirmBtnClicked = ^(){
    
            if (weakAnnexView.minField.text.integerValue == 0 && weakAnnexView.maxField.text.integerValue == 0) {
                return ;
            }
            if (weakAnnexView.minField.text.integerValue >0 && weakAnnexView.maxField.text.integerValue > 0 && weakAnnexView.minField.text.integerValue > weakAnnexView.maxField.text.integerValue) {
                return;
            }
            //create input model
            XYXAnnexViewInputModel *model = [XYXAnnexViewInputModel new];
            model.minValue = weakAnnexView.minField.text.integerValue;
            model.maxValue = weakAnnexView.maxField.text.integerValue == 0 ? NSUIntegerMax : weakAnnexView.maxField.text.integerValue;
          
            NSInteger row;
            if (weakSelf.currentColumnType == MenuColumnTypeCollectionView) {
                row = 0;
            }else{
                row =  [weakSelf selectedTableViewIndexPathOfColumn:self.currentSelectedColumn].row;
            }
            model.indexPath = [XYXIndexPath indexPathWithColumn:weakSelf.currentSelectedColumn row:row item:0 leaf:0];
            
            //deal with model to store in 'inputAnnexValues'
            __block XYXAnnexViewInputModel *oldToRemove = nil;
            [weakSelf.inputAnnexValues enumerateObjectsUsingBlock:^(XYXAnnexViewInputModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (model.indexPath.column == obj.indexPath.column) {
                    oldToRemove = obj;
                    *stop = YES;
                }
            }];
            if (oldToRemove) {
                [weakSelf.inputAnnexValues removeObject:oldToRemove];
            }
            [weakSelf.inputAnnexValues addObject:model];
            
            //remove data in the 'selectedTableViewIndexPaths' or 'selectedCollectionViewIndexPaths' for the same indexPath
            [weakSelf removeSelectedDataAtcolumn:weakSelf.currentSelectedColumn];
            
            //response to viewcontroller
            XYXFilterStatisticModel *statisticModel = [XYXFilterStatisticModel new];
            XYXIndexPath *currentSelectedIndexPath = [weakSelf selectedIndexPathOfColumn:weakSelf.currentSelectedColumn isNullable:NO];
            statisticModel.indexPath = currentSelectedIndexPath;
            statisticModel.prefixForAnnexView = NSLocalizedString(@"TITILE_USERDEFINE", @"自定义");
            [weakSelf submitFilterResultsWithStatisticModel:statisticModel];

            //refresh menu title
            NSString *newTitle = [weakSelf newMenuTitleForAnnexInput:model];
            [weakSelf.menu refreshMenuWithTitle:newTitle atColum:model.indexPath.column andFoldFilterView:YES];
            
            //close filter view
            [weakSelf.menu dismissFilterView];
        };
    }
    return _annexInputView;
}

-(AnnexConfirmView *)annexConfirmView{
    if (!_annexConfirmView) {
        _annexConfirmView = [[AnnexConfirmView alloc]init];
        __block typeof(self) weakSelf = self;
        _annexConfirmView.confirmBtnClicked = ^(){
            [weakSelf.menu dismissFilterView];
            
            if (self.currentColumnType == MenuColumnTypeCollectionView) {
                
                [weakSelf refreshMenuTitleForDismiss];
                
                XYXFilterStatisticModel *statisticModel = [XYXFilterStatisticModel new];
                NSMutableArray *titles = [NSMutableArray array];
                if ([weakSelf.dataSource respondsToSelector:@selector(menu:titleForItemAtIndexPath:)]) {
                    [weakSelf.selectedCollectionViewIndexPaths enumerateObjectsUsingBlock:^(XYXIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        [titles addObject:[weakSelf.dataSource menu:weakSelf.menu titleForItemAtIndexPath:obj]];
                    }];
                }
                XYXIndexPath *currentSelectedIndexPath = [weakSelf selectedIndexPathOfColumn:weakSelf.currentSelectedColumn isNullable:NO];
                statisticModel.titlesForCollectionView = titles;
                statisticModel.indexPath = currentSelectedIndexPath;
                
                [weakSelf submitFilterResultsWithStatisticModel:statisticModel];
                
            }else{
                [weakSelf assertWith: @"AnnexConfirmView only compared for CollectionView"];
            }
            
        };
        _annexConfirmView.cancelBtnClicked = ^(){
            [weakSelf revertCollectionViewData];
            [weakSelf submitToStatisticWithClickIndexPath:nil];
        };
    }
    return _annexConfirmView;
}

-(void)setDefaultUnfoldHeight:(CGFloat)defaultUnfoldHeight{
    _defaultUnfoldHeight = defaultUnfoldHeight;
    _unfoldHeight = defaultUnfoldHeight;
}

-(NSMutableArray<XYXIndexPath *> *)selectedTableViewIndexPaths{
    if (!_selectedTableViewIndexPaths) {
        _selectedTableViewIndexPaths = [NSMutableArray array];
    }
    return _selectedTableViewIndexPaths;
}

-(NSMutableArray<XYXIndexPath *> *)selectedCollectionViewIndexPaths{
    if (!_selectedCollectionViewIndexPaths) {
        _selectedCollectionViewIndexPaths = [NSMutableArray array];
    }
    return _selectedCollectionViewIndexPaths;
}

-(NSMutableArray<XYXAnnexViewInputModel *> *)inputAnnexValues{
    if (!_inputAnnexValues) {
        _inputAnnexValues = [NSMutableArray array];
    }
    return _inputAnnexValues;
}

#pragma mark - Private

-(CGFloat)heightOfAnnexViewWithType:(AnnexType)annexType annexDescribe:(NSString *)annexDescribe{
    CGFloat annexViewHeight = 0;
    switch (annexType) {
        case AnnexTypeNone:{
            annexViewHeight = 0;
            self.currentAnnexView = nil;
        }
            break;
        case AnnexTypeMinMaxInput:{
            annexViewHeight = CGRectGetHeight(self.annexInputView.frame);
            self.annexInputView.describeLabel.text = annexDescribe;
            self.currentAnnexView = self.annexInputView;
        }
            break;
        case AnnexTypeConfirm:{
            annexViewHeight = CGRectGetHeight(self.annexConfirmView.frame);
            self.currentAnnexView = self.annexConfirmView;
        }
            break;
    }

    return annexViewHeight;
}

-(CGFloat)maxHeightOfTableViewsAtIndex:(XYXIndexPath*)indexPath andColumnType:(MenuColumnType)columnType{
    NSUInteger rowNum = 0,itemNum = 0,leafNum = 0;
    switch (columnType) {
        case MenuColumnTypeTableViewOne:{
            if ([_dataSource respondsToSelector:@selector(menu:numberOfRowsInColumn:)]) {
                rowNum = [_dataSource menu:self.menu numberOfRowsInColumn:indexPath.column];
            }
        }
            break;
        case MenuColumnTypeTableViewTwo:{
            if ([_dataSource respondsToSelector:@selector(menu:numberOfRowsInColumn:)]) {
                rowNum = [_dataSource menu:self.menu numberOfRowsInColumn:indexPath.column];
            }
            if ([_dataSource respondsToSelector:@selector(menu:numberOfItemsAtIndexPath:)]) {
                itemNum = [_dataSource menu:self.menu numberOfItemsAtIndexPath:indexPath];
            }
        }
            break;
        case MenuColumnTypeTableViewThree:{
            
            if ([_dataSource respondsToSelector:@selector(menu:numberOfRowsInColumn:)]) {
                rowNum = [_dataSource menu:self.menu numberOfRowsInColumn:indexPath.column];
            }
            if ([_dataSource respondsToSelector:@selector(menu:numberOfItemsAtIndexPath:)]) {
                itemNum = [_dataSource menu:self.menu numberOfItemsAtIndexPath:indexPath];
            }
            if ([_dataSource respondsToSelector:@selector(menu:numberOfLeafsAtIndexPath:)]) {
                leafNum = [_dataSource menu:self.menu numberOfLeafsAtIndexPath:indexPath];
            }
        }
            break;
        default:
            break;
    }
    NSUInteger maxNum = MAX(rowNum, MAX(itemNum, leafNum));
    return maxNum * TableView_Cell_Height;
}

-(void)resetViewHeightWith:(MenuColumnType)columnType andAnnexViewHeight:(CGFloat)annexViewHeight{
    if(columnType == MenuColumnTypeCollectionView){
        self.unfoldHeight = self.defaultUnfoldHeight;
    }else{
        if (self.shouldTrimFilterHeightToFit) {
            XYXIndexPath *idxPath = [self selectedIndexPathOfColumn:self.currentSelectedColumn isNullable:NO];
            self.unfoldHeight = MIN(self.defaultUnfoldHeight, [self maxHeightOfTableViewsAtIndex:idxPath andColumnType:columnType]+annexViewHeight);
        }else{
            self.unfoldHeight = self.defaultUnfoldHeight;
        }
    }
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), self.unfoldHeight);
}

-(XYXIndexPath*)selectedIndexPathOfColumn:(NSUInteger)column isNullable:(BOOL)isNullable{
    
    XYXIndexPath *resultIndexPath = nil;
    
    // Search data in normal way
    if (self.currentColumnType != MenuColumnTypeCollectionView) {
        resultIndexPath = [self selectedTableViewIndexPathOfColumn:column];
    }else{
        //Just for filterView height calculation.
        resultIndexPath = [XYXIndexPath indexPathWithColumn:column row:0 item:0];
    }
    
    // Search data in 'annexInputValues' if it's needed.
    __block XYXAnnexViewInputModel *model = nil;
    if (self.needSearchWithinInputValues == YES && [self annexInputValueExistAtIndexPath:[XYXIndexPath indexPathWithColumn:self.currentSelectedColumn row:0]]) {
        [self.inputAnnexValues enumerateObjectsUsingBlock:^(XYXAnnexViewInputModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.indexPath.column == column){
                model = obj;
                *stop = YES;
            }
        }];
    }
    if (model) {
        resultIndexPath = model.indexPath;
    }
    
    //  Create new default XYXIndexPath
    if (isNullable == NO && resultIndexPath == nil) {
        switch (self.currentColumnType) {
            case MenuColumnTypeTableViewOne:{
                resultIndexPath = [XYXIndexPath indexPathWithColumn:column row:0];
            }
                break;
            case MenuColumnTypeTableViewTwo:{
                resultIndexPath = [XYXIndexPath indexPathWithColumn:column row:0 item:0];
            }
                break;
            case MenuColumnTypeTableViewThree:{
                resultIndexPath = [XYXIndexPath indexPathWithColumn:column row:0 item:0 leaf:0];
            }
                break;
            case MenuColumnTypeCollectionView:
            {
                //resultIndexPath = [XYXIndexPath indexPathWithColumn:column row:0 item:0];
            }
                break;
        }
    }
    return resultIndexPath;
}

-(NSArray<XYXIndexPath*>*)selectedColletionViewIndexPathAtIndexPath:(XYXIndexPath*)indexPath {
    NSMutableArray *result = [NSMutableArray array];
    [self.selectedCollectionViewIndexPaths enumerateObjectsUsingBlock:^(XYXIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (indexPath.column == obj.column &&
            indexPath.row == obj.row) {
            [result addObject:obj];
        }
    }];
    return result;
}

-(XYXIndexPath*)selectedTableViewIndexPathOfColumn:(NSUInteger)column {
    __block XYXIndexPath *resultIndexPath = nil;
    [self.selectedTableViewIndexPaths enumerateObjectsUsingBlock:^(XYXIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.column == column) {
            resultIndexPath = obj;
            *stop = YES;
        }
    }];
    return resultIndexPath;
}

/// Focus on column. Don't care about row, item, leaf at all.
-(BOOL)annexInputValueExistAtIndexPath:(XYXIndexPath*)indexPath{
    __block BOOL isExist = NO;
    [self.inputAnnexValues enumerateObjectsUsingBlock:^(XYXAnnexViewInputModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.indexPath.column == indexPath.column) {
            isExist = YES;
        }
    }];
    return isExist;
}

-(void)refreshTableView:(UITableView*)tableView{
    if (tableView == self.firstTableView) {
        if (self.secondTableView.superview) {
            self.secondTableView.contentOffset = CGPointMake(0, 0);
        }
        if (self.thirdTableView.superview) {
            self.thirdTableView.contentOffset = CGPointMake(0, 0);
        }
    }else if (tableView == self.secondTableView) {
        if (self.thirdTableView.superview) {
            self.thirdTableView.contentOffset = CGPointMake(0, 0);
        }
    }
    
    switch (self.currentColumnType) {
        
        case MenuColumnTypeTableViewTwo:{
            if (tableView != self.secondTableView) {
                [self configUIWith:self.currentSelectedColumn showSelectedItem:NO complete:nil];
            }
        }
            break;
        case MenuColumnTypeTableViewThree:{
            if (tableView != self.thirdTableView) {
                [self configUIWith:self.currentSelectedColumn showSelectedItem:NO complete:nil];
            }
        }
            break;
        default:
            break;
    }
    
}

-(void)configUIWith:(MenuColumnType)columnType annexType:(AnnexType)annexType annexDescribe:(NSString *)annexDescribe complete:(void (^)())complete{
    
    CGFloat annexViewHeight = [self heightOfAnnexViewWithType:annexType annexDescribe:annexDescribe];
    [self resetViewHeightWith:columnType andAnnexViewHeight:annexViewHeight];
    
    CGFloat filterHeight = self.unfoldHeight - annexViewHeight;
    switch (columnType) {
        case MenuColumnTypeTableViewOne:{
            self.firstTableView.frame = CGRectMake(0, 0, SCREEN_WIDTH, filterHeight);
            [self addSubview:self.firstTableView];
            [self.firstTableView reloadData];
        }
            break;
        case MenuColumnTypeTableViewTwo:{
            CGFloat firstTableViewWidth = SCREEN_WIDTH/2;
            CGFloat secondTableViewWidth = SCREEN_WIDTH/2;
            
            if ([_dataSource respondsToSelector:@selector(menu:widthOfTableView:forColumnType:)]) {
                CGFloat widthA = [_dataSource menu:self.menu widthOfTableView:self.firstTableView forColumnType:MenuColumnTypeTableViewTwo];
                CGFloat widthB = [_dataSource menu:self.menu widthOfTableView:self.secondTableView forColumnType:MenuColumnTypeTableViewTwo];
                
                firstTableViewWidth = widthA ? widthA : firstTableViewWidth;
                secondTableViewWidth = widthB ? widthB : secondTableViewWidth;
            }
            
            self.firstTableView.frame = CGRectMake(0, 0, firstTableViewWidth, filterHeight);
            self.secondTableView.frame = CGRectMake(CGRectGetMaxX(self.firstTableView.frame), 0, secondTableViewWidth, filterHeight);
            [self addSubview:self.firstTableView];
            [self addSubview:self.secondTableView];
            
            [self.secondTableView reloadData];
            [self.firstTableView reloadData];
        }
            break;
        case MenuColumnTypeTableViewThree:{
            
            CGFloat firstTableViewWidth = SCREEN_WIDTH/3;
            CGFloat secondTableViewWidth = SCREEN_WIDTH/3;
            CGFloat thirdTableViewWidth = SCREEN_WIDTH/3;
            
            if ([_dataSource respondsToSelector:@selector(menu:widthOfTableView:forColumnType:)]) {
                CGFloat widthA = [_dataSource menu:self.menu widthOfTableView:self.firstTableView forColumnType:MenuColumnTypeTableViewThree];
                CGFloat widthB = [_dataSource menu:self.menu widthOfTableView:self.secondTableView forColumnType:MenuColumnTypeTableViewThree];
                CGFloat widthC = [_dataSource menu:self.menu widthOfTableView:self.thirdTableView forColumnType:MenuColumnTypeTableViewThree];
                
                firstTableViewWidth = widthA ? widthA : firstTableViewWidth;
                secondTableViewWidth = widthB ? widthB : secondTableViewWidth;
                thirdTableViewWidth = widthC ? widthC : thirdTableViewWidth;
            }
            
            self.firstTableView.frame = CGRectMake(0, 0, firstTableViewWidth, filterHeight);
            self.secondTableView.frame = CGRectMake(CGRectGetMaxX(self.firstTableView.frame), 0, secondTableViewWidth, filterHeight);
            self.thirdTableView.frame = CGRectMake(CGRectGetMaxX(self.secondTableView.frame), 0, thirdTableViewWidth, filterHeight);
            [self addSubview:self.firstTableView];
            [self addSubview:self.secondTableView];
            [self addSubview:self.thirdTableView];
            
            [self.thirdTableView reloadData];
            [self.secondTableView reloadData];
            [self.firstTableView reloadData];
        }
            break;
            
        case MenuColumnTypeCollectionView:{
            self.collectionView.frame = CGRectMake(0, 0, SCREEN_WIDTH, filterHeight);
            [self addSubview:self.collectionView];
            [self.collectionView reloadData];
        }
            break;
    }
    
    if (self.currentAnnexView) {
        
        self.currentAnnexView.frame = CGRectMake(0, self.unfoldHeight - CGRectGetHeight(self.currentAnnexView.frame), SCREEN_WIDTH, annexViewHeight);
        
        if ([self.currentAnnexView isEqual:self.annexInputView]) {
            XYXIndexPath *currentSelectedIndexPath = [self selectedIndexPathOfColumn:self.currentSelectedColumn isNullable:NO];
            __block XYXAnnexViewInputModel *model = nil;
            if ([self annexInputValueExistAtIndexPath:[XYXIndexPath indexPathWithColumn:self.currentSelectedColumn row:0]]) {
                [self.inputAnnexValues enumerateObjectsUsingBlock:^(XYXAnnexViewInputModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (obj.indexPath.column == currentSelectedIndexPath.column &&
                        obj.indexPath.row == currentSelectedIndexPath.row) {
                        model = obj;
                        *stop = YES;
                    }
                }];
            }
            if (model) {
                self.annexInputView.minField.text = model.minValue == 0 ? nil : [NSString stringWithFormat:@"%ld",model.minValue];
                self.annexInputView.maxField.text = model.maxValue == NSUIntegerMax ? nil :[NSString stringWithFormat:@"%ld",model.maxValue];

            }else{
                self.annexInputView.minField.text = nil;
                self.annexInputView.maxField.text = nil;
            }
            
        }
        [self addSubview:self.currentAnnexView];
    }
    
    if (complete) {
        complete();
    }
}

-(XYXIndexPath*)refreshSelectedIndexPathOfTableView:(UITableView*)tableView atIndexPath:(NSIndexPath *)indexPath{
    XYXIndexPath *currentSelectedIndexPath = [self selectedTableViewIndexPathOfColumn:self.currentSelectedColumn];
    
    if (currentSelectedIndexPath == nil) {
        switch (self.currentColumnType) {
            case MenuColumnTypeTableViewOne:{
                currentSelectedIndexPath = [XYXIndexPath indexPathWithColumn:self.currentSelectedColumn row:indexPath.row];
            }
                break;
            case MenuColumnTypeTableViewTwo:{
                if (tableView == self.firstTableView) {
                    currentSelectedIndexPath = [XYXIndexPath indexPathWithColumn:self.currentSelectedColumn row:indexPath.row item:0];
                    
                }else if(tableView == self.secondTableView){
                    currentSelectedIndexPath = [XYXIndexPath indexPathWithColumn:self.currentSelectedColumn row:0 item:indexPath.row];
                }
            }
                break;
            case MenuColumnTypeTableViewThree:{
                if (tableView == self.firstTableView) {
                    currentSelectedIndexPath = [XYXIndexPath indexPathWithColumn:self.currentSelectedColumn row:indexPath.row item:0 leaf:0];
                    
                }else if(tableView == self.secondTableView){
                    currentSelectedIndexPath = [XYXIndexPath indexPathWithColumn:self.currentSelectedColumn row:0 item:indexPath.row leaf:0];
                    
                }else if(tableView == self.thirdTableView){
                    currentSelectedIndexPath = [XYXIndexPath indexPathWithColumn:self.currentSelectedColumn row:0 item:0 leaf:indexPath.row];
                }
            }
                break;
            default:
                break;
        }
        if (currentSelectedIndexPath) {
            [self.selectedTableViewIndexPaths addObject:currentSelectedIndexPath];
        }
        
    }
    else{
        if (tableView == self.firstTableView) {
            currentSelectedIndexPath.row = indexPath.row;
            
            if (self.secondTableView.superview) {
                currentSelectedIndexPath.item = 0;
            }
            if (self.thirdTableView.superview) {
                currentSelectedIndexPath.leaf = 0;
            }
            
        }else if(tableView == self.secondTableView){
            currentSelectedIndexPath.item = indexPath.row;
            if (self.thirdTableView.superview) {
                currentSelectedIndexPath.leaf = 0;
            }
            
        }else if(tableView == self.thirdTableView){
            currentSelectedIndexPath.leaf = indexPath.row;
        }
    }
    return currentSelectedIndexPath;
}

-(BOOL)refreshMenuTitleWith:(UITableView*)tableView atIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *title = cell.textLabel.text;
    
    BOOL shouldSubmitResult = NO;
    if (self.shouldMenuTitleLinkedToCellClick) {
        [self.menu refreshMenuWithTitle:title atColum:self.currentSelectedColumn andFoldFilterView:YES];
    }else{
        switch (self.currentColumnType) {
            case MenuColumnTypeTableViewOne:{
                [self.menu refreshMenuWithTitle:title atColum:self.currentSelectedColumn andFoldFilterView:YES];
                shouldSubmitResult = YES;
            }
                break;
            case MenuColumnTypeTableViewTwo:{
                if (tableView == self.secondTableView) {
                    [self.menu refreshMenuWithTitle:title atColum:self.currentSelectedColumn andFoldFilterView:YES];
                    shouldSubmitResult = YES;
                }
            }
                break;
            case MenuColumnTypeTableViewThree:{
                if (tableView == self.thirdTableView) {
                    [self.menu refreshMenuWithTitle:title atColum:self.currentSelectedColumn andFoldFilterView:YES];
                    shouldSubmitResult = YES;
                }
            }
                break;
            default:
                break;
        }
    }
    
    return shouldSubmitResult;
}

-(NSString *)newMenuTitleForAnnexInput:(XYXAnnexViewInputModel*)inputModel{
    NSString *title,*unitString = nil;
    if ([_dataSource respondsToSelector:@selector(menu:unitOfAnnexIndexPath:)]) {
        unitString = [_dataSource menu:self.menu unitOfAnnexIndexPath:inputModel.indexPath];
    }
    if (inputModel.minValue == 0) {
        title = [NSString stringWithFormat:@"%ld%@%@",inputModel.maxValue,unitString,NSLocalizedStringFromTableInBundle(@"ANNEX_TEXT_LESS", @"Root", FILTER_BUNDLE, @"以下")];
    }else if (inputModel.maxValue == NSUIntegerMax) {
        title = [NSString stringWithFormat:@"%ld%@%@",inputModel.minValue,unitString,NSLocalizedStringFromTableInBundle(@"ANNEX_TEXT_ABOVE", @"Root", FILTER_BUNDLE, @"以上")];
    }else{
        title = [NSString stringWithFormat:@"%ld-%ld%@",inputModel.minValue,inputModel.maxValue,unitString];
    }
    return title;
}

-(void)revertCollectionViewData{
    if (self.currentColumnType == MenuColumnTypeCollectionView) {
        [self.selectedCollectionViewIndexPaths removeAllObjects];
        if (self.collectionView.superview) {
            [self.collectionView reloadData];
        }
    }
}

-(void)refreshMenuTitleForDismiss{
    
    /*
    NSInteger numOfMenu = 1;
    if ([_dataSource respondsToSelector:@selector(numberOfColumnsInMenu:)]) {
        numOfMenu = [_dataSource numberOfColumnsInMenu:self.menu];
    }
    for (int columnIndex = 0; columnIndex < numOfMenu; columnIndex++) {
        NSString *title = nil;
        MenuColumnType columnType = [_dataSource menu:self.menu columnTypeOfColumn:columnIndex];
        if (columnType == MenuColumnTypeCollectionView) {
            
            title = [self menuTitleForCollectionViewAtColumn:columnIndex];
        }
        else{
            title = [self menuTitleForTableViewAtColumn:columnIndex];
        }
        [self.menu refreshMenuWithTitle:title atColum:columnIndex andFoldFilterView:YES];
    }
     */
    NSString *title = nil;
    MenuColumnType columnType = [_dataSource menu:self.menu columnTypeOfColumn:self.currentSelectedColumn];
    if (columnType == MenuColumnTypeCollectionView) {
        title = [self menuTitleForCollectionViewAtColumn:self.currentSelectedColumn];
    }
    else{
        title = [self menuTitleForTableViewAtColumn:self.currentSelectedColumn];
    }
    if (title.length) {
        [self.menu refreshMenuWithTitle:title atColum:self.currentSelectedColumn andFoldFilterView:YES];
    }
    
}

-(void)refreshMenuTitleForColumnChanged{
    if (!self.superview) {
        return;
    }
    NSString *title = nil;
    if (self.currentColumnType == MenuColumnTypeCollectionView) {
        title = [self menuTitleForCollectionViewAtColumn:self.currentSelectedColumn];
    }
    else{
        title = [self menuTitleForTableViewAtColumn:self.currentSelectedColumn];
    }
    if (title.length) {
        [self.menu refreshMenuWithTitle:title atColum:self.currentSelectedColumn andFoldFilterView:NO];
    }
}

-(void)removeSelectedDataAtcolumn:(NSUInteger)column{

    if (self.currentColumnType == MenuColumnTypeCollectionView) {
        NSMutableArray *arrToRemove = [NSMutableArray array];
        [self.selectedCollectionViewIndexPaths enumerateObjectsUsingBlock:^(XYXIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.column == column) {
                [arrToRemove addObject:obj];
            }
        }];
        if (arrToRemove.count) {
            [self.selectedCollectionViewIndexPaths removeObjectsInArray:arrToRemove];
        }

    }else{
        NSMutableArray *arrToRemove = [NSMutableArray array];
        [self.selectedTableViewIndexPaths enumerateObjectsUsingBlock:^(XYXIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.column == column) {
                [arrToRemove addObject:obj];
                *stop = YES;
            }
        }];
        if (arrToRemove.count) {
            [self.selectedTableViewIndexPaths removeObjectsInArray:arrToRemove];
        }
    }
}

-(void)assertWith:(NSString*)string{
    NSAssert(NO, string);
}

#pragma mark Menu Title

-(NSString*)menuTitleForCollectionViewAtColumn:(NSInteger)column{
    NSString *title = nil;
    if (self.selectedCollectionViewIndexPaths.count) {
        title = NSLocalizedStringFromTableInBundle(@"COLLECTION_TITLE_MORE", @"Root", FILTER_BUNDLE, @"更多");
    }else{
        XYXIndexPath *indexPath = [XYXIndexPath indexPathWithColumn:column row:0];
        
        if ([_dataSource respondsToSelector:@selector(menu:titleForColumnAtIndexPath:)]) {
            title = [self.dataSource menu:self.menu titleForColumnAtIndexPath:indexPath];
        }else{
            title = [_dataSource menu:self.menu titleForRowAtIndexPath:indexPath];
        }
    }
    return title;
}

-(NSString*)menuTitleForTableViewAtColumn:(NSInteger)column{
    
    /*
     Search in 'inputAnnexValues' first. Then check in 'selectedTableViewIndexPaths', determine to delete needless value.
     */
    __block NSString *title = nil;
    [self.inputAnnexValues enumerateObjectsUsingBlock:^(XYXAnnexViewInputModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.indexPath.column == self.currentSelectedColumn) {
            title = [self newMenuTitleForAnnexInput:obj];
            *stop = YES;
        }
    }];
    
    __block XYXIndexPath *toRemove = nil;
    __block XYXIndexPath *toScrabbleTitleUp = nil;
    [self.selectedTableViewIndexPaths enumerateObjectsUsingBlock:^(XYXIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.column == self.currentSelectedColumn) {
            if (title.length > 0) {
                toRemove = obj;
            }else{
                toScrabbleTitleUp = obj;
            }
            *stop = YES;
        }
    }];
    
    if (toRemove) {
        [self.selectedTableViewIndexPaths removeObject:toRemove];
    }
    else if (toScrabbleTitleUp) {
        
        switch (self.currentColumnType) {
            case MenuColumnTypeTableViewTwo:{
                
                NSIndexPath *newIndex = [NSIndexPath indexPathForRow:toScrabbleTitleUp.item inSection:0];
                UITableViewCell *cell = [self.secondTableView cellForRowAtIndexPath:newIndex];
                title = cell.textLabel.text;
            }
                break;
            case MenuColumnTypeTableViewThree:{
                NSIndexPath *newIndex = [NSIndexPath indexPathForRow:toScrabbleTitleUp.leaf inSection:0];
                UITableViewCell *cell = [self.thirdTableView cellForRowAtIndexPath:newIndex];
                title = cell.textLabel.text;
            }
                break;
                
            default:
                title = nil;
                break;
        }
        
    }
    return title;
}

#pragma mark Submit Data


-(void)submitFilterResultsWithStatisticModel:(XYXFilterStatisticModel *)statisticModel{
    [self removeNeedlessFilterDataForInputValues];
    
    if ([_delegate respondsToSelector:@selector(menu:filterResultWithTableView:collectionView:annexValues:)]) {
        [_delegate menu:self.menu filterResultWithTableView:self.selectedTableViewIndexPaths collectionView:self.selectedCollectionViewIndexPaths annexValues:self.inputAnnexValues];
    }
    
    if (statisticModel && [_delegate respondsToSelector:@selector(menu:statisticWithStatisticModel:)]) {
        [_delegate menu:self.menu statisticWithStatisticModel:statisticModel];
    }
}

-(void)submitToStatisticWithClickIndexPath:(XYXIndexPath*)currentSelectedIndexPath{
    NSArray *arrTemp = [self valuableFilterDataForInputValues];
    if([_delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:withTableFilterResult:collectionFilterResult:annexValues:)]){
        [_delegate menu:self.menu didSelectRowAtIndexPath:currentSelectedIndexPath withTableFilterResult:arrTemp collectionFilterResult:self.selectedCollectionViewIndexPaths annexValues:self.inputAnnexValues];
    }
}

-(NSArray*)valuableFilterDataForInputValues{
    __block NSMutableArray *arrValuable = [NSMutableArray array];
    typeof(self) weakSelf = self;
    [self.selectedTableViewIndexPaths enumerateObjectsUsingBlock:^(XYXIndexPath * _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop) {
        if (weakSelf.inputAnnexValues.count) {
            [weakSelf.inputAnnexValues enumerateObjectsUsingBlock:^(XYXAnnexViewInputModel * _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj1.indexPath.column != obj2.column) {
                    [arrValuable addObject:obj2];
                }
            }];
        }else{
            arrValuable = weakSelf.selectedTableViewIndexPaths;
        }
    }];
    return arrValuable;
}

-(void)removeNeedlessFilterDataForInputValues{
    NSMutableArray *arrToRemove = [NSMutableArray array];
    [self.inputAnnexValues enumerateObjectsUsingBlock:^(XYXAnnexViewInputModel * _Nonnull obj1, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.selectedTableViewIndexPaths enumerateObjectsUsingBlock:^(XYXIndexPath * _Nonnull obj2, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj1.indexPath.column == obj2.column) {
                [arrToRemove addObject:obj2];
            }
        }];
    }];
    if (arrToRemove.count) {
        [self.selectedTableViewIndexPaths removeObjectsInArray:arrToRemove];
    }
}

#pragma mark - Public

-(void)configUIWith:(NSUInteger)selectedColumn showSelectedItem:(BOOL)showSelectedItem complete:(void (^)())complete{
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    if (self.detalHeightForKeyboard) {
        [self animateHeight:0 withDuration:0.5 complete:nil];
    }
    
    self.currentSelectedColumn = selectedColumn;
    self.currentColumnType = [self.dataSource menu:self.menu columnTypeOfColumn:selectedColumn];
    
    XYXIndexPath *currentSelectedIndexPath = [self selectedIndexPathOfColumn:selectedColumn isNullable:NO];
    
    AnnexType annexType ;
    if ([_dataSource respondsToSelector:@selector(menu:annexTypeOfIndexPath:)]) {
        annexType = [_dataSource menu:self.menu annexTypeOfIndexPath:currentSelectedIndexPath];
    }else{
        annexType = AnnexTypeNone;
    }
    NSString *annexDescribe = nil;
    if ([_dataSource respondsToSelector:@selector(menu:describeTitleOfAnnexIndexPath:)]) {
        annexDescribe = [_dataSource menu:self.menu describeTitleOfAnnexIndexPath:currentSelectedIndexPath];
    }
    
    [self configUIWith:self.currentColumnType annexType:annexType annexDescribe:annexDescribe complete:^{
        if (showSelectedItem) {
            if (self.firstTableView.superview) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndexPath.row inSection:0];
                [self.firstTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            }
            if (self.secondTableView.superview) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndexPath.item inSection:0];
                [self.secondTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            }
            if (self.thirdTableView.superview) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentSelectedIndexPath.leaf inSection:0];
                [self.thirdTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            }
        }
        
        if (complete) {
            complete();
        }
    }];
}

-(void)animateHeight:(CGFloat)height withDuration:(NSTimeInterval)duration complete:(void (^)())complete{
    if (height > 0) {
        //Minus self.frame.size.height with height.
        self.detalHeightForKeyboard = height;
        self.unfoldHeight -= height;
        [UIView animateWithDuration:duration animations:^{
            
            if (self.currentColumnType == MenuColumnTypeCollectionView) {
                self.collectionView.frame = CGRectMake(CGRectGetMinX(self.collectionView.frame), CGRectGetMinY(self.collectionView.frame), CGRectGetWidth(self.collectionView.frame), CGRectGetHeight(self.collectionView.frame)-height);
            }else{
                if (self.firstTableView.superview) {
                    self.firstTableView.frame = CGRectMake(CGRectGetMinX(self.firstTableView.frame), CGRectGetMinY(self.firstTableView.frame), CGRectGetWidth(self.firstTableView.frame), CGRectGetHeight(self.firstTableView.frame)-height);
                }
                if (self.secondTableView.superview) {
                    self.secondTableView.frame = CGRectMake(CGRectGetMinX(self.secondTableView.frame), CGRectGetMinY(self.secondTableView.frame), CGRectGetWidth(self.secondTableView.frame), CGRectGetHeight(self.secondTableView.frame)-height);
                }
                if (self.thirdTableView.superview) {
                    self.thirdTableView.frame = CGRectMake(CGRectGetMinX(self.thirdTableView.frame), CGRectGetMinY(self.thirdTableView.frame), CGRectGetWidth(self.thirdTableView.frame), CGRectGetHeight(self.thirdTableView.frame)-height);
                }
            }
            self.currentAnnexView.frame = CGRectMake(CGRectGetMinX(self.currentAnnexView.frame), CGRectGetMinY(self.currentAnnexView.frame)-height, CGRectGetWidth(self.currentAnnexView.frame), CGRectGetHeight(self.currentAnnexView.frame));
            self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), self.unfoldHeight);
        } completion:^(BOOL finished) {
            if(complete){
                complete();
            }
        }];
    }
    else{
        if (self.detalHeightForKeyboard <= 0 ) {
            return;
        }
        self.unfoldHeight += self.detalHeightForKeyboard;
        [UIView animateWithDuration:duration animations:^{
            
            if (self.currentColumnType == MenuColumnTypeCollectionView) {
                self.collectionView.frame = CGRectMake(CGRectGetMinX(self.collectionView.frame), CGRectGetMinY(self.collectionView.frame), CGRectGetWidth(self.collectionView.frame), CGRectGetHeight(self.collectionView.frame) + self.detalHeightForKeyboard );
            }else{
                if (self.firstTableView.superview) {
                    self.firstTableView.frame = CGRectMake(CGRectGetMinX(self.firstTableView.frame), CGRectGetMinY(self.firstTableView.frame), CGRectGetWidth(self.firstTableView.frame), CGRectGetHeight(self.firstTableView.frame) + self.detalHeightForKeyboard );
                }
                if (self.secondTableView.superview) {
                    self.secondTableView.frame = CGRectMake(CGRectGetMinX(self.secondTableView.frame), CGRectGetMinY(self.secondTableView.frame), CGRectGetWidth(self.secondTableView.frame), CGRectGetHeight(self.secondTableView.frame) + self.detalHeightForKeyboard );
                }
                if (self.thirdTableView.superview) {
                    self.thirdTableView.frame = CGRectMake(CGRectGetMinX(self.thirdTableView.frame), CGRectGetMinY(self.thirdTableView.frame), CGRectGetWidth(self.thirdTableView.frame), CGRectGetHeight(self.thirdTableView.frame) + self.detalHeightForKeyboard );
                }
            }
            self.currentAnnexView.frame = CGRectMake(CGRectGetMinX(self.currentAnnexView.frame), CGRectGetMinY(self.currentAnnexView.frame) + self.detalHeightForKeyboard, CGRectGetWidth(self.currentAnnexView.frame), CGRectGetHeight(self.currentAnnexView.frame));
            self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), self.unfoldHeight);
            
        } completion:^(BOOL finished) {
            self.detalHeightForKeyboard = 0;
            if(complete){
                complete();
            }
        }];
    }
}

#pragma mark - TableView DataSource & Delegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSUInteger numberOfRows = 1;
    XYXIndexPath *idxPath = [self selectedIndexPathOfColumn:self.currentSelectedColumn isNullable:NO];
    
    if (tableView == self.firstTableView) {
        if ([_dataSource respondsToSelector:@selector(menu:numberOfRowsInColumn:)]) {
            numberOfRows = [_dataSource menu:self.menu numberOfRowsInColumn:idxPath.column];
        }
    }else if (tableView == self.secondTableView){
        if ([_dataSource respondsToSelector:@selector(menu:numberOfItemsAtIndexPath:)]) {
            numberOfRows = [_dataSource menu:self.menu numberOfItemsAtIndexPath:idxPath];
        }
    }else if (tableView == self.thirdTableView){
        if ([_dataSource respondsToSelector:@selector(menu:numberOfLeafsAtIndexPath:)]) {
            numberOfRows = [_dataSource menu:self.menu numberOfLeafsAtIndexPath:idxPath];
        }
    }
    return numberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    XYXFilterTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[XYXFilterTableViewCell reuseIdentifier]];
    if (!cell) {
        cell = [[XYXFilterTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[XYXFilterTableViewCell reuseIdentifier]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    XYXIndexPath *currentSelectedIndexPath = [self selectedIndexPathOfColumn:self.currentSelectedColumn isNullable:NO];
    if (tableView == self.firstTableView) {
        XYXIndexPath *idxPath = [XYXIndexPath indexPathWithColumn:currentSelectedIndexPath.column row:indexPath.row];
        cell.textLabel.text = [_dataSource menu:self.menu titleForRowAtIndexPath:idxPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        if (self.currentColumnType == MenuColumnTypeTableViewTwo || self.currentColumnType == MenuColumnTypeTableViewThree) {
            cell.accessoryView = [AccessoryView normalAccessoryView];
            if (indexPath.row == currentSelectedIndexPath.row) {
                cell.accessoryView = [AccessoryView selectedAccessoryView];
            }
        }else{
            cell.accessoryView = nil;
        }
        
        if (indexPath.row == currentSelectedIndexPath.row) {
            cell.selected = YES;
        }
        
    }else if(tableView == self.secondTableView){
        
        XYXIndexPath *idxPath = [XYXIndexPath indexPathWithColumn:currentSelectedIndexPath.column row:currentSelectedIndexPath.row item:indexPath.row];
        cell.textLabel.text = [_dataSource menu:self.menu titleForItemAtIndexPath:idxPath];
        
        if (self.currentColumnType == MenuColumnTypeTableViewThree) {
            cell.accessoryView = [AccessoryView normalAccessoryView];
            if (indexPath.row == currentSelectedIndexPath.item) {
                cell.accessoryView = [AccessoryView selectedAccessoryView];
            }
        }else{
            cell.accessoryView = nil;
        }
        
        if (indexPath.row == currentSelectedIndexPath.item) {
            cell.selected = YES;
        }
        
    }else if(tableView == self.thirdTableView){
        XYXIndexPath *idxPath = [XYXIndexPath indexPathWithColumn:currentSelectedIndexPath.column row:currentSelectedIndexPath.row item:currentSelectedIndexPath.item leaf:indexPath.row];
        cell.textLabel.text = [_dataSource menu:self.menu titleForLeafAtIndexPath:idxPath];
        
        if (indexPath.item == currentSelectedIndexPath.leaf) {
            cell.selected = YES;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    self.needSearchWithinInputValues = NO;
    
    XYXIndexPath *currentSelectedIndexPath = [self refreshSelectedIndexPathOfTableView:tableView atIndexPath:indexPath];
    BOOL shouldSubmitResult = [self refreshMenuTitleWith:tableView atIndexPath:indexPath];
    
    if (shouldSubmitResult) {
        //Handle the repeat value in 'inputAnnexValues'
        __block XYXAnnexViewInputModel *oldToRemove = nil;
        [self.inputAnnexValues enumerateObjectsUsingBlock:^(XYXAnnexViewInputModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.indexPath.column == currentSelectedIndexPath.column) {
                oldToRemove = obj;
                *stop = YES;
            }
        }];
        if (oldToRemove) {
            [self.inputAnnexValues removeObject:oldToRemove];
        }

        XYXFilterStatisticModel *statisticModel = [XYXFilterStatisticModel new];
        XYXFilterTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        statisticModel.titleForTableView = cell.textLabel.text;
        statisticModel.indexPath = currentSelectedIndexPath;
        [self submitFilterResultsWithStatisticModel:statisticModel];

    }else{
        [self submitToStatisticWithClickIndexPath:currentSelectedIndexPath];

    }
    
    [self refreshTableView:tableView];
}

#pragma mark - UICollectionView DataSource & Delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return [_dataSource menu:self.menu numberOfRowsInColumn:self.currentSelectedColumn];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    XYXIndexPath *idxPath = [XYXIndexPath indexPathWithColumn:self.currentSelectedColumn row:section];
    return [_dataSource menu:self.menu numberOfItemsAtIndexPath:idxPath];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    XYXFilterCollectionViewCell *cell = (XYXFilterCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:[XYXFilterCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    
    XYXIndexPath *idxPath = [XYXIndexPath indexPathWithColumn:self.currentSelectedColumn row:indexPath.section item:indexPath.row];
    cell.textLabel.text = [_dataSource menu:self.menu titleForItemAtIndexPath:idxPath];
    
    NSArray *currentSelectedIndexPaths = [self selectedColletionViewIndexPathAtIndexPath:idxPath];
    
    [currentSelectedIndexPaths enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual:idxPath]) {
            cell.selected = YES;
            *stop = YES;
        }else{
            cell.selected = NO;
        }
    }];
    
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionFooter){
        return [[UICollectionReusableView alloc]initWithFrame:CGRectNull];
    }
    XYXFilterDefaultHeaderView *defaultHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:[XYXFilterDefaultHeaderView reuseIdentifier] forIndexPath:indexPath];
    XYXIndexPath *currentIndexPath =  [XYXIndexPath indexPathWithColumn:self.currentSelectedColumn row:indexPath.section item:indexPath.row];
    defaultHeaderView.titleLabel.text = [_dataSource menu:self.menu titleForRowAtIndexPath:currentIndexPath];
    if ([self.dataSource respondsToSelector:@selector(menu:subTitleForCollectionSectionAtIndexPath:)]) {
        defaultHeaderView.subtitleLabel.text = [_dataSource menu:self.menu subTitleForCollectionSectionAtIndexPath:currentIndexPath];
    }else{
        defaultHeaderView.subtitleLabel.text = nil;
    }
    [defaultHeaderView setNeedsLayout];
    [defaultHeaderView layoutIfNeeded];
    return defaultHeaderView;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(CGRectGetWidth(self.frame), 40);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize newSize = COLLECTION_CELL_DEFAULT_SIZE;
    if ([_dataSource respondsToSelector:@selector(menu:sizeOfCollectionCellAtIndexPath:)]) {
        XYXIndexPath *currentIndexPath = [XYXIndexPath indexPathWithColumn:self.currentSelectedColumn row:indexPath.section item:indexPath.item];
        newSize = [_dataSource menu:self.menu sizeOfCollectionCellAtIndexPath:currentIndexPath];
        
        newSize = (newSize.width == CGSizeZero.width) && (newSize.height == CGSizeZero.height) ? COLLECTION_CELL_DEFAULT_SIZE : newSize;
    }
    
    return newSize;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    XYXIndexPath *currentIndexPath = [XYXIndexPath indexPathWithColumn:self.currentSelectedColumn row:indexPath.section item:indexPath.row];
 
    __block XYXIndexPath *oldToRemove = nil;
    [self.selectedCollectionViewIndexPaths enumerateObjectsUsingBlock:^(XYXIndexPath *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqual:currentIndexPath]) {
            oldToRemove = obj;
            *stop = YES;
        }
    }];
    
    if (oldToRemove) {
        [self.selectedCollectionViewIndexPaths removeObject:oldToRemove];
    }else{
        
        BOOL allowsMultipleSelection = NO;
        if ([_dataSource respondsToSelector:@selector(menu:allowsMultipleSelectionInCollectionViewAtIndexPath:)]) {
            allowsMultipleSelection = [_dataSource menu:self.menu allowsMultipleSelectionInCollectionViewAtIndexPath:currentIndexPath];
        }
        
        if (!allowsMultipleSelection) {
            
            NSMutableArray *arrToRemove = [NSMutableArray array];
            [self.selectedCollectionViewIndexPaths enumerateObjectsUsingBlock:^(XYXIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.column == currentIndexPath.column &&
                    obj.row == currentIndexPath.row) {
                    [arrToRemove addObject:obj];
                }
            }];
            if (arrToRemove.count) {
                [self.selectedCollectionViewIndexPaths removeObjectsInArray:arrToRemove];
            }
        }
        [self.selectedCollectionViewIndexPaths addObject:currentIndexPath];
    }
    [collectionView reloadData];
    
    [self submitToStatisticWithClickIndexPath:currentIndexPath];
}

@end

#pragma mark TableViewCell

@implementation XYXFilterTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.font = [UIFont systemFontOfSize:TableView_Cell_FontSize];
        self.textLabel.textColor = TABLEVIEW_CELL_TEXT_DEFAULT_COLOR;
        self.backgroundColor = TABLEVIEW_CELL_DEFAULT_BG_COLOR;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)setSelected:(BOOL)selected{
    if (selected) {
        self.textLabel.textColor = TABLEVIEW_CELL_TEXT_SELECTED_COLOR;
        self.backgroundColor = TABLEVIEW_CELL_SELECTED_BG_COLOR;
    }else{
        self.textLabel.textColor = TABLEVIEW_CELL_TEXT_DEFAULT_COLOR;
        self.backgroundColor = TABLEVIEW_CELL_DEFAULT_BG_COLOR;
    }
}

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

@end

#pragma mark CollectionView

@implementation XYXFilterCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self.contentView addSubview:self.textLabel];
        self.clipsToBounds = NO;
        self.selected = NO;
    }
    return self;
}

-(UILabel *)textLabel{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        _textLabel.layer.masksToBounds = YES;
        _textLabel.layer.borderWidth = 0.5;
        _textLabel.layer.borderColor = [UIColor grayColor].CGColor;
        _textLabel.text = NSLocalizedString(@"item", @"item");
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.font = [UIFont systemFontOfSize:CollectionView_Cell_FontSize];
    }
    return _textLabel;
}

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}

-(void)layoutSubviews{
    self.contentView.frame = self.bounds;
    self.textLabel.frame = self.bounds;
}

-(void)setSelected:(BOOL)selected{
    if (selected) {
        self.backgroundColor = COLLECTION_CELL_SELECTED_COLOR;
        self.textLabel.textColor = COLLECTION_CELL_TEXT_SELECTED_COLOR;
        self.textLabel.layer.borderWidth = 0.0;
    }else{
        self.textLabel.textColor = COLLECTION_CELL_TEXT_DEFAULT_COLOR;
        self.backgroundColor = COLLECTION_CELL_DEFAULT_COLOR;
        self.textLabel.layer.borderWidth = 0.5;
        self.textLabel.layer.borderColor = COLLECTION_CELL_TEXT_DEFAULT_COLOR.CGColor;
    }
}

@end


@implementation XYXFilterDefaultHeaderView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.subtitleLabel];
        [self addSubview:self.lineView];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.font = [UIFont systemFontOfSize:14.f];
        _titleLabel.textColor = [UIColor darkGrayColor];
        _titleLabel.text = NSLocalizedString(@"Title", @"Title");
    }
    return _titleLabel;
}

-(UILabel *)subtitleLabel{
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _subtitleLabel.font = [UIFont systemFontOfSize:14.f];
        _subtitleLabel.textColor = [UIColor lightGrayColor];
        _subtitleLabel.text = NSLocalizedString(@"Subtitle", @"Subtitle");
    }
    return _subtitleLabel;
}

-(UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = SPEPARATOR_COLOR;
        _lineView.frame = CGRectMake(10, CGRectGetHeight(self.frame)-0.5, SCREEN_WIDTH - 10, 0.5);
    }
    return _lineView;
}

-(void)layoutSubviews{
    [self.titleLabel sizeToFit];
    [self.subtitleLabel sizeToFit];
    
    CGRect newTitleFrame =  CGRectMake(10, (CGRectGetHeight(self.frame)-CGRectGetHeight(self.titleLabel.frame))/2, CGRectGetWidth(self.titleLabel.frame)+6, CGRectGetHeight(self.titleLabel.frame));
    CGFloat subTitleWidth = SCREEN_WIDTH - 10*3 - CGRectGetWidth(newTitleFrame);
    subTitleWidth = MIN(CGRectGetWidth(self.subtitleLabel.frame), subTitleWidth);
    CGRect newSubTitleFrame = CGRectMake(CGRectGetMaxX(newTitleFrame), (CGRectGetHeight(self.frame)-CGRectGetHeight(newTitleFrame))/2, subTitleWidth, CGRectGetHeight(newTitleFrame));
    
    self.titleLabel.frame = newTitleFrame;
    self.subtitleLabel.frame = newSubTitleFrame;
}

+(NSString *)reuseIdentifier{
    return NSStringFromClass([self class]);
}
@end

#pragma mark - AccessoryView

@implementation AccessoryView

#pragma mark Cache

static UIImage *normalImage = nil;
static UIImage *selectedImage = nil;

#pragma mark Initialization

+ (void)initialize
{
}

#pragma mark Drawing Methods

+ (void)drawNormalAccessoryView{

    UIColor* color = [UIColor colorWithRed:102.0/255 green:102.0/255 blue:102.0/255 alpha:1.0];
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(2.5, 0.5)];
    [bezierPath addLineToPoint: CGPointMake(6.5, 4.5)];
    [bezierPath addLineToPoint: CGPointMake(2.5, 8.5)];
    [color setStroke];
    bezierPath.lineWidth = 2;
    [bezierPath stroke];

}
+ (void)drawSelectedAccessoryView
{
    UIColor* color = [UIColor colorWithRed:59.0/255 green:148.0/255 blue:239.0/255 alpha:1.0];
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(2.5, 0.5)];
    [bezierPath addLineToPoint: CGPointMake(6.5, 4.5)];
    [bezierPath addLineToPoint: CGPointMake(2.5, 8.5)];
    [color setStroke];
    bezierPath.lineWidth = 2;
    [bezierPath stroke];
}

#pragma mark Generated Images

+(UIImageView*)normalAccessoryView{
    
    if (normalImage) {
        return [[UIImageView alloc]initWithImage:normalImage];
    }
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(9, 9), NO, 0.0f);
    [AccessoryView drawNormalAccessoryView];
    
    UIImage *accessory = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [[UIImageView alloc]initWithImage:accessory];
}

+(UIImageView*)selectedAccessoryView{
    
    if (selectedImage) {
        return [[UIImageView alloc]initWithImage:selectedImage];
    }
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(9, 9), NO, 0.0f);
    [AccessoryView drawSelectedAccessoryView];
    UIImage *accessory = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [[UIImageView alloc]initWithImage:accessory];
}

@end
