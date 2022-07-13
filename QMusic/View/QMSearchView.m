//
//  QMSearchView.m
//  QMusic
//
//  Created by JiangNan on 2022/4/4.
//  Copyright © 2022 NanJiang. All rights reserved.
//

#import "QMSearchView.h"

@interface QMSearchView ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) NSString *searchName;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *didSearchArray;
@end

@implementation QMSearchView

- (instancetype)initWithSearchArray:(NSMutableArray<NSDictionary *> *)searchArray searchName:(NSString *)searchNameSuper frame:(CGRect)frame{
    self = [super init];
    if (self) {
        self.frame = frame;
        
        _searchName = searchNameSuper;
        self.backgroundColor = [UIColor whiteColor];
        _didSearchArray = [[NSMutableArray alloc] init];
        // 查找符合条件的array
        for (NSDictionary *dict in searchArray) {
            if ([dict[@"name"] rangeOfString:_searchName options:NSCaseInsensitiveSearch].length ||
                [dict[@"detail"] rangeOfString:_searchName options:NSCaseInsensitiveSearch].length) {  // 不区分大小写
                [_didSearchArray addObject:dict];
            }
        }

        // 加载搜索列表
        if (_didSearchArray.count != 0 && ![_searchName isEqualToString:@" "]) {
            _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height - 148)];
            _tableView.dataSource = self;
            _tableView.delegate = self;
            _tableView.tableFooterView = [[UIView alloc] init];  // 不显示底部空白cell
            [self addSubview:self.tableView];
        }
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.didSearchArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"id"];
    }
    
    NSDictionary *dict = self.didSearchArray[indexPath.row];
    cell.textLabel.text = dict[@"name"];
    cell.detailTextLabel.text = dict[@"detail"];
    cell.detailTextLabel.alpha = 0.7;
    return cell;
}

#pragma mark - UITableViewDelegate

// 点击后进入detailView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = self.didSearchArray[indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectRowAtIndexPath:)]) {
        [self.delegate didSelectRowAtIndexPath:[dict[@"index"] intValue]];
    }
}

@end

