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
//  ViewController.swift
//  AdMobExampleSwift
//

import UIKit

let cellIdentifier = "messageCell"

class MessageViewController: UITableViewController {
  /**
  * @property
  * The left button to use in the nav bar.
  */
  var leftBarButton: UIBarButtonItem! {
    get {
      return navigationItem.leftBarButtonItem
    }
    set(leftBarButton) {
      navigationItem.leftBarButtonItem = leftBarButton
    }
  }

  /**
  * @property
  * The right button to use in the nav bar.
  */
  var rightBarButton: UIBarButtonItem! {
    get {
      return navigationItem.rightBarButtonItem
    }
    set(rightBarButton) {
      navigationItem.rightBarButtonItem = rightBarButton
    }
  }

  var messages = [String]()

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerClass(UITableViewCell.classForCoder(), forCellReuseIdentifier: cellIdentifier)
  }

  func addMessage(message: String!) {
    messages.append(message.copy() as! String)
    tableView.reloadData()
  }

  func removeMessage(message: String!) {
    if let index = messages.indexOf(message)
    {
      messages.removeAtIndex(index)
    }
    tableView.reloadData()
  }

// MARK: - UITableViewDataSource

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return messages.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
    cell.textLabel?.text = messages[indexPath.row]
    return cell
  }


// MARK: - UItableViewDelegate

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

}
