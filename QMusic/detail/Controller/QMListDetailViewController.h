//
//  QMDetailViewController.h
//  QMusic
//
//  Created by JiangNan on 2022/3/30.
//  Copyright © 2022 NanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol QMListDetailViewControllerDelegate <NSObject>

/// 歌曲页面即将消失
/// @param viewController 播放歌曲的那个页面
- (void)detailViewControllerWillDisappear:(UIViewController *)viewController;

@end

/// 点击tabelViewCell后进入的详情页，控制点开后的三个页面
@interface QMListDetailViewController : UIViewController

@property(nonatomic, weak) id<QMListDetailViewControllerDelegate> delegate;

/// 初始化页面
/// @param indexMain 最开始点击的cell的index
/// @param musicListMain 播放音乐的列表
- (instancetype)initWithIndex:(NSInteger)indexMain musicList:(NSArray *)musicListMain;

@end

NS_ASSUME_NONNULL_END
