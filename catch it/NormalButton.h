//
//  NormalButton.h
//  catch it
//
//  Created by Lukas Bischof on 21.02.14.
//  Copyright (c) 2014 Lukas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface NormalButton : SKSpriteNode

-(instancetype)initWithImage: (NSString *)image andPosition: (CGPoint)position size: (CGSize)size;
-(void)tap;
-(void)endTap;
-(void)setEnabled: (BOOL)enabled;

@property (nonatomic) BOOL disabled;
@property SEL action;

@end
