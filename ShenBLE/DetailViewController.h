//
//  DetailTableViewController.h
//  ShenBluetooth
//
//  Created by shen on 15/5/9.
//  Copyright (c) 2015年 shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface DetailViewController : UIViewController<
CBPeripheralManagerDelegate,
CBCentralManagerDelegate,
CBPeripheralDelegate
>

@property (nonatomic, strong) CBCentralManager *centralMgr;
@property (nonatomic, strong) CBPeripheral *discoveredPeripheral;
@property (strong, nonatomic) CBCharacteristic* writeCharacteristic;

@property int current_humitidy;
@property int current_temperature;

- (IBAction)led1control:(id)sender;

@end
