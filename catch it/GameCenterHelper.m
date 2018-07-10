//
//  GameCenterHelper.m
//  catch it
//
//  Created by Lukas Bischof on 15.02.14.
//  Copyright (c) 2014 Lukas. All rights reserved.
//

#import "GameCenterHelper.h"

@interface GameCenterHelper ()

@property (strong, nonatomic) GKPlayer *authenticatedPlayer;
@property (strong, nonatomic) NSArray *leaderboards;
@property (strong, nonatomic) NSDictionary *achievements;

@end

@implementation GameCenterHelper

+(instancetype)sharedInstance
{
    static GameCenterHelper *GCH;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        GCH = [[GameCenterHelper alloc] init];
        [GCH authenticateLocalPlayer];
    });
    return GCH;
}

-(void)loadLeaderboards
{
    __weak typeof(self) wS = self;
    [GKLeaderboard loadLeaderboardsWithCompletionHandler:^(NSArray *leaderboards, NSError *error) {
        if (nil != error)
            wS.leaderboards = leaderboards;
        else
            NSLog(@"[GCH]: error when loading the leaderboards");
        NSLog(@"leaderboards: %@", leaderboards);
    }];
}

-(void)loadAchievements
{
    __weak typeof(self) wS = self;
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        if (!error) {
            NSMutableDictionary *ach = [NSMutableDictionary new];
            [achievements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [ach setValue:obj forKey:[(GKAchievement *)obj identifier]];
            }];
            wS.achievements = [NSDictionary dictionaryWithDictionary:ach];
            NSLog(@"achievements: %@, response: %@", wS.achievements, achievements);
        } else {
            if ([self.delegate respondsToSelector:@selector(error:)]) {
                [self.delegate error:error];
            }
            NSLog(@"error: %@", error);
        }
    }];
}

-(void)authenticateLocalPlayer
{
    self.leaderboards = [NSArray new];
    self.achievements = [NSDictionary new];
    
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    [localPlayer setAuthenticateHandler:^(UIViewController *viewController, NSError *error) {        
        GKLocalPlayer *localPlayer__ = [GKLocalPlayer localPlayer];
        
        if (viewController) {
            // player isn't authenticated
            
            if ([self.delegate respondsToSelector:@selector(presentAuthenticationViewController:)])
                [self.delegate presentAuthenticationViewController:viewController];
            
            self.gameCenterIsAvailable = NO;
        } else if ([localPlayer__ isAuthenticated]) {
            // player is authenticated
            
            NSLog(@"player authenticated");
            
            if ([self.delegate respondsToSelector:@selector(playerIsNowAuthenticated:)])
                [self.delegate playerIsNowAuthenticated:localPlayer__];
            
            self.authenticatedPlayer = localPlayer__;
            
            [self setGameCenterIsAvailable:YES];
        } else {
            if (error) {
                if ([self.delegate respondsToSelector:@selector(error:)])
                    [self.delegate error:error];
                else
                    NSLog(@"<<<<EOD\n\n ERROR: %@ \n\nEOD;", error);
            }
            
            [self setGameCenterIsAvailable:NO];
        }
        
        [self loadLeaderboards];
        [self loadAchievements];
    }];
    
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, [GKLocalPlayer localPlayer]);
}

-(void)retrieveTopScoresForLeaderbordIdentifier:(const char *)identifier
                                       encoding:(NSStringEncoding)encoding
                                  andScoreRange:(NSRange)range
{
    GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
    if (leaderboardRequest != nil)
    {
        leaderboardRequest.playerScope = GKLeaderboardPlayerScopeGlobal;
        leaderboardRequest.timeScope = GKLeaderboardTimeScopeToday;
        leaderboardRequest.identifier = [[NSString alloc] initWithCString:identifier
                                                                 encoding:encoding];
        leaderboardRequest.range = range;
        [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error) {
            if (error != nil) {
                if ([self.delegate respondsToSelector:@selector(error:)])
                    [self.delegate error:error];
                return;
            }
            if (scores != nil) {
                // Process the score information.
                if ([self.delegate respondsToSelector:@selector(didReciveLeaderbordScores:)]) {
                    [self.delegate didReciveLeaderbordScores:scores];
                }
                return;
            }
            
            NSError *custError = [[NSError alloc] initWithDomain:@"GCHErrorDomain"
                                                            code:20
                                                        userInfo:@{ NSLocalizedDescriptionKey: @"unknown loeaderbord request error"}];
            if ([self.delegate respondsToSelector:@selector(error:)])
                [self.delegate error:custError];
            return;
        }];
    }
}

//-(boolean_t)reportTD: (SEL)selector
//{
//    if (self.delegate) {
//        if ([self.delegate respondsToSelector:selector]) {
//            if (![self.delegate performSelector:selector])
//                return 0;
//            return 1;
//        }
//    }
//    
//    return 0;
//}

-(void)reportScore:(int64_t)score
     forIdentifier:(NSString *)identifier
        andContext:(uint64_t)context
{
    printf("%s, score: %lld\n", __PRETTY_FUNCTION__, score);
    
    if (![[GKLocalPlayer localPlayer] isAuthenticated]) {
        NSLog(@"not authenticated");
        return;
    }
    
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:identifier];
    scoreReporter.value = score;
    scoreReporter.context = context;
    
    [GKScore reportScores:@[scoreReporter] withCompletionHandler:^(NSError *error) {
        if (error) {
            if ([self.delegate respondsToSelector:@selector(error:)]) {
                [self.delegate error:error];
            } else
                NSLog(@"\n[GCH]: <ERROR> ERROR: %@\n{line: %d, failed to report score, context: %llu, score: %lld, reporter: %@}", error, __LINE__, context, score, scoreReporter);
        } else
            NSLog(@"reported score successfully");
    }];
}

-(void)reportScore:(int64_t)score
     forIdentifier:(NSString *)identifier
        andContext:(uint64_t)context
 completionHandler:(GLvoid (^)(void))handler
{
    if (!self.gameCenterIsAvailable || ![[GKLocalPlayer localPlayer] isAuthenticated]) {
        return;
    }
    
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier:identifier];
    scoreReporter.value = score;
    scoreReporter.context = context;
    
    [GKScore reportScores:@[scoreReporter] withCompletionHandler:^(NSError *error) {
        if (error) {
            if ([self.delegate respondsToSelector:@selector(error:)]) {
                [self.delegate error:error];
            } else
                NSLog(@"\n[GCH]: <ERROR> ERROR: %@\n{line: %d, failed to report score, context: %llu, score: %lld, reporter: %@}", error, __LINE__, context, score, scoreReporter);
        }
        handler();
    }];
}

-(void)reportAchievement:(NSString *)identifier
         percentComplete:(score_t)percentComplete
       completionHandler:(void (^)(NSError *error))handler
   showsCompletionBanner:(bool_t)showsCompletionBanner
{
    if (!self.gameCenterIsAvailable || ![[GKLocalPlayer localPlayer] isAuthenticated]) {
        NSLog(@"player isn't authenticated or game center isn't available");
        return;
    }
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
    achievement.showsCompletionBanner = showsCompletionBanner;
    if (achievement) {
        achievement.percentComplete = percentComplete;
    }
    [GKAchievement reportAchievements:@[achievement]
                withCompletionHandler:handler];
}

-(void)reportAchievement:(NSString *)identifier
         percentComplete:(score_t)percentComplete
   showsCompletionBanner:(bool_t)showsCompletionBanner
{
    [self reportAchievement:identifier
            percentComplete:percentComplete
          completionHandler:^(NSError *error) {
              if (error != nil) {
                  if ([self.delegate respondsToSelector:@selector(error:)])
                      [self.delegate error:error];
                  else
                      NSLog(@"[GCH]: ERROR: %@\nfailed to report achievement", error);
              }
          } showsCompletionBanner:showsCompletionBanner];
}

-(void)reportAchievements:(NSArray *)achievements
{
    [GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            if ([self.delegate respondsToSelector:@selector(error:)])
                [self.delegate error:error];
            else
                NSLog(@"[GCH]: ERROR: %@\nfailed to report achievement", error);
        } else
            NSLog(@"[GCH]: reported Achievements");
    }];
}

-(GKGameCenterViewController *)getLeaderboardViewControllerForIdentifier:(NSString *)identifier
{
    if (![[GKLocalPlayer localPlayer] isAuthenticated]) {
        NSLog(@"%s, player is not authenticated", __PRETTY_FUNCTION__);
        return (void *)0;
    }
    
    GKGameCenterViewController *gcvc = [GKGameCenterViewController new];
    gcvc.viewState = GKGameCenterViewControllerStateLeaderboards;
    gcvc.leaderboardIdentifier = identifier;
    
    return gcvc;
}

-(GKGameCenterViewController *)getAchievementsViewController
{
    if (![[GKLocalPlayer localPlayer] isAuthenticated]) {
        NSLog(@"%s, player is not authenticated", __PRETTY_FUNCTION__);
        return (void *)0;
    }
    
    GKGameCenterViewController *gcvc = [GKGameCenterViewController new];
    [gcvc setViewState:GKGameCenterViewControllerStateAchievements];
    
    return gcvc;
}

-(GKAchievement *)getAchievementForIdentifier:(NSString *)identifier
{
    return [[GKAchievement alloc] initWithIdentifier:identifier];
}

-(bool_t)localPlayerIsAuthenticated
{
    return [[GKLocalPlayer localPlayer] isAuthenticated];
}

-(GKPlayer *)localPlayerIfAuthenticated
{
    return self.authenticatedPlayer;
}

@end