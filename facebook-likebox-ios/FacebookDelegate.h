//
//  FacebookDelegate.h
//  easy ten
//
//  Created by Алексей Гончаров on 19.08.12.
//  Copyright (c) 2012 nowhere. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>

@protocol FBETDelegate <NSObject>

@optional

- (void)addPostView:(UIView *)view;

@end

@interface FacebookDelegate : NSObject {
}

+ (id)sharedInstance;

- (void)loginWithDelegate:(UIViewController *)delegate;
-(BOOL)sessionIsValid;


@end
