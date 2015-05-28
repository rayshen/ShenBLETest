//
//  DetailTableViewController.m
//  ShenBluetooth
//
//  Created by shen on 15/5/9.
//  Copyright (c) 2015年 shen. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

#define SECTION_NAME @"Serviceinfo"

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_centralMgr setDelegate:self];
    if (_discoveredPeripheral)
    {
        NSLog(@"connectPeripheral");
        [_centralMgr connectPeripheral:_discoveredPeripheral options:nil];
    }
}

//界面退出
-(void)viewWillDisappear:(BOOL)animated{
    [self.centralMgr cancelPeripheralConnection:_discoveredPeripheral];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
//========================================================================================
//0.假设蓝牙关闭、掉线什么的，重新搜索
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStatePoweredOn:
            //[self.centralMgr scanForPeripheralsWithServices:nil options:nil];
            NSLog(@"start scan Peripherals");
            
            break;
            
        default:
            NSLog(@"Central Manager did change state");
            break;
    }
}

//1.搜索后重连
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //[_centralMgr connectPeripheral:_discoveredPeripheral options:nil];
}
//========================================================================================
*/

//2.连接的Delegate 连接若成功则搜索服务
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didFailToConnectPeripheral : %@", error.localizedDescription);
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
    [_discoveredPeripheral setDelegate:self];
    
    //查找服务
    [_discoveredPeripheral discoverServices:nil];
}

//========================================================================================
//3.搜索服务的Delegate 若发现服务，然后搜索其内的特征服务

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        NSLog(@"didDiscoverServices : %@", [error localizedDescription]);
        //        [self cleanup];
        return;
    }
    
    for (CBService *s in peripheral.services)
    {
        NSLog(@"\n>>>服务UUID found with UUID : %@ des:%@", s.UUID,s.UUID.description);
        //查找特征字节
        [s.peripheral discoverCharacteristics:nil forService:s];
    }
}
//========================================================================================
//4.搜索特征的Delegate 若发现特征，则看看这个“通道是发送的还是接收”，接收就read，发送就把这个writeCharacteristic记录下
//注意：不是所有的特性值都是可读的（readable）。通过访问 CBCharacteristicPropertyRead 可以知道特性值是否可读。如果一个特性的值不可读，使用 peripheral:didUpdateValueForCharacteristic:error:就会返回一个错误。
//Subscribing to a Characteristic’s Value(订制一个特性值) 尽管通过 readValueForCharacteristic:方法能够得到特性值，但是对于一个变化的特性值就不是很 有效了。大多数的特性值是变化的，比如一个心率监测应用，如果需要得到特性值，就需要 通过预定的方法获得。当预定了一个特性值，当值改变时，就会收到设备发出的通知。

/*特征值的属性：c.properties
 typedef NS_OPTIONS(NSInteger, CBCharacteristicProperties) {
 // 标识这个characteristic的属性是广播
 CBCharacteristicPropertyBroadcast= 0x01,
 // 标识这个characteristic的属性是读
 CBCharacteristicPropertyRead= 0x02,
 // 标识这个characteristic的属性是写-没有响应
 CBCharacteristicPropertyWriteWithoutResponse= 0x04,
 // 标识这个characteristic的属性是写
 CBCharacteristicPropertyWrite= 0x08,
 // 标识这个characteristic的属性是通知
 CBCharacteristicPropertyNotify= 0x10,
 // 标识这个characteristic的属性是声明
 CBCharacteristicPropertyIndicate= 0x20,
 // 标识这个characteristic的属性是通过验证的
 CBCharacteristicPropertyAuthenticatedSignedWrites= 0x40,
 // 标识这个characteristic的属性是拓展
 CBCharacteristicPropertyExtendedProperties= 0x80,
 // 标识这个characteristic的属性是需要加密的通知
 CBCharacteristicPropertyNotifyEncryptionRequiredNS_ENUM_AVAILABLE(NA, 6_0)= 0x100,
 // 标识这个characteristic的属性是需要加密的申明
 CBCharacteristicPropertyIndicateEncryptionRequiredNS_ENUM_AVAILABLE(NA, 6_0)= 0x200
 };
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
        NSLog(@"didDiscoverCharacteristicsForService error : %@", [error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic *c in service.characteristics)
    {
        NSLog(@"\n>>>\t特征UUID FOUND(in 服务UUID:%@): %@ (data:%@)",service.UUID.description,c.UUID,c.UUID.data);
        
        /*
        根据特征不同属性去读取或者写
        if (c.properties==CBCharacteristicPropertyRead) {
        }
        if (c.properties==CBCharacteristicPropertyWrite) {
        }
        if (c.properties==CBCharacteristicPropertyNotify) {
        }
        */
        
        //假如你和硬件商量好了，某个UUID时写，某个读的，那就不用判断啦
        /*
        if([c.UUID isEqual:[CBUUID UUIDWithString:@"FFF1"]]){
            self.writeCharacteristic = c;
        }
        if([c.UUID isEqual:[CBUUID UUIDWithString:@"FFF6"]]){
            [peripheral readValueForCharacteristic:c];
        }*/
        if (c.properties==CBCharacteristicPropertyRead) {
            [peripheral readValueForCharacteristic:c];
        }
    }
}
//========================================================================================

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"didUpdateValueForCharacteristic error : %@", error.localizedDescription);
        return;
    }
    
    NSLog(@"\nFindtheValueis (UUID:%@):%@ ",characteristic.UUID,characteristic.value);

    /*
    if([characteristic.UUID.description isEqualToString:@"FFF6"]){
        //我这里采用的是16进制数据，如<34001a00>，3400代表湿度十进制52.0，1a00代表温度26.0
        //当然你也可以有自己定义传输字符的意义
        NSData *datavalue=characteristic.value;
        NSData *shidudata=[datavalue subdataWithRange:NSMakeRange(0, 1)];
        NSData *wendudata=[datavalue subdataWithRange:NSMakeRange(2, 1)];
        NSLog(@"\nFind---theValueis:%@   %@-%@",characteristic.value,shidudata,wendudata);
        int i=0,j=0;
        [shidudata getBytes: &i length: sizeof(i)];
        [wendudata getBytes: &j length: sizeof(j)];

        self.current_humitidy=i;
        self.current_temperature=j;
        
        NSLog(@"\n室内温度为：%d℃，室内湿度为：%d%%",_current_temperature,_current_humitidy);
    }
    */
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error changing notification state: %@", [error localizedDescription]);
    }
}

//向peripheral中写入数据后的回调函数
- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSLog(@"write value success : %@", characteristic);
}


//自定义的写入数据的函数
- (void)writeToPeripheral:(NSString *)string{
    if(!_writeCharacteristic){
        NSLog(@"writeCharacteristic is nil!");
        return;
    }
    
    NSData* value = [self stringToByte:string];
    NSLog(@"Witedata: %@",value);
    
    
    [_discoveredPeripheral writeValue:value forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

//====================================================================================================
//一些转换函数，本例中只用到stringToByte
-(NSData*)stringToByte:(NSString*)string
{
    NSString *hexString=[[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++)
    {
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            return nil;
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            return nil;
        
        tempbyt[0] = int_ch1+int_ch2;  ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}

//NSData类型转换成NSString
- (NSString*)hexadecimalString:(NSData *)data{
    NSString* result;
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++){
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    result = [NSString stringWithString:hexString];
    return result;
}
//====================================================================================================


//假设有个swt1,开一下发送一个开关信号，控制LED灯
- (IBAction)led1control:(id)sender {
    UISwitch *swt1= (UISwitch*)sender;
    if (swt1.on) {
        NSLog(@"发送字节11");
        [self writeToPeripheral:@"11"];
    }else{
        NSLog(@"发送字节01");
        [self writeToPeripheral:@"10"];

    }
}

@end
