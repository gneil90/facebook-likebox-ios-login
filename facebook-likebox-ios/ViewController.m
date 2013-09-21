//
//  ViewController.m
//  facebook-likebox-ios
//
//  Created by Yan Saraev on 9/20/13.
//  Copyright (c) 2013 Yan Saraev. All rights reserved.
//

#import "ViewController.h"
#import "FacebookDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self showLikeButton:0.0f];
    
    [_checkIfUserIsMemberButton addTarget:self action:@selector(checkPressed:)
      forControlEvents:UIControlEventTouchUpInside];
}

-(void)checkPressed:(id)sender{
    FacebookDelegate *_facebook = [FacebookDelegate sharedInstance];
    if ([_facebook sessionIsValid]) {
        [_facebook getIDofLink:_pageID.text];
    }else{
        [_facebook loginWithDelegate:self];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showLikeButton:(CGFloat)alpha {
    
    self.indicatorLikeView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.view addSubview:self.indicatorLikeView];
    [self.indicatorLikeView setHidden:YES];
    
    //https://developers.facebook.com/docs/reference/plugins/like-box/
    //use this link to get your own like-box plugin
    NSString *likeButtonIframe = @"<iframe src=\"http://www.facebook.com/plugins/likebox.php?href=https%3A%2F%2Fwww.facebook.com%2Feasyten&amp;width=300&amp;height=62&amp;colorscheme=light&amp;show_faces=false&amp;header=false&amp;stream=false&amp;show_border=false\" scrolling=\"no\" frameborder=\"0\" style=\"border:none; overflow:hidden; width:300px; height:62px;\" allowTransparency=\"true\"></iframe>";
    
    NSString *likeButtonHtml = [NSString stringWithFormat:@"<HTML><BODY style=\"background:transparent\">%@</BODY></HTML>", likeButtonIframe];
    self.webView.center = self.view.center;

    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.bounces = NO;
    
    /*
    //use mask layer in order to hide photo of public page
    //do not forget to add QuartzCore framework to your project
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    CGRect maskRect = CGRectMake(70, 0, 300, 100);
    
    // Create a path with the rectangle in it.
    CGPathRef path = CGPathCreateWithRect(maskRect, NULL);
    
    // Set the path to the mask layer.
    maskLayer.path = path;
    
    // Release the path since it's not covered by ARC.
    CGPathRelease(path);
    
    self.webView.layer.mask=maskLayer;
     */
    
    self.webView.alpha=alpha;
    [self.webView loadHTMLString:likeButtonHtml baseURL:[NSURL URLWithString:@""]];
    [self performSelectorOnMainThread:@selector(indicatorStartAnimating:) withObject:self.indicatorLikeView
                        waitUntilDone:NO];
}


-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"succefully finished loading webView");
    [self.indicatorLikeView stopAnimating];
    [self performSelectorOnMainThread:@selector(indicatorStopAnimating:) withObject:self.indicatorLikeView waitUntilDone:NO];
    [UIView animateWithDuration:0.3f animations:^{self.webView.alpha=1.0f;}];
}

-(void)indicatorStartAnimating:(UIActivityIndicatorView*)indicator{
    [indicator setHidden:NO];
    indicator.center = CGPointMake(self.webView.center.x-50.0f,self.webView.center.y-10.0f);
    [indicator startAnimating];
}
-(void)indicatorStopAnimating:(UIActivityIndicatorView*)indicator{
    [indicator stopAnimating];
    [indicator setHidden:YES];
}


//method to detect when webview redirects us to login
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    NSLog(@"%@",[request.URL absoluteString]);
    
    if ([request.URL.scheme isEqualToString:@"file"])
        return YES;
    
    // Allow loading about:blank, etc.
    if ([request.URL.scheme isEqualToString:@"http"]||[request.URL.scheme isEqualToString:@"https"]){
        NSLog(@"%@",[request.URL absoluteString]);
        NSString *URLstring=@"http://www.facebook.com/plugins/likebox.php?href=https%3A%2F%2Fwww.facebook.com%2Feasyten&width=300&height=62&colorscheme=light&show_faces=false&header=false&stream=false&show_border=false";
        NSString *URLsecureString =@"https://www.facebook.com/plugins/likebox.php?href=https%3A%2F%2Fwww.facebook.com%2Feasyten&width=300&height=62&colorscheme=light&show_faces=false&header=false&stream=false&show_border=false";
        if ([[request.URL absoluteString] isEqualToString:URLstring]||[[request.URL absoluteString]isEqualToString:URLsecureString]) {
            NSLog(@"strings are equal");
            return YES;
        }else{
            FacebookDelegate *_facebook = [FacebookDelegate sharedInstance];
            if([_facebook sessionIsValid]){
                NSLog(@"session is valid");
                NSString *publicURL=@"https://www.facebook.com/easyten";
                NSString *publicURLSecure = @"http://www.facebook.com/easyten";
                if ([[request.URL absoluteString] isEqualToString:publicURL]||[[request.URL absoluteString] isEqualToString:publicURLSecure]) {
                    return NO;
                }
                return YES;
            }else{
                [_facebook loginWithDelegate:self];
                return NO;
            }
        }
    }
    return NO;
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"webView starts to load");
    
    [self performSelectorOnMainThread:@selector(indicatorStartAnimating:) withObject:self.indicatorLikeView
                        waitUntilDone:NO];
    
}


@end
