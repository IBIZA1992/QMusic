//
//  QMMusicViewController.m
//  QMusic
//
//  Created by JiangNan on 2022/3/29.
//  Copyright © 2022 NanJiang. All rights reserved.
//

#import "QMMusicView.h"
#import <AVFoundation/AVFoundation.h>

@interface QMMusicView ()<AVAudioPlayerDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) AVAudioPlayer *player;
@property (strong, nonatomic) UIImageView *controllMusic;
@property (strong, nonatomic) UIImage *playImage;
@property (strong, nonatomic) UIImage *pauseImage;
@property (strong, nonatomic) UISlider *slider;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) UILabel *leftLabel;
@property (strong, nonatomic) UILabel *rightLabel;
@property (strong, nonatomic) UILabel *lyricLabel;
@property (strong, nonatomic) NSMutableArray<QMLyricEach *> *lyricEach;
@property (nonatomic, assign)NSInteger currentRow;
@property (nonatomic, assign)NSInteger perCurrentRow;
@end

@implementation QMMusicView

- (instancetype)initWithMusic:(AVAudioPlayer *)playerSuper
                        cover:(UIImage *)imageFM
                         data:(NSArray *)metaDataArray
                        lyric:(NSMutableArray<QMLyricEach *> *)lyricEachSuper
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];

        
        
        // 设置专辑封面
        UIImageView *imageViewFM = [[UIImageView alloc] initWithFrame:CGRectMake(18, 136, 378, 378)];
        imageViewFM.image = imageFM;
        imageViewFM.layer.cornerRadius = 15;
        imageViewFM.layer.masksToBounds = YES;
        [self addSubview:imageViewFM];
        
        
        
        // 设置歌曲
        _player = playerSuper;
        
        
        
        // 设置播放/暂停按钮
        _controllMusic = [[UIImageView alloc] initWithFrame:CGRectMake(171, 752, 72, 72)];
        _controllMusic.userInteractionEnabled = YES;
        _playImage = [UIImage imageNamed:@"SourcesBundle.bundle/icon/play.circle@2x.png"];
        _pauseImage = [UIImage imageNamed:@"SourcesBundle.bundle/icon/pause.circle@2x.png"];
        [_controllMusic setImage:_playImage];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(controllMusicClick)];
        tapGesture.delegate = self;
        [_controllMusic addGestureRecognizer:tapGesture];
        [self addSubview:_controllMusic];
        
        
        
        // 定时器监听
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.005
                                                      target:self
                                                    selector:@selector(observer)
                                                    userInfo:nil
                                                     repeats:YES];
        
        
        
        // 滑动
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(18, 687, 378, 15)];
        _slider.minimumValue = 0.0;
        _slider.maximumValue = _player.duration;
        [_slider addTarget:self
                    action:@selector(slideProgress)
            forControlEvents:UIControlEventValueChanged];
        [self addSubview:_slider];
        
        
        
        // 标签
        // 时间标签
        _leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 712, 100, 21)];
        _leftLabel.text = @"00:00";
        _leftLabel.alpha = 0.65;
        [self addSubview:_leftLabel];
        _rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(352, 712, 100, 21)];
        NSString *allMusicTime = [self timeFormatted:_player.duration];
        _rightLabel.text = allMusicTime;
        _rightLabel.alpha = 0.65;
        [self addSubview:_rightLabel];
        // 歌曲信息标签
        UILabel *lblName = [[UILabel alloc] initWithFrame:CGRectMake(20, 554, 374, 71)];
        lblName.font = [UIFont boldSystemFontOfSize:26];
        [self addSubview:lblName];
        UILabel *lblSinger = [[UILabel alloc] initWithFrame:CGRectMake(20, 605, 374, 34)];
        lblSinger.alpha = 0.7;
        [self addSubview:lblSinger];
        for (AVMutableMetadataItem *item in metaDataArray) {
            if ([(NSString *)item.key isEqualToString:@"TIT2"]) {
                lblName.text = (NSString *)item.value;
            }
            if ([(NSString *)item.key isEqualToString:@"TPE1"]) {
                lblSinger.text = (NSString*)item.value;
            }
        }
        // 歌词标签
        _lyricLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 633, 374, 34)];
        [self addSubview:_lyricLabel];
        
        
        
        
        // 载入歌词
        _lyricEach = lyricEachSuper;
        
        
        
        // 默认播放
        [_player play];
    }
    return self;
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

#pragma mark - 转化时间格式
- (NSString *)timeFormatted:(int)totalSeconds {
    //将秒数转换为时间
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:totalSeconds];
    //设置时间格式
    NSDateFormatter *dateFormmatter = [[NSDateFormatter alloc] init];
    dateFormmatter.dateFormat = @"mm:ss";
    NSString *time = [dateFormmatter stringFromDate:date];
    return time;
}

#pragma mark - timer观察

- (void)observer {
    // 观察时间
    self.slider.value = self.player.currentTime;
    NSString *curren = [self timeFormatted:self.player.currentTime];
    self.leftLabel.text = curren;
    // 观察controllMusic状态
    if (self.player.playing) {
        [self.controllMusic setImage:self.pauseImage];
    } else {
        [self.controllMusic setImage:self.playImage];
    }
    // 观察歌词
    for (int i = 0; i < (int)self.lyricEach.count; i++) {
        if (self.player.currentTime > self.lyricEach[i].time) {
            self.currentRow = i;
        } else {
            break;
        }
    }
    
    // 只有切换歌词时蔡刷新，防止刷新过快不能切换歌词
    if (self.currentRow == 0) {  // 刚开始实现歌词，否则从第二句开始实现
        self.lyricLabel.text = self.lyricEach[self.currentRow].sentence;
        self.perCurrentRow = self.currentRow;
    } else if (self.perCurrentRow != self.currentRow) {
        self.lyricLabel.text = self.lyricEach[self.currentRow].sentence;
        self.perCurrentRow = self.currentRow;
    }
}

#pragma mark - 拖动进度条
- (void)slideProgress {
    self.player.currentTime = self.slider.value;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}


@end
