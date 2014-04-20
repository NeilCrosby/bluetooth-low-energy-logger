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
    [self manageLogMessage:[NSString stringWithFormat:@"%@\t%@\t%@",
                                peripheral.identifier.UUIDString,
                                peripheral.name,
                                RSSI
                            ]
                          :peripheral.identifier.UUIDString
    ];

    [self.myCentralManager stopScan];
    [self.myCentralManager scanForPeripheralsWithServices:nil options:nil];
}

- (void) manageLogMessage:(NSString *)message {
    [self manageLogMessage:message :NULL];
}
    
- (void) manageLogMessage:(NSString *)message :(NSString *) bleIdentifier {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':'ss"];
    NSString *myDateString = [dateFormatter stringFromDate:[[NSDate alloc] init]];
    
    message = [NSString stringWithFormat:@"%@\t%@\n", myDateString, message];
    
    NSLog(@"%@", message);
    
    [_arrayController addObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                  message, @"log",
                                  nil
                                  ]
     ];
    
    [self writeToLogFile: message :self.logFileLocation];
    
    if (bleIdentifier) {
        NSString *filename = [bleIdentifier stringByAppendingPathExtension:@"log"];

        [self writeToLogFile: message :[self.logFileDirectory stringByAppendingPathComponent:filename]];
    }
}

- (void)writeToLogFile:(NSString *)message :(NSString *)filePath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [@"" writeToFile:filePath atomically:NO];
        
    }
    
    NSFileHandle *aFileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    [aFileHandle truncateFileAtOffset:[aFileHandle seekToEndOfFile]];
    [aFileHandle writeData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    [aFileHandle closeFile];
    
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStatePoweredOff:
            [self manageLogMessage: @"CoreBluetooth BLE hardware is powered off"];
            break;
        case CBCentralManagerStatePoweredOn:
            [self manageLogMessage: @"CoreBluetooth BLE hardware is powered on and ready"];
            [self.myCentralManager scanForPeripheralsWithServices:nil options:nil];
            break;
        case CBCentralManagerStateResetting:
            [self manageLogMessage: @"CoreBluetooth BLE hardware is resetting"];
            break;
        case CBCentralManagerStateUnauthorized:
            [self manageLogMessage: @"CoreBluetooth BLE state is unauthorized"];
            break;
        case CBCentralManagerStateUnknown:
            [self manageLogMessage: @"CoreBluetooth BLE state is unknown"];
            break;
        case CBCentralManagerStateUnsupported:
            [self manageLogMessage: @"CoreBluetooth BLE hardware is unsupported on this platform"];
            break;
        default:
            break;
    }
}


@end
