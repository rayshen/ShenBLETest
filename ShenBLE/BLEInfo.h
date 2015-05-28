//
//  BLEInfo.h
//  ShenBluetooth
//
//  Created by shen on 15/5/8.
//  Copyright (c) 2015年 shen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface BLEInfo : NSObject

@property (nonatomic, strong) CBPeripheral *discoveredPeripheral;
@property (nonatomic, strong) NSNumber *rssi;

@end
