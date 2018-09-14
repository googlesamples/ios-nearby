#import "AppDelegate.h"

#import <GNSMessages.h>

#import "MessageViewController.h"

static NSString * const kMyAPIKey = @"<insert API key here>";
static NSString * const kBackgroundScanningSaveKey = @"NearbyBackgroundBeaconScanningEnabled";


@interface AppDelegate ()
@property(nonatomic) GNSPermission *nearbyPermission;
@property(nonatomic) GNSMessageManager *messageMgr;
@property(nonatomic) id<GNSSubscription> subscription;
@property(nonatomic) UINavigationController *navController;
@property(nonatomic) MessageViewController *messageViewController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  _messageViewController = [[MessageViewController alloc] init];
  _navController =
      [[UINavigationController alloc] initWithRootViewController:_messageViewController];
  self.window.rootViewController = _navController;
  [self.window makeKeyAndVisible];

  // Register for local notifications, which will alert the user when a beacon is found.
  if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
    [[UIApplication sharedApplication] registerUserNotificationSettings:
        [UIUserNotificationSettings settingsForTypes:
            UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound
                                          categories:nil]];
  }

  // Set up the message view navigation buttons.
  __weak __typeof__(self) weakSelf = self;
  _nearbyPermission = [[GNSPermission alloc] initWithChangedHandler:^(BOOL granted) {
    // Keep the Nearby permission button title in sync with the Nearby permission state.
    weakSelf.messageViewController.leftBarButton = [[UIBarButtonItem alloc]
        initWithTitle:[NSString stringWithFormat:@"%@ Nearby", granted ? @"Deny" : @"Allow"]
                style:UIBarButtonItemStyleBordered
               target:self
               action:@selector(toggleNearbyPermission)];
  }];
  [self updateStartStopButton];

  // Enable debug logging to help track down problems.
  [GNSMessageManager setDebugLoggingEnabled:YES];

  // Create the message manager, which lets you publish messages and subscribe to messages
  // published by nearby devices.
  void (^paramsBlock)(GNSMessageManagerParams *) = ^(GNSMessageManagerParams *params) {
    // This is called when Bluetooth permission is enabled or disabled by the user.
    params.bluetoothPermissionErrorHandler = ^(BOOL hasError) {
      if (hasError) {
        NSLog(@"Nearby works better if Bluetooth use is allowed");
      }
    };
    // This is called when Bluetooth is powered on or off by the user.
    params.bluetoothPowerErrorHandler = ^(BOOL hasError) {
      if (hasError) {
        NSLog(@"Nearby works better if Bluetooth is turned on");
      }
    };
  };
  _messageMgr = [[GNSMessageManager alloc] initWithAPIKey:kMyAPIKey paramsBlock:paramsBlock];

  // If background scanning was enabled, start scanning on startup.
  if ([[NSUserDefaults standardUserDefaults] boolForKey:kBackgroundScanningSaveKey]) {
    [self startScanning];
  }

  return YES;
}

/// Sets up the right bar button to start or stop scanning, depending on current mode.
- (void)updateStartStopButton {
  BOOL isScanning = (_subscription != nil);
  _messageViewController.rightBarButton = [[UIBarButtonItem alloc]
      initWithTitle:isScanning ? @"Stop" : @"Start"
              style:UIBarButtonItemStyleBordered
             target:self
             action:isScanning ? @selector(stopScanning) :  @selector(startScanning)];
}

/// Starts scanning for beacons.
- (void)startScanning {
  // Show the name in the message view title and set up the Stop button.
  _messageViewController.title = @"Scanning...";

  // Create a subscription that scans for nearby beacons.
  NSString *(^stringFromData)(NSData *) = ^(NSData *content) {
    return [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding];
  };
  GNSBeaconStrategy *beaconScanStrategy =
      [GNSBeaconStrategy strategyWithParamsBlock:^(GNSBeaconStrategyParams *params) {
        params.allowInBackground = YES;
      }];
  __weak __typeof__(self) weakSelf = self;
  GNSMessageHandler messageFoundHandler = ^(GNSMessage *message) {
    NSString *beaconString = stringFromData(message.content);
    [weakSelf.messageViewController addMessage:beaconString];

    // Send a local notification if not in the foreground.
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
      UILocalNotification *localNotification = [[UILocalNotification alloc] init];
      localNotification.alertBody = beaconString;
      [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    }
  };
  GNSMessageHandler messageLostHandler = ^(GNSMessage *message) {
    [weakSelf.messageViewController removeMessage:stringFromData(message.content)];
  };
  _subscription = [_messageMgr
      subscriptionWithMessageFoundHandler:messageFoundHandler
                       messageLostHandler:messageLostHandler
                              paramsBlock:^(GNSSubscriptionParams *params) {
                                params.deviceTypesToDiscover = kGNSDeviceBLEBeacon;
                                params.beaconStrategy = beaconScanStrategy;
                              }];

  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kBackgroundScanningSaveKey];
  [self updateStartStopButton];
}

/// Stops scanning.
- (void)stopScanning {
  _subscription = nil;
  _messageViewController.title = @"";
  [self updateStartStopButton];
  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kBackgroundScanningSaveKey];
}

/// Toggles the permission state of Nearby.
- (void)toggleNearbyPermission {
  [GNSPermission setGranted:![GNSPermission isGranted]];
}

@end
