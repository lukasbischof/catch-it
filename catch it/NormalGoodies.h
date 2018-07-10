//
//  NormalGoodies.h
//  catch it
//
//  Created by Lukas Bischof on 15.02.14.
//  Copyright (c) 2014 Lukas. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#define NORMAL_GOODIE_SIZE (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) ? 50 : 70)
#define IPHONE (([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) ? 1 : 0)

@interface NormalGoodies : SKSpriteNode

-(instancetype)initWithRandomItemAndPosition: (CGPoint)position bonus: (BOOL)bonus;

@property (strong, readonly) NSString *type;
@property (nonatomic, readonly) BOOL bonus;
@property (strong, nonatomic) NSArray *PNG_Names;;

@end
