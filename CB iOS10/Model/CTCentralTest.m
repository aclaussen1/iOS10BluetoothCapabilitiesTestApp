//
//  CTCentralTest.m
//  CB iOS10
//
//  Created by Max on 15/08/2016.
//  Copyright © 2016 Schneider Electric (Australia) Pty Ltd. All rights reserved.
//

#import "CTCentralTest.h"
#import <ExternalAccessory/ExternalAccessoryDefines.h>
#import <ExternalAccessory/EAAccessoryManager.h>
#import <ExternalAccessory/EAAccessory.h>
#import <ExternalAccessory/EASession.h>
#import <ExternalAccessory/EAWiFiUnconfiguredAccessoryBrowser.h>
#import <ExternalAccessory/EAWiFiUnconfiguredAccessory.h>
@import CoreBluetooth;
@import UIKit;

@interface CTCentralTest () <CBCentralManagerDelegate>

@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) EAAccessoryManager *eaSessionManager;

@end

@implementation CTCentralTest

+ (instancetype)sharedInstance {
    
    static CTCentralTest *centralTest = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        centralTest = [[[self class] alloc] init];
    });
    return centralTest;
}

- (instancetype)init {
    
    if (self = [super init]) {

        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
           
            self.peripherals = nil;
        }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
            
            self.peripherals = nil;
        }];
    }
    
    self.eaSessionManager = [EAAccessoryManager sharedAccessoryManager];
    NSArray *connectedAccessories = self.eaSessionManager.connectedAccessories;
    for (EAAccessory* ea in connectedAccessories) {
        NSLog(@"name of accessory: @%", ea.name);
    }

    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (NSString *)keyPathPeripherals {
    return NSStringFromSelector(@selector(peripherals));
}

- (void)startScan {
    
    NSLog(@"startScan %@", self.centralManager);
    if (!self.centralManager) {
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }

    [self tryScan];
}

- (void)tryScan {
    NSLog(@"hi1");
    //[self.centralManager retrieveConnectedPeripheralsWithServices:<#(nonnull NSArray<CBUUID *> *)#>]
    
    if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
         NSLog(@"hi2");
        [self.centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES }];
        NSLog(@"hi3");
    }
}

- (void)stopScan {
    [self.centralManager stopScan];
}

#pragma mark - Helpers
- (void)addPeripheralsFromArray:(NSArray *)array {
    
    if (!self.peripherals) {
    
        self.peripherals = array;
    }
    else {
        self.peripherals = [self.peripherals arrayByAddingObjectsFromArray:array];
    }
}

- (CTPeripheralInfo *)peripheralInfoForIdentifier:(NSString *)identifier {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"identifier==%@", identifier];
    return [self.peripherals filteredArrayUsingPredicate:predicate].firstObject;
}

- (CTPeripheralInfo *)peripheralInfoForPeripheral:(CBPeripheral *)peripheral {
    CTPeripheralInfo *info = [[CTPeripheralInfo alloc] init];
    info.identifier = peripheral.identifier.UUIDString;
    info.name = peripheral.name ? peripheral.name : @"empty";
    return info;
}

#pragma mark - CBCentralManager delegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    
    [self tryScan];
}
/*
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    
    CTPeripheralInfo *info = [self peripheralInfoForIdentifier:peripheral.identifier.UUIDString];
    //NSLog(@"peripheral:%@ %@", peripheral.name, RSSI);
    NSLog(@"peripheral:%@ peripheralID:%@, %@", peripheral.name, peripheral.identifier.UUIDString,RSSI);
    
    if (info) {
        info.seenCount ++;
        info.manufactureData = advertisementData[CBAdvertisementDataManufacturerDataKey];
    }
    else {
        //
        
        [self addPeripheralsFromArray:@[[self peripheralInfoForPeripheral:peripheral]]];
    }

}*/
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSString *localName = [advertisementData objectForKey:CBAdvertisementDataLocalNameKey];
    
    if ([localName length] > 0){
        NSLog(@"Discovered: %@ RSSI: %@", peripheral.name, RSSI);
        // your other needs ...
    }
}

@end
