//
// TWSocialSettingTableViewController.m
//
// Copyright (c) Weizhong Yang (http://zonble.net)
// All Rights Reserved
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
//     * Redistributions of source code must retain the above copyright
//       notice, this list of conditions and the following disclaimer.
//     * Redistributions in binary form must reproduce the above copyright
//       notice, this list of conditions and the following disclaimer in the
//       documentation and/or other materials provided with the distribution.
//     * Neither the name of Weizhong Yang (zonble) nor the
//       names of its contributors may be used to endorse or promote products
//       derived from this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY WEIZHONG YANG ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL WEIZHONG YANG BE LIABLE FOR ANY
// DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "TWSocialSettingTableViewController.h"
#import "TWCommonHeader.h"

@implementation TWSocialSettingTableViewController

#pragma mark Routines

- (void)removeOutletsAndControls_TWPlurkSettingTableViewController
{
	[loginNameField release];
	loginNameField = nil;
	[passwordField release];
	passwordField = nil;
	[loginButton release];
	loginButton = nil;
	[footerView release];
	footerView = nil;
	[loadingView release];
	loadingView = nil;
}

- (void)dealloc 
{
	[self removeOutletsAndControls_TWPlurkSettingTableViewController];
	[loginName release];
	[password release];
    [super dealloc];
}
- (void)viewDidUnload
{
	[super viewDidUnload];
	[self removeOutletsAndControls_TWPlurkSettingTableViewController];
}

#pragma mark -
#pragma mark UIViewContoller Methods

- (void)loadView
{
	[super loadView];
	UIColor *color = [UIColor colorWithHue:0.58 saturation:0.81 brightness:0.46 alpha:1.00];
	
	if (!loginNameField) {
		loginNameField = [[UITextField alloc] initWithFrame:CGRectMake(120, 15, 180, 30)];
		loginNameField.font = [UIFont systemFontOfSize:14.0];
		loginNameField.keyboardType = UIKeyboardTypeEmailAddress;
		loginNameField.autocorrectionType = UITextAutocorrectionTypeNo;
		loginNameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		loginNameField.returnKeyType = UIReturnKeyNext;
		loginNameField.placeholder = NSLocalizedString(@"Your Login Name", @"");
		loginNameField.textColor = color;
		loginNameField.delegate = self;
	}
	
	if (!passwordField) {
		passwordField = [[UITextField alloc] initWithFrame:CGRectMake(120, 15, 180, 30)];
		passwordField.font = [UIFont systemFontOfSize:14.0];
		passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
		passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		passwordField.returnKeyType = UIReturnKeyDone;
		passwordField.placeholder = NSLocalizedString(@"Your Password", @"");
		passwordField.secureTextEntry = YES;
		passwordField.textColor = color;
		passwordField.delegate = self;
	}
	
	loadingView = [[TWLoadingView alloc] initWithFrame:CGRectMake(100, 100, 120, 120)];	
		
	if (!footerView) {
		footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 60)];
		footerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	}
	
	if (!loginButton)  {	
		loginButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		loginButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		loginButton.frame = CGRectMake(20, 10, 280, 40);
		loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
		UIImage *blueButtonImage = [[UIImage imageNamed:@"BlueButton.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
		[loginButton setBackgroundImage:blueButtonImage forState:UIControlStateNormal];		
	}
	[footerView addSubview:loginButton];
	self.tableView.tableFooterView = footerView;
	self.tableView.scrollEnabled = NO;
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
}
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	
	[self refresh];
	if (![self isLoggedIn]) {
		[loginNameField becomeFirstResponder];
	}
}


#pragma mark Actions

- (BOOL)isLoggedIn
{
	return NO;
}
- (void)updateLoginInfo
{
}

- (void)refresh
{
	[self updateLoginInfo];
	
	NSString *loginText = NSLocalizedString(@"Login", @"");
	[loginButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];

	if ([self isLoggedIn]) {
		loginText =  NSLocalizedString(@"Logout", @"");
		[loginButton addTarget:self action:@selector(logoutAction:) forControlEvents:UIControlEventTouchUpInside];
		loginNameField.enabled = NO;
		passwordField.enabled = NO;
		[loginNameField removeFromSuperview];
		[passwordField removeFromSuperview];
	}
	else {
		[loginButton addTarget:self action:@selector(loginAciton:) forControlEvents:UIControlEventTouchUpInside];
		loginNameField.enabled = YES;
		passwordField.enabled = YES;
		loginNameField.text = @"";
		passwordField.text = @"";
	}
	
	[loginButton setTitle:loginText forState:UIControlStateNormal];
	[loginButton setTitle:loginText forState:UIControlStateHighlighted];
	[loginButton setTitle:loginText forState:UIControlStateDisabled];
	[loginButton setTitle:loginText forState:UIControlStateSelected];
	[footerView addSubview:loginButton];
	self.tableView.tableFooterView = footerView;
	[self.tableView reloadData];
}

- (IBAction)loginAciton:(id)sender
{
}

- (IBAction)logoutAction:(id)sender
{
}

- (void)showLoadingView
{
	[self.view addSubview:loadingView];
	[loadingView startAnimating];
	self.tableView.userInteractionEnabled = NO;
	loginNameField.enabled = NO;
	passwordField.enabled = NO;
}
- (void)hideLoadingView
{
//	[loadingView removeFromSuperview];
	[loadingView stopAnimating];
	self.tableView.userInteractionEnabled = YES;
	loginNameField.enabled = YES;
	passwordField.enabled = YES;
}

#pragma mark -
#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
	cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	cell.detailTextLabel.text = nil;
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = NSLocalizedString(@"Login Name:", @"");
			if ([self isLoggedIn]) {
				cell.detailTextLabel.text = loginName;
			}
			else {
				[cell addSubview:loginNameField];
			}
			break;
		case 1:
			cell.textLabel.text = NSLocalizedString(@"Password:", @"");
			if ([self isLoggedIn]) {
				NSMutableString *s = [NSMutableString string];
				for (NSInteger i = 0; i < [password length]; i++) {
					[s appendString:@"*"];
				}
				cell.detailTextLabel.text = s;
			}
			else {
				[cell addSubview:passwordField];
			}
			break;
			
		default:
			break;
	}

    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == loginNameField) {
		[passwordField becomeFirstResponder];
	}
	else if (textField == passwordField) {
		[self loginAciton:self];
	}	
	return YES;
}


@synthesize loginName;
@synthesize password;

@end