//
//  Bucket.h
//  catch it
//
//  Created by Lukas Bischof on 14.02.14.
//  Copyright (c) 2014 Lukas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum {
    bucketTypeWood = 1
}bucketType;

@interface Bucket : SKSpriteNode

-(instancetype)initWithBucketType: (bucketType)type andPosition: (CGPoint)position;

@end
