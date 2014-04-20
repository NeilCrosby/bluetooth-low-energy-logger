//
//  AppDelegate.m
//  List BLE
//
//  Created by Neil Crosby on 09/04/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate() <CBCentralManagerDelegate>
@end

@implementation AppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString *filename = [@"bluetooth-low-energy-advertisers" stringByAppendingPathExtension:@"log"];
    self.logFileDirectory = [@"~/Library/Logs/ble-watcher" stringByExpandingTildeInPath];

    NSError * error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:self.logFileDirectory
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    if (error != nil) {
        NSLog(@"error creating directory: %@", error);
    }
    
    self.logFileLocation = [self.logFileDirectory stringByAppendingPathComponent:filename];
    
    self.myCentralManager =
    [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    [self writeToLogFile:
     [NSString stringWithFormat:@"%@\t%@\t%@",
     peripheral.identifier.UUIDString,
     peripheral.name,
     RSSI
     ]
    ];

    [self.myCentralManager stopScan];
    [self.myCentralManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)writeToLogFile:(NSString *)message {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':'ss"];
    NSString *myDateString = [dateFormatter stringFromDate:[[NSDate alloc] init]];
    
    message = [NSString stringWithFormat:@"%@\t%@\n", myDateString, message];
    
    NSLog(@"%@", message);

    if (![[NSFileManager defaultManager] fileExistsAtPath:self.logFileLocation]) {
        [@"" writeToFile:self.logFileLocation atomically:NO];
         
    }
    
    NSFileHandle *aFileHandle = [NSFileHandle fileHandleForWritingAtPath:self.logFileLocation];
    [aFileHandle truncateFileAtOffset:[aFileHandle seekToEndOfFile]];
    [aFileHandle writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    [aFileHandle closeFile];
    
    [_arrayController addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  message, @"log",
                                  nil
                                  ]
     ];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            [self writeToLogFile: @"CoreBluetooth BLE hardware is powered off"];
            break;
        case CBCentralManagerStatePoweredOn:
            [self writeToLogFile: @"CoreBluetooth BLE hardware is powered on and ready"];
            [self.myCentralManager scanForPeripheralsWithServices:nil options:nil];
            break;
        case CBCentralManagerStateResetting:
            [self writeToLogFile: @"CoreBluetooth BLE hardware is resetting"];
            break;
        case CBCentralManagerStateUnauthorized:
            [self writeToLogFile: @"CoreBluetooth BLE state is unauthorized"];
            break;
        case CBCentralManagerStateUnknown:
            [self writeToLogFile: @"CoreBluetooth BLE state is unknown"];
            break;
        case CBCentralManagerStateUnsupported:
            [self writeToLogFile: @"CoreBluetooth BLE hardware is unsupported on this platform"];
            break;
        default:
            break;
    }
}


@end
