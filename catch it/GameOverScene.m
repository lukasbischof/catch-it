//
//  GameOverScene.m
//  catch it
//
//  Created by Lukas Bischof on 21.02.14.
//  Copyright (c) 2014 Lukas. All rights reserved.
//

#import "GameOverScene.h"
#import "MainMenuButton.h"
#import "NormalButton.h"
#import "GameScene.h"
#import "MainMenu.h"
#import <Social/Social.h>

#define getp(element) [self getPositionForelement:element]
#define _NAT_DEFNOTCE_ [NSNotificationCenter defaultCenter]

typedef NS_ENUM(short signed int, elements){
    elementTitleNode,
    elementScoreNode,
    elementPlayAgainButt,
    elementMainMenuButt,
    elementFaceBookButt,
    elementTwitterButt
};

@interface GameOverScene () {
    NSArray *_buttons;
    NSArray *_normalButtons;
}

@property (strong, nonatomic) SKLabelNode *titleNode;
@property (strong, nonatomic) SKLabelNode *scoreNode;
@property (strong, nonatomic) MainMenuButton *playAgainButton;
@property (strong, nonatomic) MainMenuButton *mainMenuButton;
@property (strong, nonatomic) NormalButton *twitterButton;
@property (strong, nonatomic) NormalButton *facebookButton;

@end

@implementation GameOverScene

-(instancetype)initWithSize:(CGSize)size
{
    if (!(self = [super initWithSize:size])) {
        // configure the Scene
    }
    return self;
}

-(CGPoint)getPositionForelement: (elements)element
{
    CGPoint point;
    switch (element) {
#ifdef IPHONE
        case elementMainMenuButt:
            if (IPHONE)
                point = CGPointMake(self.size.width / 2, self.size.height - 330);
            else
                point = CGPointMake(self.size.width / 2, self.size.height - 680);
        break;
        case elementPlayAgainButt:
            if (IPHONE)
                point = CGPointMake(self.size.width / 2, self.size.height - 250);
            else
                point = CGPointMake(self.size.width / 2, self.size.height - 500);
        break;
        case elementFaceBookButt:
            if (IPHONE)
                point = CGPointMake(80, self.size.height - 430);
            else
                point = CGPointMake(298, self.size.height - 350);
        break;
        case elementScoreNode:
            if (IPHONE)
                point = CGPointMake(self.view.frame.size.width / 2, self.size.height - 140);
            else
                point = CGPointMake(self.view.frame.size.width / 2, self.size.height - 195.8);
        break;
        case elementTitleNode:
            if (IPHONE)
                point = CGPointMake(self.view.frame.size.width / 2, self.size.height - 80);
            else
                point = CGPointMake(self.view.frame.size.width / 2, self.size.height - 110);
        break;
        case elementTwitterButt:
            if (IPHONE)
                point = CGPointMake(self.size.width - 88, self.size.height - 430);
            else
                point = CGPointMake(self.size.width - 298, self.size.height - 350);
        break;
#endif
        default:
            point = CGPointZero;
        break;
    }
    
    return point;
}

-(void)didMoveToView:(SKView *)view
{
    _buttons = [NSArray new];
    _normalButtons = [NSArray alloc];
    _normalButtons = [_normalButtons init];
    
    self.backgroundColor = [UIColor colorWithRed:0.7
                                           green:0.7
                                            blue:0.2
                                           alpha:1.0];
    
    SKSpriteNode *back = [[SKSpriteNode alloc] initWithImageNamed:@"MM_back.png"];
    back.size = self.size;
    back.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    back.alpha = 0.8;
    [self addChild:back];
    
    self.titleNode = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    self.titleNode.text = @"Game Over";
#ifdef IPHONE
    self.titleNode.fontSize = (IPHONE) ? 40 : 80;
#else
    self.titleNode.fontSize = 40;
#endif
    self.titleNode.position = getp(elementTitleNode);
    self.titleNode.fontColor = [UIColor blackColor];
    [self addChild:self.titleNode];
    
    self.scoreNode = [[SKLabelNode alloc] initWithFontNamed:@"Chalkduster"];
    self.scoreNode.text = [NSString stringWithFormat:@"Score: %lu", self.score];
#ifdef IPHONE
    self.scoreNode.fontSize = (IPHONE) ? 30 : 60;
#else
    self.scoreNode.fontSize = 30;
#endif
    self.scoreNode.position = getp(elementScoreNode);
    self.scoreNode.fontColor = [UIColor darkGrayColor];
    [self addChild:self.scoreNode];
    
    self.playAgainButton = [[MainMenuButton allocWithZone:nil] initWithDefaultImageAndPosition:getp(elementPlayAgainButt) title:@"play again"];
    self.playAgainButton.action = @selector(playAgainButtonTapped);
    [self addChild:self.playAgainButton];
    
    self.mainMenuButton = [[MainMenuButton allocWithZone:nil] initWithDefaultImageAndPosition:getp(elementMainMenuButt) title:@"main menu"];
    self.mainMenuButton.action = @selector(mainMenuButtonTapped);
    [self addChild:self.mainMenuButton];
    
    const CGFloat bttSizeIphone = 50.f;
    const CGFloat bttSizeIpad = 70.f;
    
    self.facebookButton = [[NormalButton alloc] initWithImageNamed:@"facebook.png"];
    self.facebookButton.position = getp(elementFaceBookButt);
    self.facebookButton.size = (IPHONE) ? CGSizeMake(bttSizeIphone, bttSizeIphone) : CGSizeMake(bttSizeIpad, bttSizeIpad);
    self.facebookButton.action = @selector(facebookButtonTapped);
    [self addChild:self.facebookButton];
    
    self.twitterButton = [[NormalButton alloc] initWithImageNamed:@"twitter.png"];
    self.twitterButton.position = getp(elementTwitterButt);
    self.twitterButton.size = (IPHONE) ? CGSizeMake(bttSizeIphone, bttSizeIphone) : CGSizeMake(bttSizeIpad, bttSizeIpad);
    self.twitterButton.action = @selector(twitterButtonTapped);
    [self addChild:self.twitterButton];
    
    _buttons = @[self.playAgainButton,
                self.mainMenuButton];
    
    _normalButtons = @[self.facebookButton,
                       self.twitterButton
                       ];
    
    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
        [self.facebookButton setEnabled:NO];
    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
        [self.twitterButton setEnabled:NO];
}

#pragma mark - actions
-(void)playAgainButtonTapped
{
    GameScene *gs = [[GameScene alloc] initWithSize:self.size];
    [self.view presentScene:gs transition:[SKTransition doorsOpenVerticalWithDuration:1.0]];
}

-(void)mainMenuButtonTapped
{
    MainMenu *mm = [[MainMenu alloc] initWithSize:self.size];
    [self.view presentScene:mm transition:[SKTransition crossFadeWithDuration:0.5]];
}

-(void)twitterButtonTapped
{
    [_NAT_DEFNOTCE_ postNotificationName:@"twitterBT"
                            object:self
                          userInfo:@{@"score" : [NSNumber numberWithUnsignedLong:self.score]}];
}

-(void)facebookButtonTapped
{
   [_NAT_DEFNOTCE_ postNotificationName:@"facebookBT"
                           object:self
                         userInfo:@{@"score": [NSNumber numberWithUnsignedLong:self.score]}];
}

#pragma mark - touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    for (MainMenuButton *button in self->_buttons) {
        if ([button containsPoint:[touch locationInNode:self]]) {
            [button tap];
        }
    }
    for (NormalButton *button in self->_normalButtons) {
        if ([button containsPoint:[touch locationInNode:self]] && !button.disabled) {
            [button tap];
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    for (MainMenuButton *button in self->_buttons) {
        if (![button containsPoint:[touch locationInNode:self]]) {
            [button endTap];
        }
    }
    for (NormalButton *button in self->_normalButtons) {
        if (![button containsPoint:[touch locationInNode:self]] && !button.disabled) {
            [button endTap];
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    for (MainMenuButton *button in self->_buttons) {
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
    for (NormalButton *button in self->_normalButtons) {
        if ([button containsPoint:[touch locationInNode:self]] && !button.disabled) {
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

@end
