//
//  MainMenuButton.m
//  catch it
//
//  Created by Lukas Bischof on 14.02.14.
//  Copyright (c) 2014 Lukas. All rights reserved.
//

#import "MainMenuButton.h"
#import "NormalGoodies.h"

const uint32_t category = 0x1;

static NSString *ipadName_pressed = @"MM_button@2x_pressed.png";
static NSString *iPhoneName_pressed = @"MM_button_pressed.png";
static NSString *iphoneName = @"MM_button_normal.png";
static NSString *ipadName = @"MM_button@2x_normal.png";

@interface MainMenuButton ()

@property (strong, nonatomic) SKLabelNode *title;

@end

@implementation MainMenuButton

signed int getNotTappedTitle()
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return -9;
    else
        return -15;
};

signed int getTappedTitle()
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return -11;
    else
        return -17;
};

-(instancetype)initWithDefaultImageAndPosition:(CGPoint)position title:(NSString *)title
{
    if (self = [super initWithImageNamed:(IPHONE) ? iphoneName : ipadName]) {
        self.title = [[SKLabelNode alloc] initWithFontNamed:@"Helvetica"];
        self.title.text = title;
        self.title.fontColor = [UIColor whiteColor];
        //self.title.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        self.title.position = CGPointMake(0, getNotTappedTitle());
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            self.size = CGSizeMake(220, 50);
        } else {
            self.size = CGSizeMake(490, 115);
            self.title.fontSize += 25;
        }
        
        self.position = position;
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:(IPHONE) ? self.size : CGSizeMake(470, 115)];
        self.physicsBody.affectedByGravity = NO;
        self.physicsBody.dynamic = NO;
        self.physicsBody.categoryBitMask = category;
        
        [self addChild:self.title];
    }
    return self;
}

-(void)tap
{
    self.texture = [SKTexture textureWithImageNamed:(IPHONE) ? iPhoneName_pressed : ipadName_pressed];
    self.title.position = CGPointMake(0, getTappedTitle());
}

-(void)endTap
{
    self.texture = [SKTexture textureWithImageNamed:(IPHONE) ? iphoneName : ipadName];
    self.title.position = CGPointMake(0, getNotTappedTitle());
}

@end
