//
// Copyright (c) 2015 Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  AppDelegate.m
//  NearbyMessagesExample
//

#import "AppDelegate.h"
#import <GNSMessages.h>
#import "MessageViewController.h"

static NSString * const kMyAPIKey = @"<insert API key here>";


@interface AppDelegate ()

/**
 * @property
 * This class lets you check the permission state of Nearby for the app on the current device.  If
 * the user has not opted into Nearby, publications and subscriptions will not function.
 */
@property(nonatomic) GNSPermission *nearbyPermission;

/**
 * @property
 * The message manager lets you create publications and subscriptions.  They are valid only as long
 * as the manager exists.
 */
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

  [self askToStartSharing];
  return YES;
}

/// Asks the user to share presence and scan for the presence of others.
- (void)askToStartSharing {
  // TODO to replace it with UIAlertViewController.
  UIAlertView *alert =
      [[UIAlertView alloc] initWithTitle:@"Hello!"
                                 message:@"Share your presence?"
                                delegate:self
                       cancelButtonTitle:@"Yes"
                       otherButtonTitles:nil];
  [alert show];
}

/// Stops publishing/subscribing, and ask to share presence.
- (void)stopAndAskToRestart {
  _publication = nil;
  _subscription = nil;
  _messageMgr = nil;

  _messageViewController.title = @"";
  _messageViewController.leftBarButton = nil;
  _messageViewController.rightBarButton = nil;

  [self askToStartSharing];
}

/// UIAlertView delegate method.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  [self startSharingWithName:[NSString stringWithFormat:@"Anonymous %d", arc4random() % 100]];
}

/// Toggles the permission state of Nearby.
- (void)toggleNearbyPermission {
  [GNSPermission setGranted:![GNSPermission isGranted]];
}

/// Starts publishing my name and subscribing for nearby devices that are publishing their names.
- (void)startSharingWithName:(NSString *)name {
  // Create the message manager, which lets you publish messages and subscribe to messages
  // published by nearby devices.
  void (^showMessage)(NSString *message) = ^(NSString *message) {
    NSLog(@"%@", message);
  };

  _messageMgr = [[GNSMessageManager alloc]
      initWithAPIKey:kMyAPIKey
         paramsBlock: ^(GNSMessageManagerParams *params) {
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
         }];
  if (_messageMgr) {
    __weak __typeof__(self) weakSelf = self;

    // Show the name in the message view title and set up the Stop button.
    _messageViewController.title = name;
    _messageViewController.rightBarButton = [[UIBarButtonItem alloc]
        initWithTitle:@"Stop"
                style:UIBarButtonItemStyleBordered
               target:self
               action:@selector(stopAndAskToRestart)];

    // Keep the Nearby permission button title in sync with the Nearby permission state.
    _nearbyPermission = [[GNSPermission alloc] initWithChangedHandler:^(BOOL granted) {
      weakSelf.messageViewController.leftBarButton = [[UIBarButtonItem alloc]
          initWithTitle:[NSString stringWithFormat:@"%@ Nearby", granted ? @"Deny" : @"Allow"]
                  style:UIBarButtonItemStyleBordered
                 target:self
                 action:@selector(toggleNearbyPermission)];
    }];

    // Publish the name to nearby devices.
    GNSMessage *pubMessage =
        [GNSMessage messageWithContent:[name dataUsingEncoding:NSUTF8StringEncoding]];
    _publication = [_messageMgr publicationWithMessage:pubMessage];

    _subscription = [_messageMgr
        subscriptionWithMessageFoundHandler:^(GNSMessage *message) {
          [weakSelf.messageViewController addMessage:[[NSString alloc] initWithData:message.content encoding:NSUTF8StringEncoding]];
        }
                         messageLostHandler:^(GNSMessage *message) {
                           [weakSelf.messageViewController
                               removeMessage:[[NSString alloc] initWithData:message.content encoding:NSUTF8StringEncoding]];
                         }];
  }
}

@end
