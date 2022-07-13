//
//  QMLyricView.m
//  QMusic
//
//  Created by JiangNan on 2022/3/31.
//  Copyright © 2022 NanJiang. All rights reserved.
//

#import "QMLyricView.h"

@interface QMLyricView ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) UIImageView *controllMusic;
@property (strong, nonatomic) UIImage *playImage;
@property (strong, nonatomic) UIImage *pauseImage;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<QMLyricEach *> *lyricEach;
@property (nonatomic, assign)NSInteger currentRow;
@property (nonatomic, assign)NSInteger perCurrentRow;
@end

@implementation QMLyricView

- (instancetype)initWithData:(NSArray *)metaDataArray
                      player:(AVAudioPlayer *)playerSuper
                       lyric:(NSMutableArray<QMLyricEach *> *)lyricEachSuper
{
    self = [super init];
    
    if (self) {
        // 导入信息
        _player = playerSuper;
        _lyricEach = lyricEachSuper;
        
        
        // 设置歌曲名称和歌手标签
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 93, 374, 65)];
        nameLabel.font = [UIFont boldSystemFontOfSize:26];
        [self addSubview:nameLabel];
        UILabel *singerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, 374, 21)];
        singerLabel.alpha = 0.8;
        [self addSubview:singerLabel];
        for (AVMutableMetadataItem *item in metaDataArray) {
            if ([(NSString *)item.key isEqualToString:@"TIT2"]) {
                nameLabel.text = (NSString *)item.value;
            }
            if ([(NSString *)item.key isEqualToString:@"TPE1"]) {
                singerLabel.text = [NSString stringWithFormat:@"%@", (NSString*)item.value];
            }
        }
         
        
        
        // 设置播放/暂停按钮
        _controllMusic = [[UIImageView alloc] initWithFrame:CGRectMake(330, 756, 64, 64)];
        _controllMusic.userInteractionEnabled = YES;
        _playImage = [UIImage imageNamed:@"SourcesBundle.bundle/icon/play.circle.fill@2x.png"];
        _pauseImage = [UIImage imageNamed:@"SourcesBundle.bundle/icon/pause.circle.fill@2x.png"];
        [_controllMusic setImage:_playImage];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controllMusicClick)];
        tapGesture.delegate = self;
        [_controllMusic addGestureRecognizer:tapGesture];
        [self addSubview:_controllMusic];
        
        
        
        // 定时器监听
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                      target:self
                                                    selector:@selector(observer)
                                                    userInfo:nil
                                                     repeats:YES];
        
        
        
        // 设置歌词滚动界面
        _tableView = [[UITableView alloc] init];
        _tableView.frame = CGRectMake(20, 189, 374, 536);
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;  // 隐藏分割线
        _tableView.showsVerticalScrollIndicator = NO;  // 隐藏滚动条
        [self addSubview:_tableView];
    }
    
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.lyricEach.count + 11;  // 最后过渡更自热，逐渐溜走的感觉
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"id"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;  // 避免点击歌词高亮
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"id"];
    }
    if (indexPath.row == self.currentRow) {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:24];
        cell.textLabel.alpha = 1;
        cell.textLabel.numberOfLines = 0;  // 使字体可以实现两行
    }
    else {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.alpha = 0.6;
        cell.textLabel.numberOfLines = 0;
    }
    
    if (indexPath.row < self.lyricEach.count) {  // 防止后面读出去了（越界异常）
        cell.textLabel.text = self.lyricEach[indexPath.row].sentence;
    } else {
        cell.textLabel.text = @"";
    }
    return cell;
}

#pragma mark - UITableViewDelegate
// 点击歌词切换
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.lyricEach.count) {
        self.player.currentTime = self.lyricEach[indexPath.row].time;
    }
}

#pragma mark - 点击controllMusic

- (void)controllMusicClick {
    if (self.player.playing) {
        [self.player pause];
        [self.controllMusic setImage:self.playImage];
    } else {
        [self.player play];
        [self.controllMusic setImage:self.pauseImage];
    }
}

#pragma mark - timer观察

- (void)observer
{
    // 观察按钮
    if (self.player.playing) {
        [self.controllMusic setImage:self.pauseImage];
    } else {
        [self.controllMusic setImage:self.playImage];
    }
    
    // 观察歌词（歌词自动切换）
    for (int i = 0; i < (int)self.lyricEach.count; i++) {
        if (self.player.currentTime > self.lyricEach[i].time) {
            self.currentRow = i;
        } else {
            break;
        }
    }
    
    // 只有切换歌词时才刷新，防止刷新过快不能切换歌词
    if (self.perCurrentRow != self.currentRow) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentRow inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];  // 移动
        [self.tableView reloadData];  // 刷新列表
        self.perCurrentRow = self.currentRow;
    }
}

@end
