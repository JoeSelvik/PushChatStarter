//
//  ChatViewController.m
//  PushChatStarter
//
//  Created by Kauserali on 28/03/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "ChatViewController.h"
#import "DataModel.h"
#import "LoginViewController.h"
#import "Message.h"
#import "MessageTableViewCell.h"
#import "SpeechBubbleView.h"

@implementation ChatViewController

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _dataModel = [[DataModel alloc] init];
        [_dataModel loadMessages];
    }
    return self;
}

- (void)scrollToNewestMessage
{
	// The newest message is at the bottom of the table
	NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(self.dataModel.messages.count - 1) inSection:0];
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];	
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![_dataModel joinedChat])
	{
		[self showLoginViewController];
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	self.title = [_dataModel secretCode];

	// Show a label in the table's footer if there are no messages
	if (self.dataModel.messages.count == 0)
	{
		UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
		label.text = NSLocalizedString(@"You have no messages", nil);
		label.font = [UIFont boldSystemFontOfSize:16.0f];
		label.textAlignment = NSTextAlignmentCenter;
		label.textColor = [UIColor colorWithRed:76.0f/255.0f green:86.0f/255.0f blue:108.0f/255.0f alpha:1.0f];
		label.shadowColor = [UIColor whiteColor];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		self.tableView.tableFooterView = label;
	}
	else
	{
		[self scrollToNewestMessage];
	}
}

#pragma mark -
#pragma mark UITableViewDataSource

- (int)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.dataModel.messages.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	static NSString* CellIdentifier = @"MessageCellIdentifier";

	MessageTableViewCell* cell = (MessageTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
		cell = [[MessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];

	Message* message = (self.dataModel.messages)[indexPath.row];
	[cell setMessage:message];
	return cell;
}

#pragma mark -
#pragma mark UITableView Delegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	// This function is called before cellForRowAtIndexPath, once for each cell.
	// We calculate the size of the speech bubble here and then cache it in the
	// Message object, so we don't have to repeat those calculations every time
	// we draw the cell. We add 16px for the label that sits under the bubble.
	Message* message = (self.dataModel.messages)[indexPath.row];
	message.bubbleSize = [SpeechBubbleView sizeForText:message.text];
	return message.bubbleSize.height + 16;
}

#pragma mark -
#pragma mark ComposeDelegate

- (void)didSaveMessage:(Message*)message atIndex:(int)index
{
	// This method is called when the user presses Save in the Compose screen,
	// but also when a push notification is received. We remove the "There are
	// no messages" label from the table view's footer if it is present, and
	// add a new row to the table view with a nice animation.
	if ([self isViewLoaded])
	{
		self.tableView.tableFooterView = nil;
		[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
		[self scrollToNewestMessage];
	}
}

#pragma mark -
#pragma mark Actions

- (void) showLoginViewController {
    LoginViewController* loginController = (LoginViewController*) [ApplicationDelegate.storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
	loginController.dataModel = _dataModel;
	[self presentViewController:loginController animated:YES completion:nil];
}

- (void)userDidLeave
{
	[self.dataModel setJoinedChat:NO];

	// Show the Login screen. This requires the user to join a new
	// chat room before he can return to the chat screen.
	[self showLoginViewController];
}

- (IBAction)exitAction
{
	[self userDidLeave];
}

- (IBAction)composeAction
{
	// Show the Compose screen
	ComposeViewController* composeController = (ComposeViewController*) [ApplicationDelegate.storyBoard instantiateViewControllerWithIdentifier:@"ComposeViewController"];
	composeController.dataModel = _dataModel;
	composeController.delegate = self;
	[self presentViewController:composeController animated:YES completion:nil];
}

@end
