//
//  GameCenterHelper.h
//  catch it
//
//  Created by Lukas Bischof on 15.02.14.
//  Copyright (c) 2014 Lukas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "Defines.h"

@protocol GCDelegate;

@interface GameCenterHelper : NSObject

+(instancetype)sharedInstance;
-(bool_t)localPlayerIsAuthenticated;
-(void)reportScore: (int64_t)score forIdentifier: (NSString *)identifier andContext: (uint64_t)context;
-(void)reportScore: (int64_t)score forIdentifier: (NSString *)identifier andContext: (uint64_t)context completionHandler: (void (^)(void))handler;
-(void)reportAchievement: (NSString *)identifier percentComplete: (score_t)percentComplete completionHandler: (void (^)(NSError *error))handler showsCompletionBanner: (bool_t)showsCompletionBanner;
-(void)reportAchievement: (NSString *)identifier percentComplete: (score_t)percentComplete showsCompletionBanner: (bool_t)showsCompletionBanner;
-(void)reportAchievements: (NSArray *)achievements;
-(GKAchievement *)getAchievementForIdentifier: (NSString *)identifier;

-(GKPlayer *)localPlayerIfAuthenticated;
-(void)retrieveTopScoresForLeaderbordIdentifier: (const char *)identifier encoding: (NSStringEncoding)encoding andScoreRange: (NSRange)range;
-(GKGameCenterViewController *)getLeaderboardViewControllerForIdentifier: (NSString *)identifier;
-(GKGameCenterViewController *)getAchievementsViewController;


@property (strong, nonatomic) id<GCDelegate> delegate;
@property BOOL gameCenterIsAvailable;

@end

@protocol GCDelegate <NSObject>

@required
-(void)presentAuthenticationViewController: (UIViewController *)viewController;
-(void)error: (NSError *)error;

@optional
-(void)playerIsNowAuthenticated: (GKLocalPlayer *)player;
-(void)didReciveLeaderbordScores: (NSArray *)scores;

@end
