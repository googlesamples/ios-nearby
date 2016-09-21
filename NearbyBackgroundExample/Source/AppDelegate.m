#import "AppDelegate.h"

#import <GNSMessages.h>

#import "MessageViewController.h"

static NSString * const kMyAPIKey = @"<insert API key here>";
static NSString * const kBackgroundModeSaveKey = @"NearbyBackgroundEnabled";


@interface AppDelegate ()
@property(nonatomic) GNSPermission *nearbyPermission;
@property(nonatomic) GNSMessageManager *messageMgr;
@property(nonatomic) id<GNSPublication> publication;
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
  void (^showMessage)(NSString *message) = ^(NSString *message) {
    NSLog(@"%@", message);
  };
  void (^paramsBlock)(GNSMessageManagerParams *) = ^(GNSMessageManagerParams *params) {
    // This is called when microphone permission is enabled or disabled by the user.
    params.microphonePermissionErrorHandler = ^(BOOL hasError) {
      if (hasError) {
       showMessage(@"Nearby works better if microphone use is allowed");
      }
    };
    // This is called when Bluetooth permission is enabled or disabled by the user.
    params.bluetoothPermissionErrorHandler = ^(BOOL hasError) {
      if (hasError) {
       showMessage(@"Nearby works better if Bluetooth use is allowed");
      }
    };
    // This is called when Bluetooth is powered on or off by the user.
    params.bluetoothPowerErrorHandler = ^(BOOL hasError) {
      if (hasError) {
       showMessage(@"Nearby works better if Bluetooth is turned on");
      }
    };
  };
  _messageMgr = [[GNSMessageManager alloc] initWithAPIKey:kMyAPIKey paramsBlock:paramsBlock];

  // Seed the random number generator for the anonymous name.
  srand((uint)[[NSDate date] timeIntervalSince1970]);

  // If background mode was enabled, start pub/sub on startup.
  if ([[NSUserDefaults standardUserDefaults] boolForKey:kBackgroundModeSaveKey]) {
    [self startSharingAndScanning];
  }

  return YES;
}

/// Sets up the right bar button to start or stop sharing, depending on current sharing mode.
- (void)updateStartStopButton {
  BOOL isSharing = (_publication != nil);
  _messageViewController.rightBarButton = [[UIBarButtonItem alloc]
      initWithTitle:isSharing ? @"Stop" : @"Start"
              style:UIBarButtonItemStyleBordered
             target:self
             action:isSharing ? @selector(stopSharingAndScanning) :
                                @selector(startSharingAndScanning)];
}

/// Starts sharing with a randomized name and scanning for others.
- (void)startSharingAndScanning {
  NSString *name = [NSString stringWithFormat:@"Anonymous %d", rand() % 100];

  // Show the name in the message view title and set up the Stop button.
  _messageViewController.title = name;

  // Create a strategy that enabled background mode.
  GNSStrategy *strategy = [GNSStrategy strategyWithParamsBlock:^(GNSStrategyParams *params) {
    params.allowInBackground = YES;
  }];

  // Publish the name to nearby devices.
  GNSMessage *pubMessage =
      [GNSMessage messageWithContent:[name dataUsingEncoding:NSUTF8StringEncoding]];
  _publication = [_messageMgr publicationWithMessage:pubMessage
                                         paramsBlock:^(GNSPublicationParams *params) {
                                           params.strategy = strategy;
                                         }];

  // Subscribe to messages from nearby devices and display them in the message view.
  NSString *(^stringFromData)(NSData *) = ^(NSData *content) {
    return [[NSString alloc] initWithData:content encoding:NSUTF8StringEncoding];
  };
  __weak __typeof__(self) weakSelf = self;
  _subscription = [_messageMgr
      subscriptionWithMessageFoundHandler:^(GNSMessage *message) {
        NSString *messageString = stringFromData(message.content);
        [weakSelf.messageViewController addMessage:messageString];

        // Send a local notification if not in the foreground.
        if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
          UILocalNotification *localNotification = [[UILocalNotification alloc] init];
          localNotification.alertBody = messageString;
          [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
        }
      }
                       messageLostHandler:^(GNSMessage *message) {
                         [weakSelf.messageViewController
                             removeMessage:stringFromData(message.content)];
                       }
                              paramsBlock:^(GNSSubscriptionParams *params) {
                                params.strategy = strategy;
                              }];

  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kBackgroundModeSaveKey];
  [self updateStartStopButton];
}

/// Stops sharing and scanning.
- (void)stopSharingAndScanning {
  _publication = nil;
  _subscription = nil;
  _messageViewController.title = @"";
  [self updateStartStopButton];
  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kBackgroundModeSaveKey];
}

/// Toggles the permission state of Nearby.
- (void)toggleNearbyPermission {
  [GNSPermission setGranted:![GNSPermission isGranted]];
}

@end
