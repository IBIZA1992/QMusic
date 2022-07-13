//
//  QMMusicViewController.h
//  QMusic
//
//  Created by JiangNan on 2022/3/29.
//  Copyright © 2022 NanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "QMLyricEach.h"

NS_ASSUME_NONNULL_BEGIN

/// 播放音乐的界面（第二屏）
@interface QMMusicView : UIView

/// 初始化音乐界面
/// @param playerSuper 控制播放的player
/// @param imageFM 音乐的封面
/// @param metaDataArray 该音乐的信息数组
/// @param lyricEachSuper 该音乐歌词解析后数组
- (instancetype)initWithMusic:(AVAudioPlayer *)playerSuper
                        cover:(UIImage *)imageFM
                         data:(NSArray *)metaDataArray
                        lyric:(NSMutableArray<QMLyricEach *> *)lyricEachSuper;

@end

NS_ASSUME_NONNULL_END
