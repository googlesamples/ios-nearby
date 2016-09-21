# NearbyBeacons Sample App for iOS

This is a sample app for third party developers using the Nearby Messages
library. It scans for beacons in the foreground and background.


# Getting Started

1. If you don't already have the CocoaPods tool, install it on OS X by running
the following command from the terminal. For details, see the [CocoaPods Getting
Started guide](https://guides.cocoapods.org/using/getting-started.html).

    `sudo gem install cocoapods`

2. To install the CocoaPods needed by the app, go to the NearbyBeacons directory
in a terminal and run the following command:

    `pod install`

3. Open ```NearbyBeacons.xcworkspace```.

4. Alter the source code to match your
[Google developer console](https://console.developers.google.com/) project
settings.

    * In ```AppDelegate.m```, replace *<insert API key here>* with your public
      iOS API key.

    * Click on NearbyBeacons in the project navigator, click the General tab,
      and type your bundle ID into the Bundle Identifier field.

5. Build and run.

6. If you need to set up some beacons, see the
[Google Beacons](https://developers.google.com/beacons/) site.


# Enabling Background Beacon Scanning

To scan for BLE beacons in the background, the app's Info.plist must contain the
following items:

* `UIBackgroundModes` entries:

    * `bluetooth-central` for BLE scanning.
    * `location` for iBeacons and high-power mode.  You can omit this if
      you're doing low-power scanning for Eddystone beacons only.

* `NSLocationAlwaysUsageDescription` string describing why you will be tracking
  the user's location in the background.  E.g., "Location is needed to scan for
  beacons."

This code snippet demonstrates how to create a Nearby Messages subscription that
scans for beacon in the background:

```
_beaconSubscription = [_messageManager
    subscriptionWithMessageFoundHandler:myMessageFoundHandler
                     messageLostHandler:myMessageLostHandler
                            paramsBlock:^(GNSSubscriptionParams *params) {
                              params.deviceTypesToDiscover = kGNSDeviceBLEBeacon;
                              params.beaconStrategy = [GNSBeaconStrategy
                                  strategyWithParamsBlock:^(GNSBeaconStrategyParams *params) {
                                    params.allowInBackground = YES;
                                  }];
                            }];
```

If you want to notify the user when beacons are discovered while the app is in
the background, you can use
[iOS local notifications](https://developer.apple.com/library/ios/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/Chapters/WhatAreRemoteNotif.html).

* Register for local notifications on startup:

  ```
  if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
    [[UIApplication sharedApplication] registerUserNotificationSettings:
        [UIUserNotificationSettings settingsForTypes:
            UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound
                                          categories:nil]];
  }
  ```

* Send a local notification in the message-found handler of your
  subscription:

  ```
  GNSMessageHandler myMessageFoundHandler = ^(GNSMessage *message) {
      // Send a local notification if not in the foreground.
      if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.alertBody = @"Beacon found!";
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
      }
      ...
    }
  ```
