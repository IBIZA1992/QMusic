//
//  QMLyricView.h
//  QMusic
//
//  Created by JiangNan on 2022/3/31.
//  Copyright © 2022 NanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "QMMusicView.h"
#import <Foundation/Foundation.h>
#import "QMLyricEach.h"

NS_ASSUME_NONNULL_BEGIN

/// 音乐歌词的界面（第三屏）
@interface QMLyricView : UIView

/// 初始化音乐歌词界面
/// @param metaDataArray 该音乐的信息数组
/// @param playerSuper 控制播放的player
/// @param lyricEachSuper 该音乐歌词解析后数组
- (instancetype)initWithData:(NSArray *)metaDataArray
                      player:(AVAudioPlayer *)playerSuper
                       lyric:(NSMutableArray<QMLyricEach *> *)lyricEachSuper;
@end

NS_ASSUME_NONNULL_END
