//
//  QMLikeViewController.m
//  QMusic
//
//  Created by JiangNan on 2022/3/29.
//  Copyright © 2022 NanJiang. All rights reserved.
//

#import "QMLikeViewController.h"
#import "QMLikeDetailViewController.h"
#import "QMTableViewCell.h"
#import "QMSearchView.h"

@interface QMLikeViewController ()<UITableViewDelegate, UITableViewDataSource, QMLikeDetailViewControllerDelegate, UISearchBarDelegate, QMSearchViewDelegate>
@property (nonatomic, strong) NSArray *musicList;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) QMSearchView *searchView;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *searchArray;
@end

@implementation QMLikeViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tabBarItem.title = @"喜欢";
        self.tabBarItem.image = [UIImage imageNamed:@"SourcesBundle.bundle/icon/heart@2x.png"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"SourcesBundle.bundle/icon/heart.fill@2x.png"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    // 加载tableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] init];  // 不显示底部空白cell
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;  // 隐藏分割线
    [self.view addSubview:self.tableView];
    
    
    
    // 加载歌曲
    NSArray * pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * fileName = [pathArray[0] stringByAppendingPathComponent:@"music.plist"];
    self.musicList = [[NSArray alloc]initWithContentsOfFile:fileName];
    
    
    
    // 加载搜索界面
    self.searchArray = [[NSMutableArray alloc] init];
    NSInteger i = 0;
    for (NSInteger j = 0; j < self.musicList.count; j++) {
        NSDictionary *dict = self.musicList[j];
        if ([dict[@"like"] intValue]) {
            NSString *searchIndex = [NSString stringWithFormat:@"%ld", i];
            NSDictionary *searchDict = [NSDictionary dictionaryWithObjectsAndKeys:searchIndex, @"index",
                                                                                  dict[@"name"], @"name",
                                                                                  dict[@"detail"], @"detail",
                                                                                  nil];
            [self.searchArray addObject:searchDict];
            i++;
        }
    }
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 60);
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
    
    
    
    // 加载navigationBar上的文字
    UILabel *navigationItemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 88)];
    navigationItemLabel.text = @"我喜欢";
    navigationItemLabel.font = [UIFont boldSystemFontOfSize:22];
    navigationItemLabel.textAlignment = NSTextAlignmentCenter;
    [self.tabBarController.navigationItem setTitleView:navigationItemLabel];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    for (NSDictionary *dict in self.musicList) {
        if([dict[@"like"] intValue]) {
            count++;
        }
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
    if (!cell) {
        cell = [[QMTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"id"];
    }
    
    // 设置每个单元格
    NSInteger countLikeMusic = 0;
    for (NSDictionary *dict in self.musicList) {
        if([dict[@"like"] intValue]) {
            countLikeMusic++;
        }
        if (countLikeMusic == indexPath.row + 1) {
            cell.textLabel.text = dict[@"name"];
            cell.detailTextLabel.text = dict[@"detail"];
            cell.detailTextLabel.alpha = 0.7;
            UIImage *albumImage = [UIImage imageNamed:[NSString stringWithFormat:@"SourcesBundle.bundle/music/%@.jpeg", dict[@"name"]]];
            cell.imageView.image = albumImage;
            cell.imageView.layer.cornerRadius = 8;
            cell.imageView.layer.masksToBounds = YES;
            break;
        }
    }
    return cell;
}

#pragma mark - UITableViewDelegate

// 点击后进入detailView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QMLikeDetailViewController *controller = [[QMLikeDetailViewController alloc] initWithIndex:indexPath.row
                                                                                     musicList:self.musicList];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}



#pragma mark - QMLikeDetailViewControllerDelegate

// 重载音乐列表
- (void)detailViewControllerWillDisappear:(UIViewController *)viewController {
    self.searchArray = [[NSMutableArray alloc] init];
    NSArray * pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * fileName = [pathArray[0] stringByAppendingPathComponent:@"music.plist"];
    self.musicList = [[NSArray alloc]initWithContentsOfFile:fileName];
    NSInteger i = 0;
    for (NSInteger j = 0; j < self.musicList.count; j++) {
        NSDictionary *dict = self.musicList[j];
        if ([dict[@"like"] intValue]) {
            NSString *searchIndex = [NSString stringWithFormat:@"%ld", i];
            NSDictionary *searchDict = [NSDictionary dictionaryWithObjectsAndKeys:searchIndex, @"index",
                                                                                  dict[@"name"], @"name",
                                                                                  dict[@"detail"], @"detail",
                                                                                  nil];
            [self.searchArray addObject:searchDict];
            i++;
        }
    }
    [self.tableView reloadData];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchView removeFromSuperview];
    self.searchView = nil;
}

// 点击时加载searchView
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar setShowsCancelButton:YES animated:YES];
    self.searchView = [[QMSearchView alloc] init];
    self.searchView.frame = CGRectMake(0, 148, self.view.frame.size.width, self.view.frame.size.height);
    self.searchView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.searchView];
    
    return YES;
}

// 改变输入的字符时刷新searchView
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self.searchView removeFromSuperview];
    self.searchView = [[QMSearchView alloc] initWithSearchArray:self.searchArray
                                                     searchName:searchText
                                                          frame:CGRectMake(0, 148, self.view.frame.size.width, self.view.frame.size.height)];
    self.searchView.delegate = self;
    [self.view addSubview:self.searchView];
}

#pragma mark - QMSearchViewDelegate
- (void)didSelectRowAtIndexPath:(NSInteger)index {
    QMLikeDetailViewController *controller = [[QMLikeDetailViewController alloc] initWithIndex:index
                                                                                     musicList:self.musicList];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:NO];
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
    [self.searchView removeFromSuperview];
    
}

@end
