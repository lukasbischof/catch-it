//
//  Bucket.m
//  catch it
//
//  Created by Lukas Bischof on 14.02.14.
//  Copyright (c) 2014 Lukas. All rights reserved.
//

#import "Bucket.h"

@implementation Bucket

-(instancetype)initWithBucketType:(bucketType)type andPosition:(CGPoint)position
{
    NSString *file = [NSString stringWithFormat:@"bucket_%d.png", type];
    if (self = [super initWithImageNamed:file]) {
        self.position = position;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            self.size = CGSizeMake(self.size.width, self.size.height - 30);
        else
            self.size = CGSizeMake(self.size.width + 10, self.size.height - 10);
        
        CGMutablePathRef bucketPath = CGPathCreateMutable();
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            CGPathMoveToPoint(bucketPath, nil, -50, 35);
            CGPathAddLineToPoint(bucketPath, nil, -30, -40);
            CGPathAddLineToPoint(bucketPath, nil, 30, -40);
            CGPathAddLineToPoint(bucketPath, nil, 50, 35);
        } else {
            CGPathMoveToPoint(bucketPath, nil, -55, 40);
            CGPathAddLineToPoint(bucketPath, nil, -35, -45);
            CGPathAddLineToPoint(bucketPath, nil, 35, -45);
            CGPathAddLineToPoint(bucketPath, nil, 55, 40);
        }
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeChainFromPath:bucketPath];
    }
    return self;
}

@end
