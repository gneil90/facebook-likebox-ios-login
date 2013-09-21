//
//  FacebookDelegate.m
//  easy ten
//
//  Created by Алексей Гончаров on 19.08.12.
//  Copyright (c) 2012 nowhere. All rights reserved.
//

#import "FacebookDelegate.h"
#import "ViewController.h"

@interface FacebookDelegate()

@property (nonatomic, strong) NSString *email, *name, *ID;
@property FBSession *session;
@property (weak,nonatomic) UIViewController *delegate;

@end

@implementation FacebookDelegate

+ (id)sharedInstance {
	static FacebookDelegate *__sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		__sharedInstance = [[FacebookDelegate alloc]init];
	});
	
	return __sharedInstance;
}


-(BOOL)sessionIsValid{
    if (FBSession.activeSession.isOpen)
    {
        // post to wall
        return YES;
    } else {
        // try to open session with existing valid token
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"user_likes",
                                @"read_stream",
                                @"publish_actions",
                                nil];
        FBSession *session = [[FBSession alloc] initWithPermissions:permissions];
        [FBSession setActiveSession:session];
        if([FBSession openActiveSessionWithAllowLoginUI:NO]) {
            // post to wall
            return YES;
        } else {
            // you need to log the user
            return NO;
        }
    }
}

-(void)isMemberOfPublicId:(NSString*)idPublic{
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/me/likes/%@",idPublic] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            NSLog(@"FB_UD %@", error.userInfo);
        } else {
            NSLog(@"FB_LIKES: %@:, id: %@", result,idPublic);
            if([result objectForKey:@"data"]){
                if ([[result objectForKey:@"data"] count]) {
                    NSLog(@"class data %@",[[result objectForKey:@"data"]class]);
                    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
                    NSLog(@"%lld", [[formatter numberFromString:idPublic] longLongValue]);
                    for (FBGraphObject *graph in [result objectForKey:@"data"]) {
                        if ([[formatter numberFromString:graph[@"id"]] longLongValue] == [[formatter numberFromString:idPublic] longLongValue]) {
                            if ([self.delegate isKindOfClass:[ViewController class]]&&self.delegate) {
                                [[(ViewController*)self.delegate _labelAnswer]setText:@"YES"];
                            }
                        }

                    }
                                    }else{
                    if ([self.delegate isKindOfClass:[ViewController class]]&&self.delegate) {
                        [[(ViewController*)self.delegate _labelAnswer]setText:@"NO"];
                    }
                }
            }
        }
    }];
}

-(void)getIDofLink:(NSString*)graphObject{
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@",graphObject] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (error) {
            NSLog(@"FB_UD %@", error.userInfo);
        } else {
            NSLog(@"FB_ID: %@", [result objectForKey:@"id"]);
            if ([result count]) {
                [self isMemberOfPublicId:(NSString*)[result objectForKey:@"id"]];
            }
        }

        
    }];

}

- (void)loginWithDelegate:(UIViewController *)delegate{
    [FBSession setActiveSession: [[FBSession alloc] initWithPermissions:@[@"publish_actions", @"publish_stream", @"user_photos"]]];

    [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorForcingWebView completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        switch (status) {
            case FBSessionStateOpen:
                // call the legacy session delegate
                //Now the session is open do corresponding UI changes
                if (session.isOpen) {
                    FBRequest *me = [FBRequest requestForMe];
                    
                    [me startWithCompletionHandler: ^(FBRequestConnection *connection,
                                                      NSDictionary<FBGraphUser> *my,
                                                      NSError *error) {
                        if (!my) {
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"ETSignUpFailed" object:nil];
                            NSLog(@"Facebook error:\n%@", error.description);
                            return;
                        }
                        
                        if ([delegate isKindOfClass:[ViewController class]]&&delegate) {
                            self.delegate=delegate;
                            [(ViewController*)self.delegate showLikeButton:1.0f];
                        }
                    }];
                }
                break;
            case FBSessionStateClosedLoginFailed:
            { // prefer to keep decls near to their use
                
                // unpack the error code and reason in order to compute cancel bool
                NSString *errorCode = [[error userInfo] objectForKey:FBErrorLoginFailedOriginalErrorCode];
                NSString *errorReason = [[error userInfo] objectForKey:FBErrorLoginFailedReason];
                BOOL userDidCancel = !errorCode && (!errorReason ||
                                                    [errorReason isEqualToString:FBErrorLoginFailedReasonInlineCancelledValue]);
                

                // call the legacy session delegate if needed
                //[[delegate facebook] fbDialogNotLogin:userDidCancel];
            }
                break;
                // presently extension, log-out and invalidation are being implemented in the Facebook class
            default:
                break; // so we do nothing in response to those state transitions
        }
    }];

}





@end
