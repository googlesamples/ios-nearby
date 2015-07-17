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
//  MessageViewController.m
//  NearbyMessagesExample
//

#import "MessageViewController.h"

static NSString *cellIdentifier = @"messageCell";

@interface MessageViewController ()
@property(nonatomic) NSMutableArray *messages;
@end

@implementation MessageViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];

  _messages = [NSMutableArray array];
}

- (void)setLeftBarButton:(UIBarButtonItem *)leftBarButton {
  self.navigationItem.leftBarButtonItem = leftBarButton;
}

- (UIBarButtonItem *)leftBarButton {
  return self.navigationItem.leftBarButtonItem;
}

- (void)setRightBarButton:(UIBarButtonItem *)rightBarButton {
  self.navigationItem.rightBarButtonItem = rightBarButton;
}

- (UIBarButtonItem *)rightBarButton {
  return self.navigationItem.rightBarButtonItem;
}

- (void)addMessage:(NSString *)message {
  [_messages addObject:[message copy]];
  [self.tableView reloadData];
}

- (void)removeMessage:(NSString *)message {
  [_messages removeObject:message];
  [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [_messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                          forIndexPath:indexPath];
  cell.textLabel.text = _messages[indexPath.row];
  return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
