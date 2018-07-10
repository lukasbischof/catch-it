//
//  ViewController.m
//  catch it
//
//  Created by Lukas Bischof on 14.02.14.
//  Copyright (c) 2014 Lukas. All rights reserved.
//

#import "ViewController.h"
#import "MainMenu.h"
#import "GameScene.h"
#import <Social/Social.h>
#import "GameOverScene.h"
#import "GameCenterHelper.h"
#import <iAd/iAd.h>

@interface ViewController () <GKGameCenterControllerDelegate, ADBannerViewDelegate, GCDelegate> {
    NSString *socialText;
}

@property (weak, nonatomic) IBOutlet ADBannerView *adView;
@property (assign, nonatomic, getter = isAdBannerDown) BOOL adBannerIsDown;
@property (assign, nonatomic, getter = isAllowedToShowBanner) BOOL isAllowedToShowBanner;

@end

@implementation ViewController

-(void)setIsAllowedToShowBanner:(BOOL)isAllowedToShowBanner
{
    if (![self isAdBannerDown] && !isAllowedToShowBanner) {
        [self transitionAdViewDown:YES
                        completion:^(BOOL finished) {
                            _isAllowedToShowBanner = isAllowedToShowBanner;
                        }];
        return;
    }
    _isAllowedToShowBanner = isAllowedToShowBanner;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    socialText = @"I've just finished a tricky game with a score of %lu! Will you beat me?";
    
    [[GameCenterHelper sharedInstance] setDelegate:self];
    
    self.adBannerIsDown = YES;
    [self setIsAllowedToShowBanner:YES];
    
    __weak typeof(self) wS = self;
    void (^twBlock)(NSNotification*) = ^(NSNotification *note){
        if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
            return;

        SLComposeViewController *twitterVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitterVC setInitialText:[NSString stringWithFormat:socialText, [(NSNumber *)note.userInfo[@"score"] unsignedLongValue]]];
        
        [wS presentViewController:twitterVC
                         animated:YES
                       completion:^{}];
    };
    
    void (^fbNotBlock)(NSNotification*) = ^(NSNotification *note){
        if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            return;
        }
        SLComposeViewController *facebookVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        unsigned long score = [(NSNumber *)note.userInfo[@"score"] unsignedLongValue];
        [facebookVC setInitialText:[NSString stringWithFormat:socialText, score]];
        
        [wS presentViewController:facebookVC
                         animated:YES
                       completion:^{}];
    };
    
    void (^leaderbrdBlock)(NSNotification*) = ^(NSNotification *note){
        if ([[GameCenterHelper sharedInstance] localPlayerIsAuthenticated]) {
            GKGameCenterViewController *vc = [[GameCenterHelper sharedInstance] getLeaderboardViewControllerForIdentifier:_GCH_SCORE_LEADERBOARD_IDENTIFIER];
            if (vc != nil && vc) {
                vc.gameCenterDelegate = self;
                [wS presentViewController:vc
                                 animated:YES
                               completion:^(){
                                   [(SKView *)[self view] setPaused:YES];
                               }];
                return;
            }
        }
        
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"GameCenter isn't available"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    };
    
    void (^achievementsBlock)(NSNotification*) = ^(NSNotification *note){
        if ([[GameCenterHelper sharedInstance] localPlayerIsAuthenticated]) {
            GKGameCenterViewController *vc = [[GameCenterHelper sharedInstance] getAchievementsViewController];
            if (vc != nil && vc) {
                vc.gameCenterDelegate = self;
                [wS presentViewController:vc
                                 animated:YES
                               completion:^(){
                                   [(SKView *)[self view] setPaused:YES];
                               }];
                return;
            }
        }
        
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"GameCenter isn't available"
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    };
    
    void (^startGameBlock)(NSNotification*) = ^(NSNotification *note){
        if (![self isAdBannerDown]) {
            [wS transitionAdViewDown:YES
                          completion:nil];
        }
        self.isAllowedToShowBanner = NO;
    };
    
    void (^gameOverBlock)(NSNotification*) = ^(NSNotification *note){
        if ([self isAdBannerDown]) {
            [wS transitionAdViewDown:NO
                          completion:nil];
        }
        self.isAllowedToShowBanner = YES;
    };
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"twitterBT"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:twBlock];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"facebookBT"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:fbNotBlock];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"leaderboardButtonTapped"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:leaderbrdBlock];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"achievementsButtonTapped"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:achievementsBlock];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"startGame"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:startGameBlock];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"gameOver"
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:gameOverBlock];
    
    // Configure the view.
    SKView *skView = (SKView *)self.view;
    
#ifdef DEBUG
    //skView.showsFPS = YES;
    //skView.showsNodeCount = YES;
    //skView.showsPhysics = YES;
    //skView.showsDrawCount = YES;
#endif
    
    // Create and configure the scene.
    //#warning uncomment this before releasing!
    SKScene *scene = [MainMenu sceneWithSize:skView.bounds.size];
    //SKScene *scene = [GameScene sceneWithSize:skView.bounds.size];
    //SKScene *scene = [GameOverScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
    self.adView.delegate = self;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL)prefersStatusBarHidden
{
    boolean_t sbh = 1;
    return sbh;
}

#pragma mark - GKGameCenterControllerDelegate
-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:__objc_yes completion:^(){
        [(SKView *)[self view] setPaused:NO];
    }];
}

#pragma mark - ADBannerViewDelegate
-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    NSLog(@"ERROR: %@", error);
    if (error.domain == ADErrorDomain) {
        switch (error.code) {
            case ADErrorAdUnloaded:
                
            break;
            case ADErrorApplicationInactive:
                
            break;
            case ADErrorBannerVisibleWithoutContent:
                
            break;
            case ADErrorConfigurationError:
                
            break;
            case ADErrorInventoryUnavailable:
                
            break;
            case ADErrorLoadingThrottled:
                
            break;
            case ADErrorServerFailure:
                
            break;
            case ADErrorUnknown:
                
            break;
                
            default:
            break;
        }
    }
    
    [self transitionAdViewDown:YES completion:nil];
}

-(void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    
}

-(BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    return YES;
}

-(void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [self transitionAdViewDown:NO completion:^(BOOL finished) {
        // NSLog(@"alpha: %f, background: %@", self.adView.alpha, self.adView.backgroundColor);
    }];
}

-(void)bannerViewWillLoadAd:(ADBannerView *)banner
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

-(void)transitionAdViewDown: (BOOL)down completion: (void(^)(BOOL finished))completion
{
    if (!down && ![self isAllowedToShowBanner]) {
        return;
    }
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.adView.frame = CGRectMake(0, (down) ? self.view.bounds.size.height : self.view.bounds.size.height - self.adView.frame.size.height, 0, 0);
                         self.adBannerIsDown = down;
                     }
                     completion:completion];
}

#pragma mark - GCDelegate
-(void)error:(NSError *)error
{
    if (error.domain == GKErrorDomain) {
        if (error.code == GKErrorUserDenied || error.code == GKErrorNotAuthenticated) {
            [[GameCenterHelper sharedInstance] setGameCenterIsAvailable:NO];
        }
    }
}

-(void)presentAuthenticationViewController:(UIViewController *)viewController
{
    [self presentViewController:viewController
                       animated:YES
                     completion:^{
                         [viewController addObserver:self
                                          forKeyPath:@"isBeingDismissed"
                                             options:NSKeyValueObservingOptionNew
                                             context:nil];
                     }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
