//
//  MainMenu.m
//  catch it
//
//  Created by Lukas Bischof on 14.02.14.
//  Copyright (c) 2014 Lukas. All rights reserved.
//

#import "AppDelegate.h"
#import "MainMenu.h"
#import "MainMenuButton.h"
#import "GameScene.h"
#import "Bomb.h"

static inline CGFloat skRandf() {
    return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf() * (high - low) + low;
}

typedef NS_ENUM(NSUInteger, screenSize){
    NSScreenSizeIPhone5AndHigher,
    NSScreenSizeIPhone4AndLower,
    NSScreenSizeIPadScreenSize
};

typedef enum{
    NSIphoneDevice,
    NSIpadDevice
}device;

@interface MainMenu () {
    NSArray *_butons;
    NSArray *iPhoneMMButtonPositions;
    screenSize currentScreenSize;
    device currentDevice;
}

@property (strong, nonatomic) MainMenuButton *playButton;
@property (strong, nonatomic) MainMenuButton *leaderboardButton;
@property (strong, nonatomic) MainMenuButton *achievementsButton;
@property (strong, nonatomic) NSTimer *timer;

@end

@implementation MainMenu

-(instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        // configure the Scene
        self.backgroundColor = [UIColor colorWithRed:0.7
                                               green:0.7
                                                blue:0.2
                                               alpha:1.0];
        
        SKSpriteNode *back = [[SKSpriteNode alloc] initWithImageNamed:@"MM_back.png"];
        back.size = self.size;
        back.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        back.alpha = 0.5;
        NSLog(@"self: %@, back: %@", self, back);
        [self addChild:back];
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                                  target:self
                                                selector:@selector(spawnRandomItem)
                                                userInfo:nil
                                                 repeats:YES];
        [_timer fire];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReciveInactiveState:)
                                                     name:ADApplicationWillResignActiveNotificationIdentifier
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReciveActiveState:)
                                                     name:ADApplicationWillEnterForegroundNotificationIdentifier
                                                   object:nil];
        
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (screenSize.height > 480.0f) {
                iPhoneMMButtonPositions = @[@320, @220,  @120];
                currentScreenSize = NSScreenSizeIPhone5AndHigher;
                currentDevice = NSIphoneDevice;
            } else {
                iPhoneMMButtonPositions = @[@270, @190, @110];
                currentScreenSize = NSScreenSizeIPhone4AndLower;
                currentDevice = NSIphoneDevice;
            }
        } else {
            iPhoneMMButtonPositions = @[@620, @450, @280];
            currentScreenSize = NSScreenSizeIPadScreenSize;
            currentDevice = NSIpadDevice;
        }
    }
    
    return self;
}

-(void)didReciveActiveState: (NSNotification *)notification
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.paused = NO;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0
                                              target:self
                                            selector:@selector(spawnRandomItem)
                                            userInfo:nil
                                             repeats:YES];
    [self.timer fire];
}

-(void)didReciveInactiveState: (NSNotification *)notification
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.paused = YES;
    [self.timer invalidate];
    //self.timer = nil;
}

-(void)didMoveToView:(SKView *)view
{
    
    SKLabelNode *title = [[SKLabelNode alloc] initWithFontNamed:@"Papyrus"];
    title.text = @"catch it!";
    title.fontSize += (currentDevice == NSIphoneDevice) ? 26 : 72;
    title.position = CGPointMake(self.frame.size.width/2, (currentDevice == NSIphoneDevice) ? ((currentScreenSize == NSScreenSizeIPhone5AndHigher) ? 450 : 385) : 870);
    [title setFontColor:[UIColor blackColor]];
    
    SKLabelNode *ifYouDareNode = [[SKLabelNode alloc] initWithFontNamed:@"Papyrus"];
    ifYouDareNode.text = @"if you dare...";
    [ifYouDareNode setFontSize:ifYouDareNode.fontSize + ((currentDevice == NSIphoneDevice) ? -10.f : 10)];
    ifYouDareNode.position = CGPointMake(title.position.x, title.position.y - ((currentDevice == NSIphoneDevice) ? ((currentScreenSize == NSScreenSizeIPhone4AndLower) ? 34.f : 40.f) : 60));
    ifYouDareNode.fontColor = [UIColor colorWithHue:.0f
                                         saturation:.0f
                                         brightness:.2f
                                              alpha:1.f];
    
    _playButton = [[MainMenuButton alloc] initWithDefaultImageAndPosition:CGPointMake(self.frame.size.width/2, [iPhoneMMButtonPositions[0] intValue]) title:@"Play"];
    _leaderboardButton = [[MainMenuButton alloc] initWithDefaultImageAndPosition:CGPointMake(CGRectGetMidX(self.frame), [iPhoneMMButtonPositions[1] intValue]) title:@"Leaderboard"];
    _achievementsButton = [[MainMenuButton alloc] initWithDefaultImageAndPosition:CGPointMake(CGRectGetMidX(self.frame), [iPhoneMMButtonPositions[2] intValue]) title:@"Achievements"];
    
    _playButton.action = @selector(playButtonTapped);
    _leaderboardButton.action = @selector(leaderboardButtonTapped);
    _achievementsButton.action = @selector(achievementsButtonTapped);
    
    self->_butons = @[
                      _playButton,
                      _leaderboardButton,
                      _achievementsButton
                      ];
    
    _playButton.physicsBody.dynamic =
    _leaderboardButton.physicsBody.dynamic =
    _achievementsButton.physicsBody.dynamic = NO;
    
    [self addChild:title];
    [self addChild:ifYouDareNode];
    [self addChild:_achievementsButton];
    [self addChild:_leaderboardButton];
    [self addChild:_playButton];
}

-(void)update:(NSTimeInterval)currentTime
{
    
}

-(void)didSimulatePhysics
{
    [self enumerateChildNodesWithName:@"item" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < 0)
            [node removeFromParent];
    }];
}

-(void)spawnRandomItem
{
    if (self.paused)
        return;

    Bomb *bomb = [[Bomb alloc] initWithPosition:CGPointMake(skRand(0, self.frame.size.width),
                                                            self.frame.size.height + 25)];
    [self addChild:bomb];
}

#pragma mark - actions
-(void)playButtonTapped
{
    GameScene *gs = [[GameScene alloc] initWithSize:self.size];
    [self.view presentScene:gs transition:[SKTransition doorsOpenVerticalWithDuration:1.0]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startGame"
                                                        object:self];
}

-(void)leaderboardButtonTapped
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"leaderboardButtonTapped"
                                                        object:self];
}

-(void)achievementsButtonTapped
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"achievementsButtonTapped"
                                                        object:self];
}

#pragma mark - touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    for (MainMenuButton *button in self->_butons) {
        if ([button containsPoint:[touch locationInNode:self]]) {
            [button tap];
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    for (MainMenuButton *button in self->_butons) {
        if (![button containsPoint:[touch locationInNode:self]]) {
            [button endTap];
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    for (MainMenuButton *button in self->_butons) {
        if ([button containsPoint:[touch locationInNode:self]]) {
            [button endTap];
            if (button.action) {
                if ([self respondsToSelector:button.action])
                    [self performSelectorOnMainThread:button.action
                                           withObject:nil
                                        waitUntilDone:NO];
            }
        }
    }
}

-(void)dealloc
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    [_timer invalidate];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ADApplicationWillEnterForegroundNotificationIdentifier
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ADApplicationWillResignActiveNotificationIdentifier
                                                  object:nil];
}

@end
