//
//  QMSearchView.h
//  QMusic
//
//  Created by JiangNan on 2022/4/4.
//  Copyright © 2022 NanJiang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol QMSearchViewDelegate <NSObject>

/// 已经选中了searchView里面的cell
/// @param index 原来array里面的序号（不是点击cell的序号）
- (void)didSelectRowAtIndexPath:(NSInteger)index;

@end


/// 搜索后出现的视图
@interface QMSearchView : UIView
@property(nonatomic, weak) id<QMSearchViewDelegate> delegate;

/// 初始化searchView
/// @param searchArray 要搜索的音乐列表
/// @param searchNameSuper 要搜索的内容
/// @param frame view的大小位置
- (instancetype)initWithSearchArray:(NSMutableArray<NSDictionary *> *)searchArray searchName:(NSString *)searchNameSuper frame:(CGRect)frame;
@end

NS_ASSUME_NONNULL_END
