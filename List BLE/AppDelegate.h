//
//  AppDelegate.h
//  List BLE
//
//  Created by Neil Crosby on 09/04/2014.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <IOBluetooth/IOBluetooth.h>


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property CBCentralManager *myCentralManager;
@property NSString *logFileLocation;
@property NSString *logFileDirectory;

@property (weak) IBOutlet NSArrayController *arrayController;
@end
