//
//  RootTableViewController.h
//  ShenBluetooth
//
//  Created by shen on 15/5/8.
//  Copyright (c) 2015年 shen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEInfo.h"
#import "DetailViewController.h"
@interface RootTableViewController : UITableViewController<CBCentralManagerDelegate>

@property (nonatomic, strong) CBCentralManager *centralMgr;
@property (nonatomic, strong) NSMutableArray *arrayBLE;

@end


