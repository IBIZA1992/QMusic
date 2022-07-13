//
//  QMLyricEach.h
//  QMusic
//
//  Created by JiangNan on 2022/3/31.
//  Copyright © 2022 NanJiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 储存每一句歌词
@interface QMLyricEach : NSObject
@property(nonatomic, assign) CGFloat time;
@property(nonatomic,strong) NSString *sentence;
@end

NS_ASSUME_NONNULL_END
