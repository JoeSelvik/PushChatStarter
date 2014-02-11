//
//  LoginViewController.m
//  PushChatStarter
//
//  Created by Kauserali on 28/03/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "LoginViewController.h"
#import "DataModel.h"

@interface LoginViewController()
@property (nonatomic, retain) IBOutlet UITextField* nicknameTextField;
@property (nonatomic, retain) IBOutlet UITextField* secretCodeTextField;
@end

@implementation LoginViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.nicknameTextField.text = [self.dataModel nickname];
	self.secretCodeTextField.text = [self.dataModel secretCode];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (self.nicknameTextField.text.length == 0)
		[self.nicknameTextField becomeFirstResponder];
	else
		[self.secretCodeTextField becomeFirstResponder];
}


#pragma mark -
#pragma mark Actions

- (void)userDidJoin
{
	// Close the Login screen
	[self.dataModel setJoinedChat:YES];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loginAction
{
	if (self.nicknameTextField.text.length == 0)
	{
		ShowErrorAlert(NSLocalizedString(@"Fill in your nickname", nil));
		return;
	}

	if (self.secretCodeTextField.text.length == 0)
	{
		ShowErrorAlert(NSLocalizedString(@"Fill in a secret code", nil));
		return;
	}

	[self.dataModel setNickname:self.nicknameTextField.text];
	[self.dataModel setSecretCode:self.secretCodeTextField.text];

	// Hide the keyboard
	[self.nicknameTextField resignFirstResponder];
	[self.secretCodeTextField resignFirstResponder];

	[self userDidJoin];
}

@end
