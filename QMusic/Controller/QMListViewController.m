//
//  QMListViewController.m
//  QMusic
//
//  Created by JiangNan on 2022/3/29.
//  Copyright © 2022 NanJiang. All rights reserved.
//

#import "QMListViewController.h"
#import "QMListDetailViewController.h"
#import "QMTableViewCell.h"
#import "QMSearchView.h"

@interface QMListViewController ()<UITableViewDataSource, UITableViewDelegate, QMListDetailViewControllerDelegate, UISearchBarDelegate, QMSearchViewDelegate>
@property (nonatomic, strong) NSArray *musicList;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) QMSearchView *searchView;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *searchArray;
@end

@implementation QMListViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tabBarItem.title = @"歌曲";
        self.tabBarItem.image = [UIImage imageNamed:@"SourcesBundle.bundle/icon/list@2x.png"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"SourcesBundle.bundle/icon/list_selected@2x.png"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    // 加载tableView
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] init];  // 不显示底部空白cell
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;  // 隐藏分割线
    [self.view addSubview:self.tableView];
    
    
    
    // 导入歌曲信息
        // 写入歌曲（导入外部plist文件使用）
//    self.musicList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"music.plist" ofType:nil]];
//    NSMutableArray *testMusicList = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"music.plist" ofType:nil]];
//    NSArray * pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    [testMusicList writeToFile:[pathArray[0] stringByAppendingPathComponent:@"music.plist"] atomically:YES];
        // 加载歌曲
    NSArray * pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * fileName = [pathArray[0] stringByAppendingPathComponent:@"music.plist"];
    self.musicList = [[NSArray alloc]initWithContentsOfFile:fileName];
        // 初始化载入歌曲
    if (self.musicList == nil) {
        NSMutableArray *testMusicList = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"music.plist" ofType:nil]];
        [testMusicList writeToFile:[pathArray[0] stringByAppendingPathComponent:@"music.plist"] atomically:YES];
        self.musicList = [[NSArray alloc]initWithContentsOfFile:fileName];
    }

    
    
    // 加载搜索界面
    self.searchArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < self.musicList.count; i++) {
        NSDictionary *dict = self.musicList[i];
        NSString *searchIndex = [NSString stringWithFormat:@"%ld", i];
        NSDictionary *searchDict = [NSDictionary dictionaryWithObjectsAndKeys:searchIndex, @"index",
                                                                              dict[@"name"], @"name",
                                                                              dict[@"detail"], @"detail",
                                                                              nil];
        [self.searchArray addObject:searchDict];
    }
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.frame = CGRectMake(0, 0, self.view.bounds.size.width, 60);
    self.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchBar;
    
    
    
    // 加载navigationBar上的文字
    UILabel *navigationItemLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 88)];
    navigationItemLabel.text = @"全部歌曲";
    navigationItemLabel.font = [UIFont boldSystemFontOfSize:22];
    navigationItemLabel.textAlignment = NSTextAlignmentCenter;
    [self.tabBarController.navigationItem setTitleView:navigationItemLabel];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.musicList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
    if (!cell) {
        cell = [[QMTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"id"];
    }
    
    // 设置每个单元格
    NSDictionary *dict = self.musicList[indexPath.row];
    cell.textLabel.text = dict[@"name"];
    cell.detailTextLabel.text = dict[@"detail"];
    cell.detailTextLabel.alpha = 0.7;
    UIImage *albumImage = [UIImage imageNamed:[NSString stringWithFormat:@"SourcesBundle.bundle/music/%@.jpeg", dict[@"name"]]];
    cell.imageView.image = albumImage;
    cell.imageView.layer.cornerRadius = 8;
    cell.imageView.layer.masksToBounds = YES;
    return cell;
}

#pragma mark - UITableViewDelegate

// 点击后进入detailView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QMListDetailViewController *controller = [[QMListDetailViewController alloc] initWithIndex:indexPath.row
                                                                             musicList:self.musicList];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark - QMDetailViewControllerDelegate

// 重载音乐列表
- (void)detailViewControllerWillDisappear:(UIViewController *)viewController {
    NSArray * pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * fileName = [pathArray[0] stringByAppendingPathComponent:@"music.plist"];
    self.musicList = [[NSArray alloc]initWithContentsOfFile:fileName];
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
    QMListDetailViewController *controller = [[QMListDetailViewController alloc] initWithIndex:index
                                                                             musicList:self.musicList];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:NO];
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
    [self.searchView removeFromSuperview];
}

@end
