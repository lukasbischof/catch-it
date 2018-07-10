//
//  GameScene.m
//  catch it
//
//  Created by Lukas Bischof on 14.02.14.
//  Copyright (c) 2014 Lukas. All rights reserved.
//

#import "GameScene.h"
#import "Bucket.h"
#import "Bomb.h"
#import "NormalGoodies.h"
#import "GameCenterHelper.h"
#import "GameOverScene.h"
#import "MainMenuButton.h"
#import "MainMenu.h"
#import "GameInfo.h"

#define SPAWN_ACTION_KEY @"com.lukas.catch_it.spawnAction"
#define PAUSE_NODE_NAME @"PauseNode"

const uint32_t bucketCategory = 0x1 << 1;
const uint32_t bombCategory = 0x1 << 2;
const uint32_t normalGoodieCategory = 0x1 << 3;

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return (rand() / (CGFloat)RAND_MAX) * (high - low) + low;
}

@interface GameScene () <SKPhysicsContactDelegate, UIAlertViewDelegate> {
    BOOL _pause, _gameOver, _canPlaySounds;
    int countdownNumber;
    BOOL _pauseButtonTouchDown;
    float bombChance;
    long unsigned int _score;
    float waitTimeForNewItem;
    NSArray *_buttons;
}

@property (strong, nonatomic) Bucket *bucket;
@property (strong, nonatomic) SKSpriteNode *pauseButton;
@property (strong, nonatomic) SKSpriteNode *pauseNode;
@property (strong, nonatomic) SKLabelNode *scoreNode;
@property (strong, nonatomic) GameOverScene *gameOverScene;
@property (strong, nonatomic) MainMenuButton *pauseButtQuitToMM;
@property (strong, nonatomic) MainMenuButton *pauseButtContinue;
@property (strong, nonatomic) SKAction *popSound;
@property (strong, nonatomic) SKAction *boomSound;
@property (strong, nonatomic) GameInfo *info;

@end

@implementation GameScene
#pragma mark -

-(instancetype)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        // configs
        _pause = NO;
        _pauseButtonTouchDown = FALSE;
        self->waitTimeForNewItem = 1.0;
        self->bombChance = -0.05;
        self->_gameOver = NO;
        self->_canPlaySounds = YES;
        self.physicsWorld.contactDelegate = self;
        self.info = [[GameInfo alloc] initWithDate:[NSDate date]];
        
        SKSpriteNode *back = [[SKSpriteNode alloc] initWithImageNamed:@"game_back.png"];
        back.size = self.size;
        back.position = CGPointMake(self.size.width / 2, self.size.height / 2);
        [self addChild:back];
        
        SKSpriteNode *pauseNode = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:self.size];
        pauseNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        pauseNode.alpha = 0.f;
        pauseNode.name = PAUSE_NODE_NAME;
        self.pauseNode = pauseNode;
        self.pauseNode.zPosition += 30;
        
        const CGFloat pauseButtContinueY = (IPHONE) ? 60 : 75,
                      pauseButtQuitToMMY = (IPHONE) ? -40 : -70;
        
        self.pauseButtContinue = [[MainMenuButton alloc] initWithDefaultImageAndPosition:CGPointMake(0, pauseButtContinueY) title:@"continue"];
        self.pauseButtQuitToMM = [[MainMenuButton alloc] initWithDefaultImageAndPosition:CGPointMake(0, pauseButtQuitToMMY) title:@"quit to menu"];
        
        self.pauseButtContinue.action = @selector(pauseButtContinuePressed);
        self.pauseButtQuitToMM.action = @selector(pauseButtQuitToMMPressed);
        
        _buttons = @[
                     self.pauseButtQuitToMM,
                     self.pauseButtContinue
                     ];
        [self.pauseNode addChild:self.pauseButtContinue];
        [self.pauseNode addChild:self.pauseButtQuitToMM];
        
        self.gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
        
        self.bucket = [[Bucket alloc] initWithBucketType:bucketTypeWood andPosition:CGPointMake(CGRectGetMidX(self.frame), 70)];
        
        self.bucket.physicsBody.dynamic = self.bucket.physicsBody.affectedByGravity = NO;
        self.bucket.physicsBody.categoryBitMask = bucketCategory;
        self.bucket.physicsBody.contactTestBitMask = normalGoodieCategory | bombCategory;
        self.bucket.zPosition += 10;
        [self addChild:self.bucket];
        
        _pauseButton = [[SKSpriteNode allocWithZone:(void *)0] initWithImageNamed:@"pause.png"];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            _pauseButton.size = CGSizeMake(25, 25);
        else
            _pauseButton.size = CGSizeMake(40, 40);
        
        _pauseButton.position = CGPointMake(self.frame.size.width - _pauseButton.size.width - 5,
                                            self.frame.size.height - _pauseButton.size.height - 15);
        [self addChild:_pauseButton];
        
        self.scoreNode = [[SKLabelNode allocWithZone:nil] initWithFontNamed:@"Helvetica"];
        self.scoreNode.fontColor = [UIColor whiteColor];
        self.scoreNode.fontSize += (IPHONE) ? 5 : 20;
        [self.scoreNode setText:@"Score: 0"];
        self.scoreNode.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - self.scoreNode.frame.size.height - (IPHONE ? 20 : 30));
        [self addChild:self.scoreNode];
        
        self.popSound = [SKAction playSoundFileNamed:@"pop.m4a" waitForCompletion:NO];
        
        NSString *randomBoomFile = [NSString stringWithFormat:@"boom@%d.m4a", (int)round((double)skRand(1, 2))];
        self.boomSound = [SKAction playSoundFileNamed:randomBoomFile waitForCompletion:NO];
    }
    return self;
}

-(void)didMoveToView:(SKView *)view
{
    [self startCountdown:^{
        NSLog(@"complete!");
        [self startNewGame];
    }];
}

#pragma mark - game Methods
-(void)moveBucketToPointToX: (CGFloat)x
{
    self.bucket.position = CGPointMake(x, self.bucket.position.y);
}

-(void)startNewGame
{
    self->_score = 0;
    self->_gameOver = NO;
    _pause = FALSE;
    [self removeAllActions];
    [self enumerateChildNodesWithName:@"bomb" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    [self enumerateChildNodesWithName:@"boom" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    
    [self spawnRandomItem];
}

#pragma mark -
-(void)addScoreToGame: (unsigned int)score
{
    self->_score += (long)score;
    [self.scoreNode setText:[NSString stringWithFormat:@"Score: %lu", self->_score]];
    
    float minus = (float)(self->_score / 20000.f);
    self->waitTimeForNewItem -= minus;
    self->waitTimeForNewItem = MAX(self->waitTimeForNewItem, 0.2);
    NSLog(@"wtfni: %f, self->_score: %lu, minus: %f", waitTimeForNewItem, self->_score, minus);
    
    if ([self getScore] >= 20000) {
        self->waitTimeForNewItem = 0.15;
    }
    
    [self.info setScore:self->_score];
    [self testIfScoreAchievementIsReached];
}

-(unsigned long)getScore
{
    return self->_score;
}

#pragma mark -
-(void)pauseGame
{
    _pause = YES;
    
    [self enumerateChildNodesWithName:@"bomb" usingBlock:^(SKNode *node, BOOL *stop) {
        node.physicsBody.dynamic = NO;
    }];
    
    [self enumerateChildNodesWithName:@"goodie" usingBlock:^(SKNode *node, BOOL *stop) {
        node.physicsBody.dynamic = NO;
    }];
    
    NSLog(@"pause Game");
    [self.pauseNode runAction:[SKAction fadeAlphaTo:0.9f duration:.725]];
    [self addChild:self.pauseNode];
    
    [self removeActionForKey:SPAWN_ACTION_KEY];
}

-(void)continueGame
{
    if (!_pause){ return; }
    
    __attribute__((__blocks__(byref))) SKAction *fade = [SKAction sequence:@[
                                                  [SKAction fadeAlphaTo:0.f duration:.8],
                                                  [SKAction removeFromParent]
                                                  ]];
    
    __attribute__((objc_ownership(weak))) typeof(self) wS = self;
    [self enumerateChildNodesWithName:PAUSE_NODE_NAME
                           usingBlock:^(SKNode *node, BOOL *stop) {
                               [node runAction:fade];
                               [wS startCountdown:^{
                                   [self enumerateChildNodesWithName:@"bomb" usingBlock:^(SKNode *node, BOOL *stop) {
                                       node.physicsBody.dynamic = YES;
                                   }];
                                   
                                   [self enumerateChildNodesWithName:@"goodie" usingBlock:^(SKNode *node, BOOL *stop) {
                                       node.physicsBody.dynamic = YES;
                                   }];
                                   _pause = NO;
                                   [wS spawnRandomItem];
                               }];
                           }];
}

#pragma mark -
-(void)spawnRandomItem
{
    if (_pause)
        return;
    
    CGFloat x = skRand(0, self.frame.size.width);
    bool bomb = [[NSNumber numberWithInt:(int)round(skRand(0, 1) + self->bombChance)] boolValue];
    if (bomb) {
        Bomb *bomb = [[Bomb alloc] initWithPosition:CGPointMake(x, self.frame.size.height + BOMB_SIZE / 2)];
        bomb.physicsBody.usesPreciseCollisionDetection = YES;
        bomb.physicsBody.categoryBitMask = bombCategory;
        bomb.physicsBody.collisionBitMask = bucketCategory;
        bomb.physicsBody.contactTestBitMask = bucketCategory;
        bomb.zRotation = rand();
        [self addChild:bomb];
    } else {
        BOOL bonus = '\0';
        
        double_t percent = 40;
        bonus = (boolean_t)MAX(0, round((double)(skRand(0, 1) - (percent / 100))));
        NSLog(@"bonus: %d", bonus);
        
        __strong NormalGoodies *ng = [[NormalGoodies alloc] initWithRandomItemAndPosition:CGPointMake(x, self.frame.size.height + NORMAL_GOODIE_SIZE / 2) bonus:bonus];
        ng.physicsBody.usesPreciseCollisionDetection = YES;
        ng.physicsBody.categoryBitMask = normalGoodieCategory;
        ng.physicsBody.collisionBitMask = bucketCategory;
        ng.physicsBody.contactTestBitMask = bucketCategory;
        if (![ng.type isEqualToString:GIItemEggs] &&
            ![ng.type isEqualToString:GIItemClocks] &&
            ![ng.type isEqualToString:GIItemWaterDrops])
            ng.zRotation = rand();
        
        [self addChild:ng];
    }
    
    SKAction *spawnAction = [SKAction sequence:@[
                                                 [SKAction waitForDuration:self->waitTimeForNewItem],
                                                 [SKAction performSelector:@selector(spawnRandomItem)
                                                                  onTarget:self]
                                                 ]];
    [self runAction:spawnAction];
}

#pragma mark -
-(void)gameOver: (CGPoint)point
{
    if (self->_gameOver) {
        return;
    } else {
        self->_gameOver = YES;
    }
    
    _pause = YES;
    self->_canPlaySounds = NO;
    
    [[GameCenterHelper sharedInstance] reportScore:(long long)_score
                                     forIdentifier:_GCH_SCORE_LEADERBOARD_IDENTIFIER
                                        andContext:0];
    [self reportAchievementProgress];
    
    self.gameOverScene.score = self->_score;
    self->_score = 0;
    
    // Explosion
    SKSpriteNode *boom = [[SKSpriteNode alloc] initWithImageNamed:@"fire.png"];
    [boom setScale:0.0];
    boom.position = point;
    [boom runAction:[SKAction group:@[[SKAction scaleTo:2.2 duration:1.0],
                                      [SKAction fadeAlphaTo:0.0 duration:1.0],
                                      [SKAction performSelector:@selector(postGameOverNotification)
                                                       onTarget:self],
                                      [SKAction sequence:@[[SKAction waitForDuration:1.0],
                                                           [SKAction removeFromParent],
                                                           ]]]]];
    [self addChild:boom];
}

-(void)postGameOverNotification
{
    SKSpriteNode *goNode = [[SKSpriteNode alloc] initWithColor:[UIColor whiteColor] size:self.frame.size];
    goNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    goNode.zPosition += 40;
    goNode.alpha = 0.0;
    [goNode runAction:[SKAction fadeAlphaTo:1.0 duration:1.0]];
    [self addChild:goNode];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                   (int64_t)(1.2 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       [self.view presentScene:self.gameOverScene
                                    transition:[SKTransition doorsCloseVerticalWithDuration:1.0]];
                       [[NSNotificationCenter defaultCenter] postNotificationName:@"gameOver" object:self];
                   });
}

#pragma mark -

-(void)startCountdown: (void (^)(void))completion
{
    _pause = YES;
    self->countdownNumber = 4;
    SKAction *countdown = [SKAction sequence:@[
                                               [SKAction performSelector:@selector(displayCountdownLabel)
                                                                onTarget:self],
                                               [SKAction waitForDuration:1.0],
                                               [SKAction performSelector:@selector(displayCountdownLabel)
                                                                onTarget:self],
                                               [SKAction waitForDuration:1.0],
                                               [SKAction performSelector:@selector(displayCountdownLabel)
                                                                onTarget:self],
                                               ]];
    [self runAction:countdown];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                  (int64_t)(3 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       completion();
                       _pause = NO;
                   });
}

-(void)displayCountdownLabel
{
    countdownNumber--;
    
    SKLabelNode *label = [SKLabelNode new];
    label.text = [NSString stringWithFormat:@"%d", self->countdownNumber];
    label.fontSize += 10;
    label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    
    SKAction *remove = [SKAction removeFromParent];
    SKAction *fade = [SKAction fadeAlphaTo:0.0 duration:1.0];
    NSArray *actions = @[fade, remove];
    [label runAction:[SKAction sequence:actions]];
    
    [self addChild:label];
}

#pragma mark - GameCenter Methods
-(void)testIfScoreAchievementIsReached
{
    if (self->_score >= 10000) {
        [[GameCenterHelper sharedInstance] reportAchievement:_GCH_ACHIEVEMENT_STANDART_GAMER
                                             percentComplete:100
                                       showsCompletionBanner:TRUE];
        if (self->_score >= 20000) {
            [[GameCenterHelper sharedInstance] reportAchievement:_GCH_ACHIEVEMENT_MEDIUM_GAMER
                                                 percentComplete:100
                                           showsCompletionBanner:TRUE];
            if (self->_score >= 30000) {
                [[GameCenterHelper sharedInstance] reportAchievement:_GCH_ACHIEVEMENT_PRO_GAMER
                                                     percentComplete:100
                                               showsCompletionBanner:TRUE];
            }
            if (self->_score >= 35000) {
                [[GameCenterHelper sharedInstance] reportAchievement:_GCH_ACHIEVEMENT_UNKNOWN_PLAYER
                                                     percentComplete:100
                                               showsCompletionBanner:TRUE];
            }
        }
    }
}

-(void)reportAchievementProgress
{
    NSDictionary *items = [self.info getGIItems];
    
    /*
     pro_gamer          √
     
     only_water_drops   √
     
     medium_gamer       √
     
     standart_gamer     √
     
     zero_points        √
     
     rainbow            √
     
     unknown_player     √
     */
    
    // only_water_drops award
    NSNumber *waterDrops = (NSNumber *)items[GIItemWaterDrops];
    if ([@0 compare:(NSNumber *)items[GIItemClocks]] == NSOrderedSame &&
        [@0 compare:(NSNumber *)items[GIItemEggs]] == NSOrderedSame &&
        [@0 compare:(NSNumber *)items[GIItemFurbis]] == NSOrderedSame &&
        [@0 compare:(NSNumber *)items[GIItemLeafs]] == NSOrderedSame &&
        [@0 compare:(NSNumber *)items[GIItemSnowFlakes]] == NSOrderedSame &&
        [waterDrops intValue] > 0) {
        NSLog(@"only waterdrops!");
        [[GameCenterHelper sharedInstance] reportAchievement:_GCH_ACHIEVEMENT_ONLY_WATER_DROPS
                                             percentComplete:100
                                       showsCompletionBanner:TRUE];
    }
    
    // rainbow award
    if ([@1 compare:(NSNumber *)items[GIItemWaterDrops]] == NSOrderedSame &&
        [@1 compare:(NSNumber *)items[GIItemSnowFlakes]] == NSOrderedSame &&
        [@1 compare:(NSNumber *)items[GIItemLeafs]] == NSOrderedSame &&
        [@1 compare:(NSNumber *)items[GIItemFurbis]] == NSOrderedSame &&
        [@1 compare:(NSNumber *)items[GIItemEggs]] == NSOrderedSame &&
        [@1 compare:(NSNumber *)items[GIItemClocks]] == NSOrderedSame) {
        NSLog(@"rainbow!");
        [[GameCenterHelper sharedInstance] reportAchievement:_GCH_ACHIEVEMENT_RAINBOW
                                             percentComplete:100
                                       showsCompletionBanner:TRUE];
    }
    
    if ([self.info getScore] == 0) {
        NSLog(@"no score award!");
        [[GameCenterHelper sharedInstance] reportAchievement:_GCH_ACHIEVEMENT_ZERO_POINTS
                                             percentComplete:100
                                       showsCompletionBanner:NO];
    }
    
    if (self->_score > 0) {
        GKAchievement *stdGamr = [[GameCenterHelper sharedInstance] getAchievementForIdentifier:_GCH_ACHIEVEMENT_STANDART_GAMER];
        GKAchievement *medGamr = [[GameCenterHelper sharedInstance] getAchievementForIdentifier:_GCH_ACHIEVEMENT_MEDIUM_GAMER];
        GKAchievement *proGamr = [[GameCenterHelper sharedInstance] getAchievementForIdentifier:_GCH_ACHIEVEMENT_PRO_GAMER];
        GKAchievement *unknwnGamr = [[GameCenterHelper sharedInstance] getAchievementForIdentifier:_GCH_ACHIEVEMENT_UNKNOWN_PLAYER];
        
        if (!stdGamr.completed) {
            stdGamr.percentComplete = (double)MIN(100 * ((double)self->_score / 10000), 100);
        }
        if (!medGamr.completed) {
            medGamr.percentComplete = (double)MIN(100 * ((double)self->_score / 20000), 100);
        }
        if (!proGamr.completed) {
            proGamr.percentComplete = (double)MIN(100 * ((double)self->_score / 30000), 100);
        }
        if (!unknwnGamr.completed) {
            unknwnGamr.percentComplete = (double)MIN(100 * ((double)self->_score / 35000), 100);
        }
                
        [[GameCenterHelper sharedInstance] reportAchievements:@[stdGamr, medGamr, proGamr, unknwnGamr]];
    }
}

#pragma mark - SKPhysicsContactDelegate Methods
-(void)didBeginContact:(SKPhysicsContact *)contact
{
    if (contact.bodyA.categoryBitMask == bucketCategory ||
        contact.bodyB.categoryBitMask == bucketCategory) {
        
        if (contact.bodyA.categoryBitMask == normalGoodieCategory ||
            contact.bodyB.categoryBitMask == normalGoodieCategory) {
            if (contact.bodyA.node.class == [NormalGoodies class]) {
                if ([(NormalGoodies *)contact.bodyA.node bonus]) {
                    [self addScoreToGame:500];
                } else {
                    [self addScoreToGame:100];
                }
                [self.info addGIItem:[(NormalGoodies *)contact.bodyA.node type]];
            } else if (contact.bodyB.node.class == [NormalGoodies class]) {
                if ([(NormalGoodies *)contact.bodyB.node bonus]) {
                    [self addScoreToGame:500];
                } else {
                    [self addScoreToGame:100];
                }
                [self.info addGIItem:[(NormalGoodies *)contact.bodyB.node type]];
            }
            if (contact.bodyA.categoryBitMask == normalGoodieCategory)
                [contact.bodyA.node removeFromParent];
            else
                [contact.bodyB.node removeFromParent];
            
            if (self->_canPlaySounds)
                [self runAction:self.popSound];
        } else if (contact.bodyA.categoryBitMask == bombCategory ||
                   contact.bodyB.categoryBitMask == bombCategory) {
            if (contact.bodyA.categoryBitMask == bombCategory) {
                [contact.bodyA.node removeFromParent];
            } else {
                [contact.bodyB.node removeFromParent];
            }
            if (self->_canPlaySounds)
                [self runAction:self.boomSound];
            [self gameOver:contact.contactPoint];
        }
        
    }
}

#pragma mark - actions
-(void)pauseButtContinuePressed
{
    [self continueGame];
}

-(void)pauseButtQuitToMMPressed
{
    [[[UIAlertView alloc] initWithTitle:@"sure?"
                                message:@"do you really want to return to the main menu? You're score won't be submitted to GameCenter"
                               delegate:self
                      cancelButtonTitle:@"cancel"
                      otherButtonTitles:@"quit", nil] show];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // quit :: 1\
       cancel :: 0
    
    if (buttonIndex == 1) {
        self->_score = 0;
        self->_gameOver = YES;
        MainMenu *mm = [[MainMenu alloc] initWithSize:self.size];
        [self.view presentScene:mm transition:[SKTransition doorsCloseVerticalWithDuration:1.0]];
    }
}

#pragma mark - touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    NSLog(@"pause: %d", _pause);
    if (_pause) {
        for (MainMenuButton *obj in _buttons) {
            NSLog(@"button: %@", obj);
            if ([obj containsPoint:[touch locationInNode:self.pauseNode]]) {
                NSLog(@"contains point!");
                [obj tap];
            }
        }
        return;
    }
    
    CGPoint location = [touch locationInNode:self];
    
    if ([_pauseButton containsPoint:location]) {
        _pauseButtonTouchDown = TRUE;
        return;
    }
    
    [self moveBucketToPointToX:location.x];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (_pause){
        for (MainMenuButton *button in self->_buttons) {
            if (![button containsPoint:[touch locationInNode:self.pauseNode]]) {
                [button endTap];
            }
        }
        return;
    }
    
    CGPoint location = [touch locationInNode:self];
    [self moveBucketToPointToX:location.x];
    
    if (![_pauseButton containsPoint:location]) {
        _pauseButtonTouchDown = FALSE;
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if (_pause){
        for (MainMenuButton *button in self->_buttons) {
            if ([button containsPoint:[touch locationInNode:self.pauseNode]]) {
                [button endTap];
                if (button.action) {
                    if ([self respondsToSelector:button.action])
                        [self performSelectorOnMainThread:button.action
                                               withObject:nil
                                            waitUntilDone:NO];
                }
            }
        }
        return;
    }
    
    CGPoint location = [touch locationInNode:self];
    
    if ([_pauseButton containsPoint:location] && _pauseButtonTouchDown == TRUE) {
        _pauseButtonTouchDown = FALSE;
        [self pauseGame];
    }
}

-(void)dealloc
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

@end
