//
//  Global.h
//  AntilLost
//
//  Created by vpclub on 15/1/19.
//  Copyright (c) 2015年 vpclub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@interface Global : NSObject
{
    
}

//根据标签ID获取标签字典,如果参数未nil，则返回所有

@property (nonatomic,retain)NSMutableArray *peripheralList;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic,assign)BOOL   isChange;
@property (nonatomic,assign)BOOL   isConnect;   //0是断开连接
@property (nonatomic,assign) NSInteger    language;    // 1为英语  0为汉语
@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic,assign) float  sliderValue;
@property (nonatomic,assign) BOOL  isBackgroud;
@property (nonatomic,assign)  BOOL    isDuanKai;

@property (nonatomic,assign) NSInteger      chaojulishneg;  //1为断开铃声
@property (nonatomic,assign) NSInteger      duankailingsheng;

@property (nonatomic,assign) BOOL      jiebang;

//单例类的模式
+ (Global *)getInstance;

//+(NSMutableArray *)getListPeripheral;


@end
