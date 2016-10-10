#import <UIKit/UIKit.h>

/// This class displays a list of messages in a scrolling table view.  You can also customize the
/// button to use as the right button in the nav bar.
@interface MessageViewController : UITableViewController

/// The left button to use in the nav bar.
@property(nonatomic) UIBarButtonItem *leftBarButton;

/// The right button to use in the nav bar.
@property(nonatomic) UIBarButtonItem *rightBarButton;

/// Message management.
- (void)addMessage:(NSString *)message;
- (void)removeMessage:(NSString *)message;

@end

