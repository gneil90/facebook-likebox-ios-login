//
//  ViewController.h
//  facebook-likebox-ios
//
//  Created by Yan Saraev on 9/20/13.
//  Copyright (c) 2013 Yan Saraev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIWebViewDelegate>

@property (weak,nonatomic) IBOutlet UIWebView *webView;

@property (strong,nonatomic) UIActivityIndicatorView *indicatorLikeView;

- (void)showLikeButton:(CGFloat)alpha;


@end
