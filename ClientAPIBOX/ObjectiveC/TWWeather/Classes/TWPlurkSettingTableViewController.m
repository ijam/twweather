//
// TWPlurkSettingTableViewController.m
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

#import "TWPlurkSettingTableViewController.h"
#import "TWCommonHeader.h"
#import "SFHFKeychainUtils.h"

@implementation TWPlurkSettingTableViewController

- (void)viewDidLoad 
{
    [super viewDidLoad];
	self.title = NSLocalizedString(@"Plurk Setting", @"");
}	

- (BOOL)isLoggedIn
{
	return [[ObjectivePlurk sharedInstance] isLoggedIn];
}
- (void)updateLoginInfo
{
	NSString *theLoginName = [[NSUserDefaults standardUserDefaults] stringForKey:TWPlurkLoginNamePreference];
	if (theLoginName) {
		self.loginName = theLoginName;	
		NSError *error = nil;
		NSString *thePassword = [SFHFKeychainUtils getPasswordForUsername:theLoginName andServiceName:TWPlurkService error:&error];
		if (thePassword) {
			self.password  = thePassword;			
		}
	}
}

- (IBAction)loginAciton:(id)sender
{
	self.loginName = [loginNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	self.password = [passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	loginNameField.text = loginName;
	passwordField.text = password;
	
	if (![loginName length]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please input your Plurk login name.", @"") message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
		[alert show];
		[alert release];
		[loginNameField becomeFirstResponder];
		return;
	}
	
	if (![password length]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Please input your Plurk password.", @"") message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
		[alert show];
		[alert release];
		[passwordField becomeFirstResponder];
		return;
	}
	
	[self showLoadingView];
	[[ObjectivePlurk sharedInstance] loginWithUsername:loginName password:password delegate:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:loginName, @"loginName", password, @"password", nil]];
}

- (IBAction)logoutAction:(id)sender
{
	NSString *theLoginName = [[NSUserDefaults standardUserDefaults] stringForKey:TWPlurkLoginNamePreference];
	NSError *error = nil;
	[SFHFKeychainUtils deleteItemForUsername:theLoginName andServiceName:TWPlurkService error:&error];
	[[ObjectivePlurk sharedInstance] logout];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:TWPlurkLoginNamePreference];

	[self refresh];

	[loginNameField becomeFirstResponder];
}

#pragma mark -
#pragma mark Plurk Login delegate methods.

- (void)plurk:(ObjectivePlurk *)plurk didLoggedIn:(NSDictionary *)result
{
	[self hideLoadingView];
	
	if (loginName && password) { 
		NSError *error = nil;
		[[NSUserDefaults standardUserDefaults] setObject:loginName forKey:TWPlurkLoginNamePreference];
		[SFHFKeychainUtils storeUsername:loginName andPassword:password forServiceName:TWPlurkService updateExisting:YES error:&error];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	[self refresh];
	
	if (self.navigationItem.leftBarButtonItem) {
		UIBarButtonItem *item = self.navigationItem.leftBarButtonItem;
		SEL action = [item action];
		id target = [item target];
		[target performSelector:action withObject:self];
	}
	
}
- (void)plurk:(ObjectivePlurk *)plurk didFailLoggingIn:(NSError *)error
{
	[self hideLoadingView];
	[loginNameField becomeFirstResponder];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed to login Plurk.", @"") message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}

@end
