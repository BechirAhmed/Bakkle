//
// MDCSwipeToChooseView.m
//
// Copyright (c) 2014 to present, Brian Gesiak @modocache
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "MDCSwipeToChooseView.h"
#import "MDCSwipeToChoose.h"
#import "MDCGeometry.h"
#import "UIView+MDCBorderedLabel.h"
#import "UIColor+MDCRGB8Bit.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const MDCSwipeToChooseViewHorizontalPadding = 10.f;
static CGFloat const MDCSwipeToChooseViewTopPadding = 20.f;
static CGFloat const MDCSwipeToChooseViewLabelHeight = 65.f;


@interface MDCSwipeToChooseView ()
@property (nonatomic, strong) MDCSwipeToChooseViewOptions *options;
@end

@implementation MDCSwipeToChooseView

#pragma mark - Object Lifecycle

/*
 *              GET BACK TO THIS. THIS IS FOR THE FEED CONSTRAINTS AND UI.
 */



- (instancetype)initWithFrame:(CGRect)frame
                      options:(MDCSwipeToChooseViewOptions *)options tutorial:(BOOL)tutorial goodwill:(BOOL)goodwill ipad:(BOOL)ipad{
    
    self = [super initWithFrame: frame];
    if (self) {
        _options = options ? options : [MDCSwipeToChooseViewOptions new];
        self.ipad = ipad;
        self.tutorial = tutorial;
        [self setupView];
        [self constructBlurBackground];
        if (tutorial) {
            [self constructInstructionImageView];
        }else {
            [self constructImageView];
//            [self constructTopUserInfoView];
            [self constructInformationView];
                    }
        [self constructLikedView];
        [self constructNopeImageView];
        if (!goodwill) {
            [self constructHoldView];
            [self constructReportView];
            [self setupSwipeToChoose];
        }else {
            [self setupSwipeToChooseGoodwill];
        }
        
        

    }
    return self;
}

#pragma mark - Internal Methods

- (void)setupView {
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 12.f;
    self.layer.masksToBounds = YES;
}

- (void)constructBlurBackground {
    UIVisualEffect *blur;
    blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView;
    effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    _bottomBlurImg = [[UIImageView alloc] initWithFrame:self.bounds];
    effectView.frame = _bottomBlurImg.bounds;
    [_bottomBlurImg setContentMode:UIViewContentModeScaleAspectFill];
    _bottomBlurImg.clipsToBounds = YES;
    [_bottomBlurImg addSubview:effectView];
    [self addSubview:_bottomBlurImg];
}

- (void)constructInstructionImageView {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    [_imageView setContentMode:UIViewContentModeScaleAspectFill];
    _imageView.clipsToBounds = YES;
    [self addSubview:_imageView];
    
    _transparentImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _imageView.frame.size.width, _imageView.frame.size.height)];
    _transparentImage.backgroundColor = [UIColor blackColor];
    _transparentImage.alpha = 0.f;
    [_imageView addSubview:_transparentImage];
}

- (void)constructImageView {
    CGFloat yCoordinate = (self.bounds.size.height - self.bounds.size.width)/2;
    if (!_ipad) {
        yCoordinate = (self.bounds.size.height - self.bounds.size.width)/2;
    }
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width + yCoordinate)];
    [_imageView setContentMode:UIViewContentModeScaleAspectFill];
    _imageView.clipsToBounds = YES;
    [self addSubview:_imageView];
    
    
    _transparentImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _imageView.frame.size.width, _imageView.frame.size.height)];
    _transparentImage.backgroundColor = [UIColor blackColor];
    _transparentImage.alpha = 0.f;
    [_imageView addSubview:_transparentImage];
    
}

- (void)constructInformationView {
    CGFloat bottomHeight = (self.bounds.size.height - self.bounds.size.width);
    if (!_ipad){
        bottomHeight = (self.bounds.size.height - self.bounds.size.width)/2;
    }
    CGRect bottomFrame = CGRectMake(0,
                                    CGRectGetHeight(self.bounds) - bottomHeight,
                                    CGRectGetWidth(self.bounds),
                                    bottomHeight);
    _informationView = [[UIView alloc] initWithFrame:bottomFrame];
    
    
    _informationView.backgroundColor = [UIColor clearColor];
    _informationView.clipsToBounds = YES;
    _informationView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleTopMargin;
    
    if (_ipad) {
        [self addBlur:self.informationView];
    }
    
    [self addSubview:_informationView];
    
    [self constructNameLabel];
    [self constructPriceLabel];
}

//-(void)constructTopUserInfoView {
//    CGFloat topHeight = (self.bounds.size.height - self.bounds.size.width);
//    if (!_ipad){
//        topHeight = (self.bounds.size.height - self.bounds.size.width)/2;
//    }
//    
//    CGRect topFrame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), topHeight);
//    _topUserInfoView = [[UIView alloc] initWithFrame:topFrame];
//    _topUserInfoView.backgroundColor = [UIColor clearColor];
//    _topUserInfoView.clipsToBounds = YES;
//    _topUserInfoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//    
//    [self addSubview:_topUserInfoView];
//    
//    if (_ipad) {
//        [self addBlur:self.topUserInfoView];
//    }
//    
//    [self constructUserProfileImg];
//    [self constructSellersName];
//    //[self constructRatingView];
//    
//}

-(void)addBlur:(UIView *) view {
    UIVisualEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    UIImageView *bottomBlurImg = [[UIImageView alloc] initWithFrame:view.bounds];
    effectView.frame = bottomBlurImg.bounds;
    [bottomBlurImg setContentMode:UIViewContentModeScaleAspectFill];
    bottomBlurImg.clipsToBounds = YES;
    [bottomBlurImg addSubview:effectView];
    [view addSubview:bottomBlurImg];
}

//-(void)constructUserProfileImg {
//    CGFloat leftPadding = 11.f;
//    CGRect frame = CGRectMake(leftPadding, 0, 30, 30);
//    _profileImg = [[UIImageView alloc] initWithFrame:frame];
//    _profileImg.center = CGPointMake(leftPadding+20, CGRectGetHeight(_topUserInfoView.frame)/2);
//    _profileImg.layer.cornerRadius = _profileImg.frame.size.width/2;
//    _profileImg.layer.masksToBounds = YES;
//    _profileImg.layer.borderWidth = 2.0;
//    _profileImg.contentMode = UIViewContentModeScaleAspectFill;
//    UIColor *borderColor = [UIColor whiteColor];
//    _profileImg.layer.borderColor = borderColor.CGColor;
//    [_topUserInfoView addSubview:_profileImg];
//}

//-(void)constructSellersName {
//    CGRect frame = CGRectMake(_profileImg.frame.size.width + 24, 0, (_topUserInfoView.frame.size.width*3/4)-(_profileImg.frame.size.width + 10), CGRectGetHeight(_topUserInfoView.frame));
//    _sellerName = [[UILabel alloc] initWithFrame:frame];
//    _sellerName.text = [NSString stringWithFormat:@"%s", ""];
//    _sellerName.font = [UIFont fontWithName:@"Avenir-Black" size:23];
//    _sellerName.textColor = [UIColor whiteColor];
//    _sellerName.textAlignment = NSTextAlignmentLeft;
//    [_topUserInfoView addSubview:_sellerName];
//}

//-(void)constructRatingView {
//    CGRect frame = CGRectMake(CGRectGetWidth(_topUserInfoView.frame)*3/4 - 30, 0, 90, CGRectGetHeight(_topUserInfoView.frame));
//    _ratingView = [[RateView alloc] initWithFrame:frame];
//    
//    self.ratingView.notSelectedImage = [UIImage imageNamed:@"star_none.png"];
//    self.ratingView.halfSelectedImage = [UIImage imageNamed:@"star_half.png"];
//    self.ratingView.fullSelectedImage = [UIImage imageNamed:@"star_full.png"];
//    self.ratingView.editable = NO;
//    self.ratingView.maxRating = 5;
//    
//    [_topUserInfoView addSubview:_ratingView];
//    
//}

- (void)constructNameLabel {
    CGRect frame = CGRectMake(10,
                              0,
                              self.frame.size.width/4*3-5,
                              CGRectGetHeight(_informationView.frame));
    _nameLabel = [[UILabel alloc] initWithFrame:frame];
    _nameLabel.text = [NSString stringWithFormat:@"%s", ""];
    _nameLabel.font = [UIFont fontWithName:@"Avenir-Black" size:24];
    _nameLabel.numberOfLines = 1;
    _nameLabel.adjustsFontSizeToFitWidth = YES;
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.textAlignment = NSTextAlignmentLeft;
    [_informationView addSubview:_nameLabel];
}

- (void)constructPriceLabel {
    CGRect frame = CGRectMake(self.frame.size.width/4*3+5, 0, self.frame.size.width/4-10, CGRectGetHeight(_informationView.frame));
    _priceLabel = [[UILabel alloc] initWithFrame:frame];
    _priceLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:22];
    _priceLabel.numberOfLines = 1;
    _priceLabel.adjustsFontSizeToFitWidth = YES;
    _priceLabel.text = [NSString stringWithFormat:@"%s", ""];
    _priceLabel.textColor = [UIColor whiteColor];
    _priceLabel.textAlignment = NSTextAlignmentRight;
    [_informationView addSubview:_priceLabel];
}

- (void)constructHoldView {
    CGRect frame = CGRectMake(CGRectGetMidX(_imageView.bounds)/2,
                              self.bounds.size.height/2,
                              CGRectGetMidX(_imageView.bounds),
                              MDCSwipeToChooseViewLabelHeight);
    self.holdView = [[UIView alloc] initWithFrame:frame];
    [self.holdView constructBorderedLabelWithText:self.options.holdText
                                            color:self.options.holdColor
                                            angle:self.options.holdRotationAngle
                                         textSize:self.options.holdTextSize
     ];
    self.holdView.alpha = 0.f;
    [self.imageView addSubview:self.holdView];
}

- (void)constructReportView {
    CGRect frame = CGRectMake(CGRectGetMidX(_imageView.bounds)/2, MDCSwipeToChooseViewTopPadding, CGRectGetMidX(_imageView.bounds), MDCSwipeToChooseViewLabelHeight);
    self.reportView = [[UIImageView alloc] initWithFrame:frame];
    [self.reportView constructBorderedLabelWithText:self.options.reportText
                                              color:self.options.reportColor
                                              angle:self.options.reportRotationAngle
                                           textSize:self.options.reportTextSize
     ];
    
    self.reportView.alpha =  0.f;
    [self.imageView addSubview:self.reportView];
}

- (void)constructLikedView {
    CGRect frame = CGRectMake(MDCSwipeToChooseViewHorizontalPadding,
                              MDCSwipeToChooseViewTopPadding,
                              CGRectGetMidX(_imageView.bounds),
                              MDCSwipeToChooseViewLabelHeight);
    self.likedView = [[UIView alloc] initWithFrame:frame];
    [self.likedView constructBorderedLabelWithText:self.options.likedText
                                             color:self.options.likedColor
                                             angle:self.options.likedRotationAngle
                                          textSize:self.options.likedTextSize
     ];
    self.likedView.alpha = 0.f;
    [self.imageView addSubview:self.likedView];
}

- (void)constructNopeImageView {
    CGFloat width = CGRectGetMidX(self.imageView.bounds);
    CGFloat xOrigin = CGRectGetMaxX(_imageView.bounds) - width - MDCSwipeToChooseViewHorizontalPadding;
    self.nopeView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin,
                                                                  MDCSwipeToChooseViewTopPadding,
                                                                  width,
                                                                  MDCSwipeToChooseViewLabelHeight)];
    [self.nopeView constructBorderedLabelWithText:self.options.nopeText
                                            color:self.options.nopeColor
                                            angle:self.options.nopeRotationAngle
                                         textSize:self.options.nopeTextSize
     ];
    self.nopeView.alpha = 0.f;
    [self.imageView addSubview:self.nopeView];
}

- (void)setupSwipeToChoose {
    MDCSwipeOptions *options = [MDCSwipeOptions new];
    options.delegate = self.options.delegate;
    options.threshold = self.options.threshold;
    
    __block UIView *likedImageView = self.likedView;
    __block UIView *nopeImageView = self.nopeView;
    __block UIView *holdImageView = self.holdView;
    __block UIView *reportImageView = self.reportView;
    __block UIView *transparentImageView = self.transparentImage;
    __weak MDCSwipeToChooseView *weakself = self;
    options.onPan = ^(MDCPanState *state) {
        if (state.direction == MDCSwipeDirectionNone) {
            likedImageView.alpha = 0.f;
            nopeImageView.alpha = 0.f;
            holdImageView.alpha = 0.f;
            reportImageView.alpha = 0.f;
        } else if (state.direction == MDCSwipeDirectionLeft) {
            transparentImageView.alpha = state.thresholdRatio / 3 * 2;
            likedImageView.alpha = 0.f;
            reportImageView.alpha = 0.f;
            holdImageView.alpha = 0.f;
            nopeImageView.alpha = state.thresholdRatio;
        } else if (state.direction == MDCSwipeDirectionRight) {
            transparentImageView.alpha = state.thresholdRatio / 3 * 2;
            likedImageView.alpha = state.thresholdRatio;
            nopeImageView.alpha = 0.f;
            holdImageView.alpha = 0.f;
            reportImageView.alpha = 0.f;
        } else if (state.direction == MDCSwipeDirectionUp) {
            transparentImageView.alpha = state.thresholdRatio / 3 * 2;
            reportImageView.alpha = state.thresholdRatio;
            nopeImageView.alpha = 0.f;
            likedImageView.alpha = 0.f;
            holdImageView.alpha = 0.f;
        } else if (state.direction == MDCSwipeDirectionDown) {
            transparentImageView.alpha = state.thresholdRatio / 3 * 2;
            holdImageView.alpha = state.thresholdRatio;
            reportImageView.alpha = 0.f;
            nopeImageView.alpha = 0.f;
            likedImageView.alpha = 0.f;
        }
        
        if (weakself.options.onPan) {
            weakself.options.onPan(state);
        }
    };
    
    [self mdc_swipeToChooseSetup:options];
}

- (void)setupSwipeToChooseGoodwill {
    MDCSwipeOptions *options = [MDCSwipeOptions new];
    options.delegate = self.options.delegate;
    options.threshold = self.options.threshold;
    
    __block UIView *likedImageView = self.likedView;
    __block UIView *nopeImageView = self.nopeView;
    __block UIView *holdImageView = self.holdView;
    __block UIView *reportImageView = self.reportView;
    __block UIView *transparentImageView = self.transparentImage;
    __weak MDCSwipeToChooseView *weakself = self;
    options.onPan = ^(MDCPanState *state) {
        if (state.direction == MDCSwipeDirectionNone) {
            likedImageView.alpha = 0.f;
            nopeImageView.alpha = 0.f;
            holdImageView.alpha = 0.f;
            reportImageView.alpha = 0.f;
        } else if (state.direction == MDCSwipeDirectionLeft) {
            transparentImageView.alpha = state.thresholdRatio / 3 * 2;
            likedImageView.alpha = 0.f;
            reportImageView.alpha = 0.f;
            holdImageView.alpha = 0.f;
            nopeImageView.alpha = state.thresholdRatio;
        } else if (state.direction == MDCSwipeDirectionRight) {
            transparentImageView.alpha = state.thresholdRatio / 3 * 2;
            likedImageView.alpha = state.thresholdRatio;
            nopeImageView.alpha = 0.f;
            holdImageView.alpha = 0.f;
            reportImageView.alpha = 0.f;
        }
        
        if (weakself.options.onPan) {
            weakself.options.onPan(state);
        }
    };
    
    [self mdc_swipeToChooseSetup:options];
}


@end
