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
//  AppDelegate.swift
//  NearbyMessagesExampleSwift
//

import UIKit

let kMyAPIKey = "<insert API key here>"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  /**
  * @property
  * This class lets you check the permission state of Nearby for the app on the current device.  If
  * the user has not opted into Nearby, publications and subscriptions will not function.
  */
  var nearbyPermission: GNSPermission!

  /**
  * @property
  * The message manager lets you create publications and subscriptions.  They are valid only as long
  * as the manager exists.
  */
  var messageMgr: GNSMessageManager
  var publication: GNSPublication?
  var subscription: GNSSubscription?
  var navController: UINavigationController!
  var messageViewController: MessageViewController!

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    messageViewController = MessageViewController()
    navController = UINavigationController(rootViewController: messageViewController)
    window?.rootViewController = navController
    window?.makeKeyAndVisible()

    // Set up the message view navigation buttons.
    weak var weakSelf = self
    nearbyPermission = GNSPermission(changedHandler: { granted in
      weakSelf?.messageViewController.leftBarButton = UIBarButtonItem(title: String(format: "%@ Nearby", granted ? "Deny" : "Allow"), style: .Bordered, target: self, action: toggleNearbyPermission)
    })
    setupStartStopButton()
    return true;
  }

  /// Sets up the right bar button to start or stop sharing, depending on current sharing mode.
  func setupStartStopButton {
    let isSharing = (publication != nil)
    messageViewController.rightBarButton = UIBarButtonItem(title: isSharing ? "Stop" : "Start", style: .Bordered, target: self, action: isSharing ? stopSharing :  startSharing)
  }

  /// Starts sharing with a randomized name.
  func startSharing {
    startSharingWithName(String(format:"Anonymous %d", arc4random() % 100))
    setupStartStopButton()
  }

  /// Stops publishing/subscribing.
  - (void)stopSharing {
    publication = nil
    subscription = nil
    messageMgr = nil
    messageViewController.title = ""
  }

  /// Toggles the permission state of Nearby.
  func toggleNearbyPermission() {
    GNSPermission.setGranted(!GNSPermission.isGranted())
  }

  /// Starts publishing the specified name and scanning for nearby devices that are publishing
  /// their names.
  func startSharingWithName(name: String) {
    // Create the message manager, which lets you publish messages and subscribe to messages
    // published by nearby devices.
    messageMgr = GNSMessageManager(APIKey: kMyAPIKey, paramsBlock: { (params: GNSMessageManagerParams!) -> Void in
      // This is called when microphone permission is enabled or disabled by the user.
      params.microphonePermissionErrorHandler = { hasError in
        if (hasError) {
          print("Nearby works better if microphone use is allowed")
        }
      }
      // This is called when Bluetooth permission is enabled or disabled by the user.
      params.bluetoothPermissionErrorHandler = { hasError in
        if (hasError) {
          print("Nearby works better if Bluetooth use is allowed")
        }
      }
      // This is called when Bluetooth is powered on or off by the user.
      params.bluetoothPowerErrorHandler = { hasError in
        if (hasError) {
          print("Nearby works better if Bluetooth is turned on")
        }
      }
    })
    if (messageMgr) {
      weak var weakSelf = self
      // Show the name in the message view title and set up the Stop button.
      messageViewController.title = name

      // Publish the name to nearby devices.
      let pubMessage: GNSMessage = GNSMessage(content: name.dataUsingEncoding(encoding: NSUTF8StringEncoding, allowLossyConversion: true))
      publication = messageMgr.publicationWithMessage(message: pubMessage)

      // Subscribe to messages from nearby devices and display them in the message view.
      subscription = messageMgr.subscriptionWithMessageFoundHandler({ (message: GNSMessage!) -> Void in
        weakSelf?.messageViewController.addMessage(NSString(data: message.content, encoding:NSUTF8StringEncoding))
      }, messageLostHandler: { (message: GNSMessage!) -> Void in
        weakSelf?.messageViewController.removeMessage(NSString(data: message.content, encoding: NSUTF8StringEncoding))
      })
    }
  }
}

