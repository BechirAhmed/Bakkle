//
// MDCSwipeToChooseView.h
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

#import <UIKit/UIKit.h>
#import "RateView.h"

@class MDCSwipeToChooseViewOptions;

/*!
 * A `UIView` subclass that acts nearly identically to the swipe-to-choose
 * views in Tinder.app. Swipe right to "like", left to "dislike".
 */
@interface MDCSwipeToChooseView : UIView

@property (nonatomic, strong) UIPageControl *pageControl;

/*
 * extra view beside swipe view
 */
@property (nonatomic, strong) UIView *informationView;

/*!
 * The main image to be displayed and then "liked" or "disliked".
 */
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIImageView *bottomBlurImg;

@property (nonatomic, strong) UIImageView *transparentImage;


/*!
 * The "liked" view, which fades in as the `MDCSwipeToChooseView` is panned to the right.
 */
@property (nonatomic, strong) UIView *likedView;

/*
 * The "hold" view, which fades in as the swipe is made to the top.
 */
@property (nonatomic, strong) UIView *holdView;

/*
 * The "report" view, which fades in as the swipe is made to the bottom.
 */
@property (nonatomic, strong) UIView *reportView;

/*!
 * The "nope" view, which fades in as the `MDCSwipeToChooseView` is panned to the left.
 */
@property (nonatomic, strong) UIView *nopeView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *priceLabel;

@property (nonatomic, strong) UILabel *distLabel;

@property (nonatomic, strong) UILabel *methodLabel;

@property (nonatomic, strong) UIImageView *profileImg;

@property (nonatomic, strong) UILabel *sellerName;

@property (nonatomic, assign) float sellerRating;

@property (strong, nonatomic) RateView *ratingView;

// shows that if the app is on ipad or iphone
@property BOOL ipad;


/*!
 * The designated initializer takes a `frame` and a set of options to customize
 * the behavior of the view.
 */
- (instancetype)initWithFrame:(CGRect)frame
                      options:(MDCSwipeToChooseViewOptions *)options goodwill:(BOOL)goodwill ipad:(BOOL)ipad;

@end


