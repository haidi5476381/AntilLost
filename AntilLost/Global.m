//
//  Global.m
//  AntilLost
//
//  Created by vpclub on 15/1/19.
//  Copyright (c) 2015年 vpclub. All rights reserved.
//

#import "Global.h"

static Global * instance = nil;

@implementation Global




+ (Global *)getInstance
{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.peripheralList = [[NSMutableArray alloc]init];
        self.language = 0;
    }
    
    return self;
}






@end
