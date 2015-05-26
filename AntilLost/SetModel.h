//
//  SetModel.h
//  AntilLost
//
//  Created by vpclub on 15/1/30.
//  Copyright (c) 2015年 vpclub. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SetModel : NSObject

@property (nonatomic,strong) NSString *name;
@property (nonatomic,assign) BOOL   isContent;
@property (nonatomic,assign) int    style;
@property (nonatomic,assign) float    distance;
@property (nonatomic,assign) BOOL    isShake;
@property (nonatomic,assign) BOOL      isRing;
@property (nonatomic,assign) BOOL      isBangDing;


@end
