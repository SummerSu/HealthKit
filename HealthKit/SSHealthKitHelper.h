//
//  SSHealthKitHelper.h
//  HealthKit
//
//  Created by 孙苏 on 2017/6/2.
//  Copyright © 2017年 sunsu. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^SSHealthKitHelperBlock)(NSString * stepCount);


@interface SSHealthKitHelper : NSObject

// 开启健康数据中心
-(void)setupHkHealthStore:(SSHealthKitHelperBlock)block;

@end
