//
//  NormalButton.m
//  catch it
//
//  Created by Lukas Bischof on 21.02.14.
//  Copyright (c) 2014 Lukas. All rights reserved.
//

#import "NormalButton.h"

@interface NormalButton ()

@property UIImage *normalImage;

@end

@implementation NormalButton

-(instancetype)initWithImage:(NSString *)image
                 andPosition:(CGPoint)position
                        size:(CGSize)size
{
    if (!(self = [super initWithImageNamed:image])) {
        self.size = size;
        self.position = position;
    }
    
    return self;
}

-(void)setEnabled:(BOOL)enabled
{
    self.disabled = enabled ? FALSE : TRUE;
    self.alpha = self.disabled ? 0.6 : 1.0;
}

-(void)tap
{
    if (self.disabled)
        return;
    [self runAction:[SKAction fadeAlphaTo:0.6 duration:0.05]];
}

-(void)endTap
{
    if (self.disabled) {
        return;
    }
    [self runAction:[SKAction fadeAlphaTo:1.0 duration:0.3]];
}

@end
