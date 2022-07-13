//
//  QMDetailViewController.m
//  QMusic
//
//  Created by JiangNan on 2022/3/30.
//  Copyright © 2022 NanJiang. All rights reserved.
//

#import "QMListDetailViewController.h"
#import "QMMusicView.h"
#import "QMDataView.h"
#import <GameplayKit/GameplayKit.h>
#import "QMLyricView.h"

@interface QMListDetailViewController ()<UIScrollViewDelegate, UIGestureRecognizerDelegate, AVAudioPlayerDelegate>
@property (nonatomic, strong) QMDataView *dataView;
@property (nonatomic, strong) UIImageView *backMusic;
@property (nonatomic, strong) UIImageView *forwardMusic;
@property (nonatomic, strong) UIImageView *switchMusic;
@property (nonatomic, strong) UIImageView *likeMusic;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) UIImage *albumImage;
@property (nonatomic, strong) UIImage *repeatImage;
@property (nonatomic, strong) UIImage *repeatOnceImage;
@property (nonatomic, strong) UIImage *shuffleImage;
@property (nonatomic, strong) UIImage *likeMusicImage;
@property (nonatomic, strong) UIImage *unlikeMusicImage;
@property (nonatomic, strong) NSURL *musicURL;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) QMMusicView *musicView;
@property (nonatomic, strong) QMLyricView *lyricView;
@property (nonatomic, assign) NSInteger musicArrayIndex;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *musicArray;
@property (nonatomic, assign) NSInteger switchMusicIndex;
@property (nonatomic, assign) NSInteger isLikeMusic;
@property (nonatomic, strong) NSString *musicName;
@property (strong, nonatomic) NSString *lyricString;
@property (strong, nonatomic) NSArray *lyricLines;
@property (strong, nonatomic) NSMutableArray<QMLyricEach *> *lyricEach;
@property (strong, nonatomic) UILabel *leftNavigationLabel;
@property (strong, nonatomic) UILabel *middleNavigationLabel;
@property (strong, nonatomic) UILabel *rightNavigationLabel;
@property (strong, nonatomic) NSArray<NSNumber *> *shuffleIndexArray;
@property (nonatomic, assign) NSInteger shuffleMusicArrayIndex;
@end

@implementation QMListDetailViewController

- (instancetype)initWithIndex:(NSInteger)indexMain musicList:(NSArray *)musicListMain {
    self = [super init];
    if (self) {
        _musicArrayIndex = indexMain;
        
        // 转为均可变
        _musicArray = [[NSMutableArray alloc] init];
        for (NSDictionary * item in musicListMain) {
            NSMutableDictionary *mutableItem = [NSMutableDictionary dictionaryWithDictionary:item];
            [_musicArray addObject:mutableItem];
        }
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    
    // 设置navigationBar上的文字
    UILabel *navigationItemLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, self.view.frame.size.width - 200, 88)];
    navigationItemLabel.textAlignment = NSTextAlignmentCenter;
    [self.navigationItem setTitleView:navigationItemLabel];
    
    self.leftNavigationLabel = [[UILabel alloc] initWithFrame:CGRectMake(37, 13, 35, 21)];
    self.leftNavigationLabel.text = @"详情";
    self.leftNavigationLabel.alpha = 0.5;
    [navigationItemLabel addSubview:self.leftNavigationLabel];
    
    self.rightNavigationLabel = [[UILabel alloc] initWithFrame:CGRectMake(143, 13, 35, 21)];
    self.rightNavigationLabel.text = @"歌词";
    self.rightNavigationLabel.alpha = 0.5;
    [navigationItemLabel addSubview:self.rightNavigationLabel];
    
    self.middleNavigationLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 13, 35, 21)];
    self.middleNavigationLabel.text = @"歌曲";
    [navigationItemLabel addSubview:self.middleNavigationLabel];
    
    

    // 设置滚动界面(三屏)
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width * 3, 0);
    self.scrollView.contentOffset = CGPointMake(self.view.bounds.size.width, 0);
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    
    
    // 设置控制播放功能按钮
    // 后退（上一曲）
    self.backMusic = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width + 95.5, 688, 24, 24)];
    self.backMusic.userInteractionEnabled = YES;
    UIImage *imageLeft = [UIImage imageNamed:@"SourcesBundle.bundle/icon/buttonLeft@2x.png"];
    [self.backMusic setImage:imageLeft];
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backMusicClick)];
    tapGesture1.delegate = self;
    [self.backMusic addGestureRecognizer:tapGesture1];
    
    // 前进（下一曲）
    self.forwardMusic = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width + 294.5, 688, 24, 24)];
    self.forwardMusic.userInteractionEnabled = YES;
    UIImage *imageRight = [UIImage imageNamed:@"SourcesBundle.bundle/icon/buttonRight@2x.png"];
    [self.forwardMusic setImage:imageRight];
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forwardMusicClick)];
    tapGesture2.delegate = self;
    [self.forwardMusic addGestureRecognizer:tapGesture2];
    
    // 切换播放模式
    self.switchMusic = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width + 20, 688, 24, 24)];
    self.switchMusic.userInteractionEnabled = YES;
    self.repeatImage = [UIImage imageNamed:@"SourcesBundle.bundle/icon/repeat@2x.png"];
    self.repeatOnceImage = [UIImage imageNamed:@"SourcesBundle.bundle/icon/repeat.1@2x.png"];
    self.shuffleImage = [UIImage imageNamed:@"SourcesBundle.bundle/icon/shuffle@2x.png"];
    [self.switchMusic setImage:self.repeatImage];  // 默认列表循环
    UITapGestureRecognizer *tapGesture3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchMusicClick)];
    tapGesture3.delegate = self;
    [self.switchMusic addGestureRecognizer:tapGesture3];
    
    // 喜欢
    self.likeMusic = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width + 370, 688, 24, 24)];
    self.likeMusic.userInteractionEnabled = YES;
    self.likeMusicImage = [UIImage imageNamed:@"SourcesBundle.bundle/icon/heart.fill@2x.png"];
    self.unlikeMusicImage = [UIImage imageNamed:@"SourcesBundle.bundle/icon/heart@2x.png"];
    UITapGestureRecognizer *tapGesture4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(likeMusicClick)];
    tapGesture4.delegate = self;
    [self.likeMusic addGestureRecognizer:tapGesture4];
    
    
    
    // 加载音乐
    [self loadMusic];
    
    
    
    // 粘贴按钮
    [self.scrollView addSubview:self.backMusic];
    [self.scrollView addSubview:self.forwardMusic];
    [self.scrollView addSubview:self.switchMusic];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self.player stop];
    self.player = nil;
    
    [self.musicView removeFromSuperview];
    [self.dataView removeFromSuperview];
    [self.lyricView removeFromSuperview];
    
    // 委托刷新列表
    if (self.delegate && [self.delegate respondsToSelector:@selector(detailViewControllerWillDisappear:)]) {
        [self.delegate detailViewControllerWillDisappear:self];
    }
}

#pragma mark - 点击操作

#pragma mark 点击switch

- (void)switchMusicClick {
    long i = self.switchMusicIndex;
    i++;
    if (i % 3 == 0) {
        [self.switchMusic setImage:self.repeatImage];  // 设置列表循环
    } else if (i % 3 == 1) {
        [self.switchMusic setImage:self.repeatOnceImage];  // 设置单曲循环
    } else {
        [self.switchMusic setImage:self.shuffleImage];  // 设置随机播放
        
        // 打乱引索顺序的数组
        NSMutableArray<NSNumber *> *indexArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.musicArray.count; i++) {
            [indexArray addObject:[[NSNumber alloc] initWithInt:i]];
        }
        self.shuffleIndexArray = [indexArray shuffledArray];
        
        for (NSInteger i = 0; i < self.musicArray.count; i++) {
            if (self.shuffleIndexArray[i].integerValue == self.musicArrayIndex) {
                self.shuffleMusicArrayIndex = i;
                break;
            }
        }
    }
    self.switchMusicIndex = i++;
}

#pragma mark 点击back

- (void)backMusicClick {
    
    if (self.switchMusicIndex % 3 == 2) {  // 随机播放
        if (self.shuffleMusicArrayIndex == 0) {
            self.shuffleMusicArrayIndex = self.musicArray.count - 1;
        } else {
            self.shuffleMusicArrayIndex--;
        }
        self.musicArrayIndex = self.shuffleIndexArray[self.shuffleMusicArrayIndex].integerValue;
        
        [self loadMusicAgain];

    } else {
        if (self.musicArrayIndex == 0) {
            self.musicArrayIndex = self.musicArray.count - 1;
        } else {
            self.musicArrayIndex--;
        }
        
        [self loadMusicAgain];
    }
    
}

#pragma mark 点击forward

- (void)forwardMusicClick {
    
    if (self.switchMusicIndex % 3 == 2) {  // 随机播放
        if (self.shuffleMusicArrayIndex == self.musicArray.count - 1) {
            self.shuffleMusicArrayIndex = 0;
        } else {
            self.shuffleMusicArrayIndex++;
        }
        self.musicArrayIndex = self.shuffleIndexArray[self.shuffleMusicArrayIndex].integerValue;

        [self loadMusicAgain];
    } else {
        if (self.musicArrayIndex == self.musicArray.count - 1) {
            self.musicArrayIndex = 0;
        } else {
            self.musicArrayIndex++;
        }

        [self loadMusicAgain];
    }
    
}

#pragma mark 点击like
- (void)likeMusicClick {
    if (self.isLikeMusic) {
        self.isLikeMusic = 0;  // 实现多次点击，否则只能显示一次！
        [self.likeMusic setImage:self.unlikeMusicImage];
        NSMutableDictionary *mutableDictionary = self.musicArray[self.musicArrayIndex];
        [mutableDictionary setObject:@"0" forKey:@"like"];
        [self.musicArray setObject:mutableDictionary atIndexedSubscript:self.musicArrayIndex];
        // 写入沙盒文件
        NSArray * pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        [self.musicArray writeToFile:[pathArray[0] stringByAppendingPathComponent:@"music.plist"] atomically:YES];
    } else {
        self.isLikeMusic = 1;
        [self.likeMusic setImage:self.likeMusicImage];
        NSMutableDictionary *mutableDictionary = self.musicArray[self.musicArrayIndex];
        [mutableDictionary setObject:@"1" forKey:@"like"];
        [self.musicArray setObject:mutableDictionary atIndexedSubscript:self.musicArrayIndex];
        // 写入沙盒文件
        NSArray * pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        [self.musicArray writeToFile:[pathArray[0] stringByAppendingPathComponent:@"music.plist"] atomically:YES];
    }
}

#pragma mark - AVAudioPlayerDelegate
// 播放结束后执行操作
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (self.switchMusicIndex % 3 == 1) {  // 单曲循环
        [self.player play];
    } else if (self.switchMusicIndex % 3 == 0) {  // 列表循环
        if (self.musicArrayIndex == self.musicArray.count - 1) {
            self.musicArrayIndex = 0;
        } else {
            self.musicArrayIndex++;
        }

        [self loadMusicAgain];
    } else {  // 随机播放
        if (self.shuffleMusicArrayIndex == self.musicArray.count - 1) {
            self.shuffleMusicArrayIndex = 0;
        } else {
            self.shuffleMusicArrayIndex++;
        }
        self.musicArrayIndex = self.shuffleIndexArray[self.shuffleMusicArrayIndex].integerValue;
        
        [self loadMusicAgain];
    }
}

#pragma mark - 加载音乐

// 根据索引载入音乐
- (void)loadMusic {
    
    NSDictionary *dict = self.musicArray[self.musicArrayIndex];
    self.musicName = dict[@"name"];
    self.isLikeMusic = [dict[@"like"] intValue];
    // 显示是否喜欢
    if (self.isLikeMusic) {
        [self.likeMusic setImage:self.likeMusicImage];
    } else {
        [self.likeMusic setImage:self.unlikeMusicImage];
    }
    
    // 根据名字载入歌曲
    self.musicURL = [[NSBundle mainBundle] URLForResource:[NSString stringWithFormat:@"SourcesBundle.bundle/music/%@.mp3", self.musicName] withExtension:nil];
    self.albumImage = [UIImage imageNamed:[NSString stringWithFormat:@"SourcesBundle.bundle/music/%@.jpeg", self.musicName]];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:self.musicURL error:nil];
    self.player.volume = 1;
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.musicURL options:nil];
    NSArray *formatArray = asset.availableMetadataFormats;
    NSString *format = formatArray.firstObject;
    NSArray *metaDataArray = [asset metadataForFormat:format];
    
    // 读取歌词信息
    for (AVMutableMetadataItem *item in metaDataArray) {
        if ([(NSString *)item.key isEqualToString:@"USLT"]) {
            self.lyricString = (NSString*)item.value;
        }
    }
    self.lyricLines = [self.lyricString componentsSeparatedByString:@"\r"]; // 不是/n是/r!
    self.lyricEach = [[NSMutableArray alloc] init];
    for (NSString *lrcF in self.lyricLines) {
        QMLyricEach *lrc = [[QMLyricEach alloc] init];
        NSArray *lrc1 = [lrcF componentsSeparatedByString:@"]"];   // ]分离
        NSArray *time1 = [lrc1[0] componentsSeparatedByString:@":"];  // 中间分离
        NSArray *time2 = [time1[0] componentsSeparatedByString:@"["];  // [分离
        lrc.time = (int)[time2[1] integerValue] * 60 + (float)[time1[1] floatValue] - 0.4;  // 储存时间
        lrc.sentence = lrc1[1];  // 储存句子
        [self.lyricEach addObject:lrc];
    }
    
    // 设置音乐界面
    // 设置数据界面（第一屏）
    self.dataView = [[QMDataView alloc] initWithData:metaDataArray];
        // 调整粘贴的位置
    self.dataView.frame = CGRectMake(0, -50, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    [self.scrollView addSubview:self.dataView];
    [self.dataView.labelInformation sizeToFit];
    
    // 设置音乐界面（第二屏）
    self.musicView = [[QMMusicView alloc] initWithMusic:self.player cover:self.albumImage data:metaDataArray lyric:self.lyricEach];
        //调整粘贴的位置
    self.musicView.frame = CGRectMake(self.scrollView.bounds.size.width, -88, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    [self.scrollView addSubview:self.musicView];
    
    // 设置音乐界面（第三屏）
    self.lyricView = [[QMLyricView alloc] initWithData:metaDataArray player:self.player lyric:self.lyricEach];
        // 调整粘贴位置
    self.lyricView.frame = CGRectMake(self.scrollView.bounds.size.width * 2, -77, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height);
    [self.scrollView addSubview:self.lyricView];
    self.player.delegate = self;
    [self.scrollView addSubview:self.likeMusic];
}

- (void)loadMusicAgain {
    
    // 停止播放
    [self.player stop];
    self.player = nil;
    
    // 移除view
    [self.musicView removeFromSuperview];
    [self.dataView removeFromSuperview];
    [self.lyricView removeFromSuperview];

    [self loadMusic];

    // 添加view
    [self.scrollView addSubview:self.backMusic];
    [self.scrollView addSubview:self.forwardMusic];
    [self.scrollView addSubview:self.switchMusic];
    
}

#pragma mark - UIScrollViewDelegate

// 刷新navigation上的标签
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    NSInteger page = self.scrollView.contentOffset.x / pageWidth;  // 判断第几页（从0开始）
    if (page == 0) {
        self.leftNavigationLabel.alpha = 1;
        self.middleNavigationLabel.alpha = 0.5;
        self.rightNavigationLabel.alpha = 0.5;
    } else if (page == 1) {
        self.leftNavigationLabel.alpha = 0.5;
        self.middleNavigationLabel.alpha = 1;
        self.rightNavigationLabel.alpha = 0.5;
    } else {
        self.leftNavigationLabel.alpha = 0.5;
        self.middleNavigationLabel.alpha = 0.5;
        self.rightNavigationLabel.alpha = 1;
    }
}

@end
