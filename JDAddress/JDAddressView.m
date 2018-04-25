//
//  JDAddressView.m
//  111
//
//  Created by LX on 2018/4/2.
//  Copyright © 2018年 LX. All rights reserved.
//

#import "JDAddressView.h"

#define KContentHeight 300
#define KTitleHeight 50
#define kBtnHeight 30
#define WIDTH [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height
#define RGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]

static NSString *CellID=@"CellID";

@interface JDAddressView () <UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

{
    UIView             *_contentView;
    UIScrollView       *_mainScrollView;
    NSArray            *_provinceArray;
    NSArray            *_cityArray;
    NSArray            *_townArray;
    NSDictionary       *_pickerDic;
    NSArray            *_selectedArray;
    NSString           *_province;
    NSString           *_city;
    NSString           *_town;
}
@end

@implementation JDAddressView

#pragma mark -- init

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self=[super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        //
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT-380, WIDTH, KContentHeight+KTitleHeight+kBtnHeight)];
        _contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_contentView];
        
        //
        UILabel *_lbTitle=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, WIDTH, KTitleHeight)];
        _lbTitle.backgroundColor=[UIColor redColor];
        _lbTitle.text=@"选择地址";
        _lbTitle.textAlignment=NSTextAlignmentCenter;
        _lbTitle.textColor=RGB(0, 0, 34);
        [_contentView addSubview:_lbTitle];
        //
        for (NSInteger i=0; i<3; i++) {
            UIButton *_btn=[UIButton buttonWithType:UIButtonTypeCustom];
            _btn.frame=CGRectMake(80*i, KTitleHeight, 80,kBtnHeight);
            [_btn setTitleColor:RGB(204, 54, 60) forState:UIControlStateNormal];
            _btn.tag=100+i;
            [_btn setTitle:@"" forState:UIControlStateNormal];
            [_btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            _btn.userInteractionEnabled=NO;
            [_contentView addSubview:_btn];
            //
            UIView *_lineView=[[UIView alloc]initWithFrame:CGRectMake(80*i+10, 78, 60, 2)];
            _lineView.backgroundColor=RGB(204, 54, 60);
            [_contentView addSubview:_lineView];
            _lineView.tag=300+i;
            _lineView.hidden=YES;
            if (i==0) {
                [_btn setTitle:@"请选择" forState:UIControlStateNormal];
                _btn.userInteractionEnabled=YES;
                _lineView.hidden=NO;
            }
        }
        //
        _mainScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 80, WIDTH, KContentHeight)];
        _mainScrollView.delegate=self;
        _mainScrollView.contentSize=CGSizeMake(WIDTH, KContentHeight);
        _mainScrollView.pagingEnabled=YES;
        _mainScrollView.showsVerticalScrollIndicator=NO;
        _mainScrollView.showsHorizontalScrollIndicator=NO;
        [_contentView addSubview:_mainScrollView];
        for (NSInteger i=0; i<3; i++) {
            UITableView *_tbView=[[UITableView alloc]initWithFrame:CGRectMake(WIDTH*i, 0, WIDTH, KContentHeight)style:UITableViewStylePlain];
            [_tbView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellID];
            _tbView.estimatedRowHeight=0;
            _tbView.estimatedSectionFooterHeight=0;
            _tbView.estimatedSectionHeaderHeight=0;
            _tbView.separatorStyle=UITableViewCellSeparatorStyleNone;
            _tbView.delegate=self;
            _tbView.dataSource=self;
            _tbView.tag=200+i;
            [_mainScrollView addSubview:_tbView];
        }
        
        UITapGestureRecognizer *_tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(remove)];
        _tap.delegate=self;
        [self addGestureRecognizer:_tap];
        
        //
        [self show];
    }
    return self;
}

#pragma mark -- UIGestureDelegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:_contentView]) {
        return NO;
    }
    return YES;
}

#pragma mark -- Private Method

- (void)loadData
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MMTAddress" ofType:@"plist"];
    _pickerDic = [[NSDictionary alloc] initWithContentsOfFile:path];
    _provinceArray = [_pickerDic valueForKey:@"p"];
    _selectedArray = _pickerDic[@"c"][_provinceArray.firstObject];
    _cityArray = _selectedArray;
    _townArray = _pickerDic[@"a"][@"北京市-北京市"];
}

- (void)setProvinces:(NSArray *)provinces
{
    _provinceArray=provinces;
    UITableView *_tbView=[_mainScrollView viewWithTag:200];
    [_tbView reloadData];
}

- (void)setCities
{
    _cityArray=_pickerDic[@"c"][_province];
    UITableView *_tbView=[_contentView viewWithTag:201];
    [_tbView reloadData];
    _mainScrollView.contentSize=CGSizeMake(2*WIDTH, KContentHeight);
    [UIView animateWithDuration:0.5 animations:^{
        _mainScrollView.contentOffset=CGPointMake(WIDTH, 0);
    }];
}

- (void)setTowns
{
    _townArray=_pickerDic[@"a"][[NSString stringWithFormat:@"%@-%@",_province,_city]];;
    UITableView *_tbView=[_mainScrollView viewWithTag:202];
    [_tbView reloadData];
    _mainScrollView.contentSize=CGSizeMake(3*WIDTH, 0);
    [UIView animateWithDuration:0.5 animations:^{
        _mainScrollView.contentOffset=CGPointMake(2*WIDTH, 0);
    }];
}

#pragma mark -- Button Event

- (void)btnClicked:(UIButton *)sender
{
    for (UIView *subView in _contentView.subviews) {
        if (subView.tag>=300) {
            subView.hidden=YES;
        }
    }
    UIView *_line=[_contentView viewWithTag:300+sender.tag-100];
    _line.hidden=NO;
    [UIView animateWithDuration:0.5 animations:^{
        _mainScrollView.contentOffset = CGPointMake(WIDTH *(sender.tag - 100), 0);
    }];
}

- (void)show
{
    [self loadData];
//    [[UIApplication sharedApplication].delegate.window addSubview:self];
//    self.center = [UIApplication sharedApplication].keyWindow.center;
//    CGRect contentViewFrame = CGRectMake(0, HEIGHT, WIDTH, KContentHeight);
//    contentViewFrame.origin.y -= _contentView.frame.size.height;
//    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//        _contentView.frame = contentViewFrame;
//    } completion:^(BOOL finished) {
//
//    }];
}

- (void)remove
{
    CGRect contentViewFrame = _contentView.frame;
    contentViewFrame.origin.y += _contentView.frame.size.height;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _contentView.frame = contentViewFrame;
    } completion:^(BOOL finished) {
        [_contentView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (void)hidenPickerView
{
    if ([self.delegate respondsToSelector:@selector(didSelected:)]) {
        [self.delegate didSelected:[NSString stringWithFormat:@"%@%@%@",_province,_city,_town]];
    }
    [self remove];
}

#pragma mark -- UItableViewDelegate &dateSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (tableView.tag-200) {
        case 0:
            return _provinceArray.count;
            break;
            case 1:
            return _cityArray.count;
            break;
            case 2:
            return _townArray.count;
            break;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *_cell=[tableView dequeueReusableCellWithIdentifier:CellID forIndexPath:indexPath];
    if (!_cell) {
        _cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
    }
    _cell.selectedBackgroundView.backgroundColor=RGB(255, 238, 238);
    _cell.textLabel.highlightedTextColor=RGB(204, 54, 60);
    _cell.textLabel.textColor=RGB(102, 102, 102);
    _cell.textLabel.font=[UIFont systemFontOfSize:18.0f];
    switch (tableView.tag-200) {
        case 0:
            _cell.textLabel.text=_provinceArray[indexPath.row];
            break;
            case 1:
            _cell.textLabel.text=_cityArray[indexPath.row];
            break;
            case 2:
            _cell.textLabel.text=_townArray[indexPath.row];
            break;
    }
    return _cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIButton *_btn1=[_contentView viewWithTag:100];
    UIButton *_btn2=[_contentView viewWithTag:101];
    UIButton *_btn3=[_contentView viewWithTag:102];
    for (UIView *subView in _contentView.subviews) {
        if (subView.tag>=300) {
            subView.hidden=YES;
        }
    }
   // UIView *_lineView1 = [_contentView viewWithTag:300];
    UIView *_lineView2 = [_contentView viewWithTag:301];
    UIView *_lineView3 = [_contentView viewWithTag:302];
    
    NSInteger _row=indexPath.row;
    switch (tableView.tag-200) {
        case 0:
            {
                _province=_provinceArray[_row];
                [self setCities];
                [_btn1 setTitle:_province forState:UIControlStateNormal];
                [_btn1 setTitleColor:RGB(34, 34, 34) forState:UIControlStateNormal];
                [_btn2 setTitle:@"请选择" forState:UIControlStateNormal];
                [_btn2 setTitleColor:RGB(204, 54, 60) forState:UIControlStateNormal];
                [_btn3 setTitle:@"" forState:UIControlStateNormal];
                _btn1.userInteractionEnabled=YES;
                _btn2.userInteractionEnabled=YES;
                _btn3.userInteractionEnabled=NO;
                _lineView2.hidden=NO;
            }
            break;
        case 1:
        {
            _city=_cityArray[_row];
            [self setTowns];
            [_btn2 setTitle:_city forState:UIControlStateNormal];
            [_btn2 setTitleColor:RGB(34, 34, 34) forState:UIControlStateNormal];
            [_btn3 setTitle:@"请选择" forState:UIControlStateNormal];
            [_btn3 setTitleColor:RGB(204, 54, 60) forState:UIControlStateNormal];
            _lineView3.hidden = NO;
            _btn3.userInteractionEnabled = YES;
        }
            break;
        case 2:
        {
            _town=_townArray[_row];
            [self setTowns];
            [_btn3 setTitle:_town forState:UIControlStateNormal];
            [_btn3 setTitleColor:RGB(34, 34, 34) forState:UIControlStateNormal];
            _lineView3.hidden = NO;
            [self hidenPickerView];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    for (UIView *subView in _contentView.subviews) {
        if (subView.tag>=300) {
            subView.hidden=YES;
        }
    }
    if (scrollView==_mainScrollView) {
        UIView *lineView = [_mainScrollView viewWithTag:300 + scrollView.contentOffset.x / WIDTH];
        lineView.hidden = NO;
    }
}

@end
