//
//  GameInfo.m
//  catch it
//
//  Created by Lukas Bischof on 28.02.14.
//  Copyright (c) 2014 Lukas. All rights reserved.
//

#import "GameInfo.h"

@interface GameInfo ()

@property (strong, nonatomic) NSMutableDictionary *info;

@end

@implementation GameInfo

-(instancetype)initWithDate:(NSDate *)date
{
    if (self = [super init]) {
        self.info = [NSMutableDictionary new];
        [self.info setValue:date forKey:GIDateProperty];
        [self.info setValue:[@{GIItemClocks     : @0,
                               GIItemEggs       : @0,
                               GIItemFurbis     : @0,
                               GIItemLeafs      : @0,
                               GIItemSnowFlakes : @0,
                               GIItemWaterDrops : @0} mutableCopy] forKey:GIItemsProperty];
        [self.info setValue:@0 forKey:GIScoreProperty];
    }
    
    return self;
}

-(void)setScore:(unsigned long)score
{
    [self.info setValue:[NSNumber numberWithUnsignedLong:score]
                 forKey:GIScoreProperty];
}

-(unsigned long)getScore
{
    return [(NSNumber *)self.info[GIScoreProperty] unsignedLongValue];
}

-(void)addGIItem:(NSString *)item
{
    self.info[GIItemsProperty][item] = [NSNumber numberWithInt:[(NSNumber *)self.info[GIItemsProperty][item] intValue] + 1];
}

-(NSDictionary *)getGIItems
{
    return self.info[GIItemsProperty];
}

-(NSNumber *)getGIItemValueForItem:(NSString *)item
{
    return self.info[GIItemsProperty][item];
}

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ info: %@", [super description], self.info];
}

@end