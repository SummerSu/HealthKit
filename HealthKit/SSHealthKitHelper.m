//
//  SSHealthKitHelper.m
//  HealthKit
//
//  Created by 孙苏 on 2017/6/2.
//  Copyright © 2017年 sunsu. All rights reserved.
//

#import "SSHealthKitHelper.h"
#import <HealthKit/HealthKit.h>

@interface SSHealthKitHelper ()

@property (nonatomic, strong) HKHealthStore *healthStore;
@property (nonatomic, copy) SSHealthKitHelperBlock block;
@end


@implementation SSHealthKitHelper

-(void)setupHkHealthStore:(SSHealthKitHelperBlock)block
{
    //查看healthKit在设备上是否可用，ipad不支持HealthKit
    if(![HKHealthStore isHealthDataAvailable]) {
        NSLog(@"设备不支持healthKit");
        block(nil);
        return;
    }
    
    self.block = block;
    
    //创建healthStore实例对象
    self.healthStore = [[HKHealthStore alloc] init];
    
    //设置需要获取的权限这里仅设置了步数
    HKObjectType *stepCount = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
     NSSet *healthSet = [NSSet setWithObjects:stepCount, nil,nil];
    
    //从健康应用中获取权限
    [self.healthStore requestAuthorizationToShareTypes:nil readTypes:healthSet completion:^(BOOL success, NSError * _Nullable error) {
        
        NSLog(@"error=error==error===%@==",error);
        if (success) {
            NSLog(@"获取步数权限成功");
            //获取步数后我们调用获取步数的方法
            [self readStepCount];
        } else {
            NSLog(@"获取步数权限失败");
        }
    }];
}


// 查询数据
- (void)readStepCount {
//    //查询采样信息
//    HKSampleType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
//    
//    //NSSortDescriptors用来告诉healthStore怎么样将结果排序。
//    NSSortDescriptor *start = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
//    NSSortDescriptor *end = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
//    
//    /*查询的基类是HKQuery，这是一个抽象类，能够实现每一种查询目标，这里我们需要查询的步数是一个
//     HKSample类所以对应的查询类就是HKSampleQuery。
//     下面的limit参数传1表示查询最近一条数据,查询多条数据只要设置limit的参数值就可以了
//     */
//    
////    @weakify(self);
//    HKSampleQuery *sampleQuery = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:[self predicateForSamplesToday] limit:HKObjectQueryNoLimit sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
//        
////        @strongify(self);
//        NSString *stepStr = @"";
//        BOOL success = NO;
//        if(!error && results) {
//            //打印查询结果
//            NSLog(@"resultCount = %ld result = %@",results.count,results);
//            if (results.count > 0) {
//                NSInteger totleSteps = 0;
//                for(HKQuantitySample *quantitySample in results) {
//                    HKQuantity *quantity = quantitySample.quantity;
//                    HKUnit *heightUnit = [HKUnit countUnit];
//                    NSInteger usersHeight = (NSInteger)[quantity doubleValueForUnit:heightUnit];
//                    totleSteps += usersHeight;
//                }
//                
//                //把结果装换成字符串类型
//                stepStr = [NSString stringWithFormat:@"%ld",(long)totleSteps];
//                success = YES;
//                NSLog(@"最新步数：%@",stepStr);
//            }
//        }
//        
//        if (self.block) {
//            self.block(success, stepStr);
//        }
//    }];
//    //执行查询
//    [self.healthStore executeQuery:sampleQuery];
    
    
    
    //设置需要获取的权限 这里仅设置了步数
    HKObjectType *stepType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    NSSet *healthSet = [NSSet setWithObjects:stepType,nil];

    
    HKQuantityType *sampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    
    
    //NSSortDescriptors用来告诉healthStore怎么样将结果排序。
    
    NSSortDescriptor *start = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierStartDate ascending:NO];
    
    NSSortDescriptor *end   = [NSSortDescriptor sortDescriptorWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    
    
    
    /*查询的基类是HKQuery，这是一个抽象类，能够实现每一种查询目标，这里我们需要查询的步数是一个
     
     HKSample类所以对应的查询类就是HKSampleQuery。
     
     下面的limit参数传1表示查询最近一条数据,查询多条数据只要设置limit的参数值就可以了
     
     */
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *dateCom = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
    
    
    
    NSDate *startDate, *endDate;
    
    endDate = [calendar dateFromComponents:dateCom];
    
    
    
    [dateCom setHour:0];
    
    [dateCom setMinute:0];
    
    [dateCom setSecond:0];
    
    
    
    startDate = [calendar dateFromComponents:dateCom];
    
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionStrictStartDate];
    
    
    
    __weak typeof (&*_healthStore)weakHealthStore = _healthStore;
    
    
    
    HKSampleQuery *q1 = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        double sum = 0;
        
        double sumTime = 0;
        
        NSLog(@"步数结果=%@", results);
        
        for (HKQuantitySample *res in results)
            
        {
            
            
            
            sum += [res.quantity doubleValueForUnit:[HKUnit countUnit]];
            
            
            
            NSTimeZone *zone = [NSTimeZone systemTimeZone];
            
            NSInteger interval = [zone secondsFromGMTForDate:res.endDate];
            
            
            
            NSDate *startDate = [res.startDate dateByAddingTimeInterval:interval];
            
            NSDate *endDate   = [res.endDate dateByAddingTimeInterval:interval];
            
            
            
            sumTime += [endDate timeIntervalSinceDate:startDate];
            
//            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                
//                //查询是在多线程中进行的，如果要对UI进行刷新，要回到主线程中
//                
//                self.title = [NSString stringWithFormat:@"运动步数：%@", @(sum).stringValue];
//                
//            }];
         
//
            
            NSString * step = [NSString stringWithFormat:@"%@",[@(sum) stringValue]];
            if (self.block) {
                self.block(step);
            }
        }
        
        int h = sumTime / 3600;
        
        int m = ((long)sumTime % 3600)/60;
        
        NSLog(@"运动时长：%@小时%@分", @(h), @(m));
        
        NSLog(@"运动步数：%@步", @(sum));
        
        if(error) NSLog(@"1error==%@", error);
        
        [weakHealthStore stopQuery:query];
        
        NSLog(@"\n\n");
        
        
        
 
        
        
    }];
    
    
    
    HKSampleType *timeSampleType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];
    
    HKSampleQuery *q2 = [[HKSampleQuery alloc] initWithSampleType:timeSampleType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        double time = 0;
        
        for (HKQuantitySample *res in results)
            
        {
            
            time += [res.quantity doubleValueForUnit:[HKUnit meterUnit]];
            
        }
        
        NSLog(@"运动距离===%@米", @((long)time));
        
        if(error) NSLog(@"2error==%@", error);
        
        [weakHealthStore stopQuery:query];
        
    }];
    
    
    
    HKSampleType *type3 = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed];
    
    HKSampleQuery *q3 = [[HKSampleQuery alloc] initWithSampleType:type3 predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        double num = 0;
        
        for (HKQuantitySample *res in results)
            
        {
            
            num += [res.quantity doubleValueForUnit:[HKUnit countUnit]];
            
        }
        
        NSLog(@"楼层===%@层", @(num));
        
        if(error) NSLog(@"3error==%@", error);
        
        [weakHealthStore stopQuery:query];
        
    }];
    
    
    
    HKSampleType *type4 = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    
    HKSampleQuery *q4 = [[HKSampleQuery alloc] initWithSampleType:type4 predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:@[start,end] resultsHandler:^(HKSampleQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable results, NSError * _Nullable error) {
        
        double num = 0;
        
        for (HKQuantitySample *res in results)
            
        {
            
            num += [res.quantity doubleValueForUnit:[HKUnit kilocalorieUnit]];
            
        }
        
        NSLog(@"卡路里===%@大卡", @((long)num));
        
        if(error) NSLog(@"4error==%@", error);
        
        [weakHealthStore stopQuery:query];
        
        NSLog(@"\n\n");
        
    }];
    
    
    
    NSDateComponents *dateCom5B = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    
    [dateCom5B setDay:(dateCom5B.day - 10)];
    
    dateCom5B.calendar = calendar;
    
    NSDateComponents *dateCom5E = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    
    dateCom5E.calendar = calendar;
    
    NSPredicate *predicate5 = [HKActivitySummaryQuery predicateForActivitySummaryWithDateComponents:dateCom5B];
    
    //    NSPredicate *predicate5 = [HKActivitySummaryQuery predicateForActivitySummariesBetweenStartDateComponents:dateCom5B endDateComponents:dateCom5E];
    
    HKActivitySummaryQuery *q5 = [[HKActivitySummaryQuery alloc] initWithPredicate:predicate5 resultsHandler:^(HKActivitySummaryQuery * _Nonnull query, NSArray<HKActivitySummary *> * _Nullable activitySummaries, NSError * _Nullable error) {
        
        double energyNum       = 0;
        
        double exerciseNum     = 0;
        
        double standNum        = 0;
        
        double energyGoalNum   = 0;
        
        double exerciseGoalNum = 0;
        
        double standGoalNum    = 0;
        
        for (HKActivitySummary *summary in activitySummaries)
            
        {
            
            energyNum       += [summary.activeEnergyBurned doubleValueForUnit:[HKUnit kilocalorieUnit]];
            
            exerciseNum     += [summary.appleExerciseTime doubleValueForUnit:[HKUnit secondUnit]];
            
            standNum        += [summary.appleStandHours doubleValueForUnit:[HKUnit countUnit]];
            
            energyGoalNum   += [summary.activeEnergyBurnedGoal doubleValueForUnit:[HKUnit kilocalorieUnit]];
            
            exerciseGoalNum += [summary.appleExerciseTimeGoal doubleValueForUnit:[HKUnit secondUnit]];
            
            standGoalNum    += [summary.appleStandHoursGoal doubleValueForUnit:[HKUnit countUnit]];
            
        }
        
        NSLog(@"\n\n");
        
        NSLog(@"健身记录：energyNum=%@",       @(energyNum));
        
        NSLog(@"健身记录：exerciseNum=%@",     @(exerciseNum));
        
        NSLog(@"健身记录：standNum=%@",        @(standNum));
        
        NSLog(@"健身记录：energyGoalNum=%@",   @(energyGoalNum));
        
        NSLog(@"健身记录：exerciseGoalNum=%@", @(exerciseGoalNum));
        
        NSLog(@"健身记录：standGoalNum=%@",    @(standGoalNum));
        
        if(error) NSLog(@"5error==%@", error);
        
        [weakHealthStore stopQuery:query];
        
        NSLog(@"\n\n");
        
        
        

        
    }];
    
    
    
    
    //执行查询
    
    [_healthStore executeQuery:q1];
    
    [_healthStore executeQuery:q2];
    
    [_healthStore executeQuery:q3];
    
    [_healthStore executeQuery:q4];
    
    [_healthStore executeQuery:q5];
    

    
    
}

/*!
 *  获取当天的时间段
 *  @brief  当天时间段
 *
 *  @return 时间段
 */
- (NSPredicate *)predicateForSamplesToday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond: 0];
    
    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
    return predicate;
}
@end
