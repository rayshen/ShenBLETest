//
//  RootTableViewController.m
//  ShenBluetooth
//
//  Created by shen on 15/5/8.
//  Copyright (c) 2015年 shen. All rights reserved.
//

#import "RootTableViewController.h"

@interface RootTableViewController ()

@end

@implementation RootTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"蓝牙搜索";
    self.centralMgr = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.arrayBLE = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//蓝牙状态delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStatePoweredOn:
            [self.centralMgr scanForPeripheralsWithServices:nil options:nil];
            NSLog(@"start scan Peripherals");

            break;
            
        default:
            NSLog(@"Central Manager did change state");
            break;
    }
}

//发现设备delegate
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    BLEInfo *discoveredBLEInfo = [[BLEInfo alloc] init];
    discoveredBLEInfo.discoveredPeripheral = peripheral;
    discoveredBLEInfo.rssi = RSSI;
    
    // update tableview
    [self saveBLE:discoveredBLEInfo];
   
}

//保存设备信息
- (BOOL)saveBLE:(BLEInfo *)discoveredBLEInfo
{
    for (BLEInfo *info in self.arrayBLE)
    {
        if ([info.discoveredPeripheral.identifier.UUIDString isEqualToString:discoveredBLEInfo.discoveredPeripheral.identifier.UUIDString])
        {
            return NO;
        }
    }
    
    NSLog(@"\nDiscover New Devices!\n");
    NSLog(@"BLEInfo\n UUID：%@\n RSSI:%@\n\n",discoveredBLEInfo.discoveredPeripheral.identifier.UUIDString,discoveredBLEInfo.rssi);
    
    [self.arrayBLE addObject:discoveredBLEInfo];
    [self.tableView reloadData];
    return YES;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _arrayBLE.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    // Step 2: If there are no cells to reuse, create a new one
    if(cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    // Add a detail view accessory
    BLEInfo *thisBLEInfo=[self.arrayBLE objectAtIndex:indexPath.row];
    cell.textLabel.text=[NSString stringWithFormat:@"%@ %@",thisBLEInfo.discoveredPeripheral.name,thisBLEInfo.rssi];
    cell.detailTextLabel.text=[NSString stringWithFormat:@"UUID:%@",thisBLEInfo.discoveredPeripheral.identifier.UUIDString];
    // Step 3: Set the cell text
    
    // Step 4: Return the cell
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BLEInfo *thisBLEInfo=[self.arrayBLE objectAtIndex:indexPath.row];
    DetailViewController* dtvc=[self.storyboard instantiateViewControllerWithIdentifier:@"DetailViewController"];
    dtvc.centralMgr=self.centralMgr;
    dtvc.discoveredPeripheral=thisBLEInfo.discoveredPeripheral;
    
    [self.navigationController pushViewController:dtvc animated:YES];
    
}
@end
