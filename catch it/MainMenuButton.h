//
//  MainMenuButton.h
//  catch it
//
//  Created by Lukas Bischof on 14.02.14.
//  Copyright (c) 2014 Lukas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MainMenuButton : SKSpriteNode

-(instancetype)initWithDefaultImageAndPosition: (CGPoint)position title: (NSString *)title;
-(void)tap;
-(void)endTap;

@property SEL action;

@end
