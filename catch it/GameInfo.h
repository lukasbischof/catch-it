//
//  GameInfo.h
//  catch it
//
//  Created by Lukas Bischof on 28.02.14.
//  Copyright (c) 2014 Lukas. All rights reserved.
//

#import <Foundation/Foundation.h>

//@"clock",
//@"furbi",
//@"egg",
//@"snowflake",
//@"leaf",
//@"water_drop"

#define GIDateProperty @"GIDate"
#define GIScoreProperty @"GIScore"
#define GIItemsProperty @"GIItems"

#define GIItemClocks @"clock"
#define GIItemFurbis @"furbi"
#define GIItemEggs @"egg"
#define GIItemSnowFlakes @"snowflake"
#define GIItemLeafs @"leaf"
#define GIItemWaterDrops @"water_drop"

@interface GameInfo : NSObject

-(instancetype)initWithDate: (NSDate *)date;
-(void)setScore: (long unsigned)score;
-(unsigned long)getScore;
-(void)addGIItem: (NSString *)item;
-(NSDictionary *)getGIItems;
-(NSNumber *)getGIItemValueForItem: (NSString *)item;

@end
