//
//  QMDataView.h
//  QMusic
//
//  Created by JiangNan on 2022/3/30.
//  Copyright © 2022 NanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 音乐详情的界面（第一屏）
@interface QMDataView : UIView
@property (nonatomic, strong) UILabel *labelInformation;  // 调整粘贴位置，使注释位置合适

/// 初始化详情界面
/// @param metaDataArray 该音乐的信息数组
- (instancetype)initWithData:(NSArray *)metaDataArray;
@end

NS_ASSUME_NONNULL_END
