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

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                          forIndexPath:indexPath];
  if (indexPath.row < (NSInteger)[_messages count]) {
    cell.textLabel.text = _messages[indexPath.row];
  }
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
