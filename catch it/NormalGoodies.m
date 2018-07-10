//
//  NormalGoodies.m
//  catch it
//
//  Created by Lukas Bischof on 15.02.14.
//  Copyright (c) 2014 Lukas. All rights reserved.
//

#import "NormalGoodies.h"

@interface NormalGoodies () {
    NSArray *_physicBodies;
    CGSize _normalSize;
}

@end

@implementation NormalGoodies

-(instancetype)initWithRandomItemAndPosition:(CGPoint)position bonus:(BOOL)$bonus
{
    self->_normalSize = CGSizeMake(NORMAL_GOODIE_SIZE, NORMAL_GOODIE_SIZE);
    
    _PNG_Names = @[
                   @"clock",
                   @"furbi",
                   @"egg",
                   @"snowflake",
                   @"leaf",
                   @"water_drop"
                   ];
    _physicBodies = @[
                      [SKPhysicsBody bodyWithCircleOfRadius:(IPHONE) ? 22 : 35],
                      [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake((IPHONE) ? 31 : 43, NORMAL_GOODIE_SIZE)],
                      [SKPhysicsBody bodyWithCircleOfRadius:(IPHONE) ? 22 : 33],
                      [SKPhysicsBody bodyWithCircleOfRadius:(IPHONE) ? 22 : 34],
                      [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake((IPHONE) ? 28 : 46, NORMAL_GOODIE_SIZE)],
                      [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake((IPHONE) ? 29 : 41, NORMAL_GOODIE_SIZE)]
                      ];
    
    NSUInteger randInd = arc4random() % _PNG_Names.count;
    NSString *fileName = [NSString stringWithFormat:@"%@.png", _PNG_Names[randInd]];
    _type = self.PNG_Names[randInd];
    // NSLog(@"%s: fileName: %@", __PRETTY_FUNCTION__, fileName);
    
    if (self = [super initWithImageNamed:fileName]) {
        self.size = self->_normalSize;
        self.physicsBody = _physicBodies[randInd];
        self.physicsBody.usesPreciseCollisionDetection = YES;
        self.physicsBody.dynamic = self.physicsBody.affectedByGravity = YES;
        self.position = position;
        self.name = @"goodie";
        
        _bonus = $bonus;
        if ($bonus) {
            SKEmitterNode *bonus = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"Bonus" ofType:@"sks"]];
            NSArray *sequence = @[
                                  [SKAction group:@[
                                                    [SKAction fadeAlphaTo:0.6 duration:0.32],
                                                    [SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:0.4 duration:0.32]
                                                    ]],
                                  [SKAction group:@[
                                                    [SKAction fadeAlphaTo:1.0 duration:0.32],
                                                    [SKAction colorizeWithColor:[UIColor redColor] colorBlendFactor:0.0 duration:0.32]
                                                    ]]];
            [self runAction:[SKAction repeatActionForever:[SKAction sequence:sequence]]];
            [self addChild:bonus];
        }
    }
    return self;
}

@end
