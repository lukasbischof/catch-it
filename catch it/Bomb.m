//
//  Bomb.m
//  catch it
//
//  Created by Lukas Bischof on 14.02.14.
//  Copyright (c) 2014 Lukas. All rights reserved.
//

#import "Bomb.h"

#define BOMB_COUNT 10

@interface Bomb () {
    NSMutableArray *textures;
}
@end

@implementation Bomb

-(id)initWithPosition:(CGPoint)position
{
    if (self = [super init]) {
        self.texture = [SKTexture textureWithImageNamed:@"bomb.png"];
        self.position = position;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            self.size = CGSizeMake(50, 50);
        else
            self.size = CGSizeMake(80, 80);
        self.name = @"bomb";
        
#ifdef __IPHONE_7_1
        if ([[[UIDevice currentDevice] systemVersion] isEqualToString:@"7.1"]) {
            NSArray *bodies;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                bodies = @[[SKPhysicsBody bodyWithCircleOfRadius:21
                                                          center:CGPointMake(0, 0)],
                           [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(8, 10)
                                                           center:CGPointMake(sin(45 * M_PI / 180) * 20,
                                                                              cos(45 * M_PI / 180) * 20)]];
            } else {
                bodies = @[[SKPhysicsBody bodyWithCircleOfRadius:35
                                                          center:CGPointMake(0, 0)],
                           [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(10, 12)
                                                           center:CGPointMake(sin(45 * M_PI / 180) * 33,
                                                                              cos(45 * M_PI / 180) * 33)]];
            }
            
            self.physicsBody = [SKPhysicsBody bodyWithBodies:bodies];
        } else {
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:21];
            } else {
                self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:35];
            }
        }
#else
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:21];
        } else {
            self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:35];
        }
#endif
        self.physicsBody.affectedByGravity = self.physicsBody.dynamic = YES;
        
        textures = [NSMutableArray new];
        for (NSUInteger i = 1; i <= BOMB_COUNT; i++) {
            NSString *name = [NSString stringWithFormat:@"bomb_%lu.png", (unsigned long)i];
            [textures addObject:[SKTexture textureWithImageNamed:name]];
        }
        
        SKAction *burn = [SKAction animateWithTextures:textures
                                          timePerFrame:0.055];
        [self runAction:[SKAction repeatActionForever:burn]];
    }
    return self;
}

@end
