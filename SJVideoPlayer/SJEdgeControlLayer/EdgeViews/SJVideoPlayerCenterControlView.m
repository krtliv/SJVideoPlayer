//
//  SJVideoPlayerCenterControlView.m
//  SJVideoPlayerProject
//
//  Created by BlueDancer on 2017/12/4.
//  Copyright © 2017年 SanJiang. All rights reserved.
//

#import "SJVideoPlayerCenterControlView.h"
#if __has_include(<Masonry/Masonry.h>)
#import <Masonry/Masonry.h>
#else
#import "Masonry.h"
#endif
#if __has_include(<SJAttributesFactory/SJAttributeWorker.h>)
#import <SJAttributesFactory/SJAttributeWorker.h>
#else
#import "SJAttributeWorker.h"
#endif
#if __has_include(<SJUIFactory/SJUIFactory.h>)
#import <SJUIFactory/SJUIFactory.h>
#else
#import "SJUIFactory.h"
#endif
#import "UIView+SJVideoPlayerSetting.h"

@interface SJVideoPlayerCenterControlView ()

@property (nonatomic, strong, readonly) UIButton *failedBtn;
@property (nonatomic, strong, readonly) UIButton *replayBtn;
@property (nonatomic, strong, readonly) UIButton *playBtn;
@property (nonatomic, strong, readonly) UIButton *pauseBtn;
@end

@implementation SJVideoPlayerCenterControlView
@synthesize failedBtn = _failedBtn;
@synthesize replayBtn = _replayBtn;
@synthesize playBtn = _playBtn;
@synthesize pauseBtn = _pauseBtn;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if ( !self ) return nil;
    [self _centerSetupView];
    [self _centerSettings];
    self.playState = NO;
    return self;
}

- (CGSize)intrinsicContentSize {
    CGFloat w = ceil(SJScreen_Min() * 0.382);
    return CGSizeMake(w, w);
}

- (void)clickedBtn:(UIButton *)btn {
    if ( ![_delegate respondsToSelector:@selector(centerControlView:clickedBtnTag:)] ) return;
    [_delegate centerControlView:self clickedBtnTag:btn.tag];
}

- (void)failedState {
    self.replayBtn.hidden = YES;
    self.playBtn.hidden = YES;
    self.pauseBtn.hidden = YES;
    self.failedBtn.hidden = NO;
}

- (void)replayState {
    self.failedBtn.hidden = YES;
    self.playBtn.hidden = YES;
    self.pauseBtn.hidden = YES;
    self.replayBtn.hidden = NO;
}

- (void)setPlayState:(BOOL)playState {
    _playState = playState;
    
    self.replayBtn.hidden = YES;
    self.failedBtn.hidden = YES;
    self.pauseBtn.hidden = YES;
    self.playBtn.hidden = YES;

    [UIView animateWithDuration:0.3 animations:^{
        if ( playState ) {
            self.pauseBtn.hidden = NO;
            self.playBtn.alpha = 0.001;
            self.pauseBtn.alpha = 1;
        }
        else {
            self.playBtn.hidden = NO;
            self.playBtn.alpha = 1;
            self.pauseBtn.alpha = 0.001;
        }
    }];
}

- (void)_centerSetupView {
    [self addSubview:self.failedBtn];
    [self addSubview:self.replayBtn];
    [self addSubview:self.playBtn];
    [self addSubview:self.pauseBtn];
    
    [_pauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.centerY.equalTo(self);
        make.center.centerX.equalTo(self);
        make.size.offset(74);
    }];
    [_playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.centerY.equalTo(self);
        make.center.centerX.equalTo(self);
        make.size.offset(74);
    }];
    [_failedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    [_replayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.centerY.equalTo(self);
        make.center.centerX.equalTo(self);
        make.size.offset(74);
    }];
}

- (UIButton *)failedBtn {
    if ( _failedBtn ) return _failedBtn;
    _failedBtn = [SJUIButtonFactory buttonWithImageName:@"" target:self sel:@selector(clickedBtn:) tag:SJVideoPlayerCenterViewTag_Failed];
    return _failedBtn;
}
- (UIButton *)replayBtn {
    if ( _replayBtn ) return _replayBtn;
    _replayBtn = [SJUIButtonFactory buttonWithImageName:@"" target:self sel:@selector(clickedBtn:) tag:SJVideoPlayerCenterViewTag_Replay];
    _replayBtn.titleLabel.numberOfLines = 0;
    return _replayBtn;
}

- (UIButton *)playBtn {
    if ( _playBtn ) return _playBtn;
    _playBtn = [SJUIButtonFactory buttonWithImageName:@"" target:self sel:@selector(clickedBtn:) tag:SJVideoPlayerCenterViewTag_Play];
    return _playBtn;
}

- (UIButton *)pauseBtn {
    if ( _pauseBtn ) return _pauseBtn;
    _pauseBtn = [SJUIButtonFactory buttonWithImageName:@"" target:self sel:@selector(clickedBtn:) tag:SJVideoPlayerCenterViewTag_Pause];
    return _pauseBtn;
}

- (void)_centerSettings {
    __weak typeof(self) _self = self;
    self.settingRecroder = [[SJVideoPlayerControlSettingRecorder alloc] initWithSettings:^(SJEdgeControlLayerSettings * _Nonnull setting) {
        __strong typeof(_self) self = _self;
        if ( !self ) return;

        [self.replayBtn setAttributedTitle:sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
            if ( setting.replayBtnImage ) {
                make.insert(setting.replayBtnImage, 0, CGPointZero, setting.replayBtnImage.size);
            }
            if ( setting.replayBtnImage && 0 != setting.replayBtnTitle.length ) {
                make.insertText(@"\n", -1);
            }
            
            if ( 0 != setting.replayBtnTitle.length ) {
                make.insert([NSString stringWithFormat:@"%@", setting.replayBtnTitle], -1);
                make.lastInserted(^(SJAttributesRangeOperator * _Nonnull lastOperator) {
                    lastOperator
                    .font(setting.replayBtnFont)
                    .textColor(setting.replayBtnTitleColor);
                });
            }
            make.alignment(NSTextAlignmentCenter).lineSpacing(6);
        }) forState:UIControlStateNormal];
        
        
        [self.failedBtn setAttributedTitle:sj_makeAttributesString(^(SJAttributeWorker * _Nonnull make) {
            if ( setting.playFailedBtnImage ) {
                make.insert(setting.playFailedBtnImage, 0, CGPointZero, setting.playFailedBtnImage.size);
            }
            if ( setting.playFailedBtnImage && 0 != setting.playFailedBtnTitle.length ) {
                make.insertText(@"\n", -1);
            }
            
            if ( 0 != setting.playFailedBtnTitle.length ) {
                make.insert([NSString stringWithFormat:@"%@", setting.playFailedBtnTitle], -1);
                make.lastInserted(^(SJAttributesRangeOperator * _Nonnull lastOperator) {
                    lastOperator
                    .font(setting.playFailedBtnFont)
                    .textColor(setting.playFailedBtnTitleColor);
                });
            }
            make.alignment(NSTextAlignmentCenter).lineSpacing(6);
        }) forState:UIControlStateNormal];

        [self.playBtn setImage:setting.playCenterBtnImage forState:UIControlStateNormal];
        [self.pauseBtn setImage:setting.pauseCenterBtnImage forState:UIControlStateNormal];
        
    }];
}

@end
