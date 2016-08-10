//
//  RCTAppleHealthKit+Methods_Body.m
//  RCTAppleHealthKit
//
//  Created by Greg Wilson on 2016-06-26.
//  Copyright © 2016 Greg Wilson. All rights reserved.
//

#import "RCTAppleHealthKit+Methods_Nutrition.h"
#import "RCTAppleHealthKit+Queries.h"
#import "RCTAppleHealthKit+Utils.h"
#import "RCTAppleHealthKit+TypesAndPermissions.h"
#import "RCTConvert.h"

@implementation RCTAppleHealthKit (Methods_Nutrition)


- (void)nutrition_saveMeal:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{

    NSMutableArray *samples = [NSMutableArray array];

    NSDictionary *metadata = @{
      HKMetadataKeyFoodType:@"Lunchbox"
    };

    NSDate *now = [NSDate date];

    for(id key in input) {
      HKUnit *unit = ([key isEqualToString:@"DietaryEnergy"]) ? [HKUnit kilocalorieUnit] : [HKUnit gramUnit];
      double value = [RCTConvert double:[input objectForKey:key]];

      HKQuantitySample* object = [HKQuantitySample
                                     quantitySampleWithType:[self.writePermsDict valueForKey:key]
                                     quantity:[HKQuantity quantityWithUnit:unit doubleValue:value]
                                    startDate:now
                                      endDate:now
                                     metadata:metadata];
      [samples addObject:object];
    }

    // Sets passed to HKCorrelation must end in null

    HKCorrelation* foodCorrelation = [HKCorrelation
                            correlationWithType:[HKCorrelationType correlationTypeForIdentifier:HKCorrelationTypeIdentifierFood]
                            startDate:now
                            endDate:now
                            objects:[NSSet setWithArray:samples]
                            metadata:metadata];

       //
    // double weight = [RCTAppleHealthKit doubleValueFromOptions:input];
    // NSDate *sampleDate = [RCTAppleHealthKit dateFromOptionsDefaultNow:input];
    // HKUnit *unit = [RCTAppleHealthKit hkUnitFromOptions:input key:@"unit" withDefault:[HKUnit poundUnit]];
    //
    // HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:unit doubleValue:weight];
    // HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    // HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:sampleDate endDate:sampleDate];

    [self.healthStore saveObject:foodCorrelation withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"error saving the food correlation: %@", error);
            callback(@[RCTMakeError(@"error saving the food correlation", error, nil)]);
            return;
        }
        callback(@[[NSNull null], input]);
    }];
}

@end
