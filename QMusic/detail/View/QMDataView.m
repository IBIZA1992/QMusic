//
//  QMDataView.m
//  QMusic
//
//  Created by JiangNan on 2022/3/30.
//  Copyright © 2022 NanJiang. All rights reserved.
//

#import "QMDataView.h"

@interface QMDataView ()

@end

@implementation QMDataView

- (instancetype)initWithData:(NSArray *)metaDataArray
{
    self = [super init];
    if (self) {
        // 设置label位置
        _labelInformation = [[UILabel alloc] initWithFrame:CGRectMake(20, 369, 374, 493)];
        _labelInformation.numberOfLines = 0;
        _labelInformation.alpha = 0.8;
        [self addSubview:_labelInformation];
        
        UILabel *labelName = [[UILabel alloc] initWithFrame:CGRectMake(20, 93, 374, 65)];
        labelName.font = [UIFont boldSystemFontOfSize:26];
        [self addSubview:labelName];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, 166, 374, 21)];
        label1.alpha = 0.8;
        [self addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, 195, 374, 21)];
        label2.alpha = 0.8;
        [self addSubview:label2];
        
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(20, 224, 374, 21)];
        label3.alpha = 0.8;
        [self addSubview:label3];
        
        UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(20, 253, 374, 21)];
        label4.alpha = 0.8;
        [self addSubview:label4];
        
        UILabel *label5 = [[UILabel alloc] initWithFrame:CGRectMake(20, 282, 374, 21)];
        label5.alpha = 0.8;
        [self addSubview:label5];
        
        UILabel *label6 = [[UILabel alloc] initWithFrame:CGRectMake(20, 311, 374, 21)];
        label6.alpha = 0.8;
        [self addSubview:label6];
        
        UILabel *label7 = [[UILabel alloc] initWithFrame:CGRectMake(20, 340, 374, 21)];
        label7.alpha = 0.8;
        [self addSubview:label7];
        
        
        
        // 读取歌曲信息
        for (AVMutableMetadataItem *item in metaDataArray) {
            if ([(NSString *)item.key isEqualToString:@"TIT2"]) {
                labelName.text = (NSString *)item.value;
            }
            if ([(NSString *)item.key isEqualToString:@"TPE1"]) {
                label1.text = [NSString stringWithFormat:@"演唱者：%@", (NSString*)item.value];
            }
            if ([(NSString *)item.key isEqualToString:@"TPE2"]) {
                label2.text = [NSString stringWithFormat:@"作词：%@", (NSString*)item.value];
            }
            if ([(NSString *)item.key isEqualToString:@"TCOM"]) {
                label3.text = [NSString stringWithFormat:@"作曲：%@", (NSString*)item.value];
            }
            if ([(NSString *)item.key isEqualToString:@"TALB"]) {
                label4.text = [NSString stringWithFormat:@"专辑：%@", (NSString*)item.value];
            }
            if ([(NSString *)item.key isEqualToString:@"TCON"]) {
                label5.text = [NSString stringWithFormat:@"类型：%@", (NSString*)item.value];
            }
            if ([(NSString *)item.key isEqualToString:@"TYER"]) {
                label6.text = [NSString stringWithFormat:@"年代：%@", (NSString*)item.value];
            }
            if ([(NSString *)item.key isEqualToString:@"TBPM"]) {
                label7.text = [NSString stringWithFormat:@"BPM：%@", (NSString*)item.value];
            }
            if ([(NSString *)item.key isEqualToString:@"COMM"]) {
                self.labelInformation.text = [NSString stringWithFormat:@"简介：\n        %@", (NSString*)item.value];
            }
        }
        
    }
    return self;
}

@end
