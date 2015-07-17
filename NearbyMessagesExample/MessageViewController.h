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
//  MessageViewController.h
//  NearbyMessagesExample
//

@import UIKit;

/**
 * @interface
 * This class displays a list of messages in a scrolling table view.
 * You can also customize the button to use as the right or left button in the nav bar.
 */
@interface MessageViewController : UITableViewController

/**
 * @property
 * The left button to use in the nav bar.
 */
@property(nonatomic) UIBarButtonItem *leftBarButton;

/**
 * @property
 * The right button to use in the nav bar.
 */
@property(nonatomic) UIBarButtonItem *rightBarButton;

/// Message management.
- (void)addMessage:(NSString *)message;
- (void)removeMessage:(NSString *)message;

@end

