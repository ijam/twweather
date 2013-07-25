//
// TWSocialComposer.m
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

#import "TWSocialComposer.h"
#import "TWSocialBackgroudView.h"
#import "TWWeatherAppDelegate.h"
#import "TWPlurkSettingTableViewController.h"
#import "TWTwitterSettingTableViewController.h"
#import "UIViewController+Compatibility.h"

static TWSocialComposer *sharedComposer;

@implementation TWSocialComposer

+ (TWSocialComposer *)sharedComposer
{
	if (!sharedComposer) {
		TWSocialComposerViewController *viewController = [[TWSocialComposerViewController alloc] init];
		sharedComposer = [[TWSocialComposer alloc] initWithRootViewController:viewController];
		sharedComposer.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		sharedComposer.navigationBar.barStyle = UIBarStyleBlack;
		[viewController release];
	}
	return sharedComposer;
}

- (void)showLoginAlert
{
	NSString *msg = nil;
	if (self.mode == TWSocialComposerPlurkMode) {
		msg = NSLocalizedString(@"You did not login Plurk.", @"");
	}
	else if (self.mode == TWSocialComposerTwitterMode) {
		msg = NSLocalizedString(@"You did not login Twitter.", @"");
	}

	if (msg) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:msg message:NSLocalizedString(@"Do you want to login now?", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:NSLocalizedString(@"Login", @""), nil];
		[alertView show];
		[alertView release];
	}
}

- (void)showWithText:(NSString *)text
{
	if (self.mode == TWSocialComposerPlurkMode && ![[ObjectivePlurk sharedInstance] isLoggedIn]) {
		[self showLoginAlert];
		return;
	}
	else if (self.mode == TWSocialComposerTwitterMode && ![[TWTwitterEngine sharedEngine] isLoggedIn]) {
		[self showLoginAlert];
		return;
	}
		
	TWSocialComposerViewController *composer = (TWSocialComposerViewController *)[self viewControllers][0];
	[composer view];
	UINavigationController *rootNavController = [TWWeatherAppDelegate sharedDelegate].navigationController;
	[rootNavController presentModalViewController:self animated:YES];

	composer.textView.editable = YES;
	composer.textView.text = text;
	[composer updateWordCount];
	
	if (self.mode == TWSocialComposerPlurkMode) {
		composer.title = NSLocalizedString(@"Post to Plurk", @"");
	}
	else if (self.mode == TWSocialComposerTwitterMode) {
		composer.title = NSLocalizedString(@"Post to Twitter", @"");
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	if (buttonIndex) {
		UIViewController *controller = nil;
		if (self.mode == TWSocialComposerPlurkMode && ![[ObjectivePlurk sharedInstance] isLoggedIn]) {
			controller = [[TWPlurkSettingTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
		}
		else if (self.mode == TWSocialComposerTwitterMode && ![[TWTwitterEngine sharedEngine] isLoggedIn]) {
			controller = [[TWTwitterSettingTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
		}
		
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
		UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelLoginPlurk:)];
		controller.navigationItem.leftBarButtonItem = item;
		[item release];
		[controller release];
		UINavigationController *rootNavController = [TWWeatherAppDelegate sharedDelegate].navigationController;
		[rootNavController presentModalViewController:navController animated:YES];
		[navController release];
	}
}

- (IBAction)cancelLoginPlurk:(id)sender
{
	UINavigationController *rootNavController = [TWWeatherAppDelegate sharedDelegate].navigationController;	
	[rootNavController dismissModalViewControllerAnimated:YES];
}

@synthesize mode;

@end

#pragma mark -

@implementation TWSocialComposerViewController

#pragma mark Routines

- (void)removeOutletsAndControls_TWPlurkComposer
{
	[textView release];
	textView = nil;
	[loadingView release];
	loadingView = nil;
	[loadingLabel release];
	loadingLabel = nil;
}

- (void)dealloc 
{
	[self removeOutletsAndControls_TWPlurkComposer];
	[currentConnectionID release];
    [super dealloc];
}
- (void)viewDidUnload
{
	[super viewDidUnload];
	[self removeOutletsAndControls_TWPlurkComposer];
}

#pragma mark -
#pragma mark UIViewContoller Methods

- (void)loadView 
{
	TWSocialBackgroudView *aView = [[[TWSocialBackgroudView alloc] initWithFrame:[UIScreen mainScreen].bounds] autorelease];
	aView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	aView.backgroundColor = [UIColor whiteColor];
	self.view = aView;
	
	textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width - 20, 170)];
	textView.backgroundColor = [UIColor clearColor];
	textView.editable = YES;
	textView.contentOffset = CGPointMake(10, 10);
	textView.font = [UIFont systemFontOfSize:14.0];
	textView.keyboardAppearance = UIKeyboardAppearanceAlert;
	textView.delegate = self;
	[self.view addSubview:textView];
	
	wordCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 190, [UIScreen mainScreen].bounds.size.width - 20, 10)];
	wordCountLabel.textColor = [UIColor whiteColor];
	wordCountLabel.font = [UIFont systemFontOfSize:10.0];
	wordCountLabel.textAlignment = UITextAlignmentCenter;
	wordCountLabel.backgroundColor = [UIColor blackColor];
	[self.view addSubview:wordCountLabel];
	
	loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	loadingView.frame = CGRectMake(40, 230, 19, 19);
	loadingView.hidden = YES;
	[self.view addSubview:loadingView];
		
	loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 230, 220, 20)];					
	loadingLabel.backgroundColor = [UIColor blackColor];
	loadingLabel.textColor = [UIColor whiteColor];
	loadingLabel.font = [UIFont systemFontOfSize:16.0];
	loadingLabel.text = NSLocalizedString(@"Posting your message...", @"");
	loadingLabel.hidden = YES;
	[self.view addSubview:loadingLabel];

}

- (void)viewDidLoad 
{
    [super viewDidLoad];
//	self.title = NSLocalizedString(@"Post to Plurk", @"");
	
	UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
	self.navigationItem.leftBarButtonItem = cancelItem;
	[cancelItem release];

	UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction:)];
	self.navigationItem.rightBarButtonItem = doneItem;
	[doneItem release];
	
}
- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
	[textView becomeFirstResponder];

	[loadingView stopAnimating];
	loadingView.hidden = YES;
	loadingLabel.hidden = YES;	

	originalBarStyle = [UIApplication sharedApplication].statusBarStyle;
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
}
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	[textView becomeFirstResponder];
}
- (void)viewWillDisappear:(BOOL)animated 
{
	[textView resignFirstResponder];
	[UIApplication sharedApplication].statusBarStyle = originalBarStyle;
	[super viewWillDisappear:animated];
}

#pragma mark Actions

- (void)updateWordCount
{
	NSUInteger count = [textView.text length];
	NSString *s = [NSString stringWithFormat:@"%d/140", count];
	wordCountLabel.text = s;
}

- (IBAction)cancelAction:(id)sender
{
	if ([self.navigationController compitibaleParentViewController]) {
		[[self.navigationController compitibaleParentViewController] dismissModalViewControllerAnimated:YES];
	}
}
- (IBAction)doneAction:(id)sender
{
	TWSocialComposer *composer = (TWSocialComposer *)self.navigationController;
	if (!composer) {
		return;
	}

	NSString *content = textView.text;
	textView.editable = NO;

	[loadingView startAnimating];
	loadingView.hidden = NO;
	loadingLabel.hidden = NO;
	
	if (composer.mode == TWSocialComposerPlurkMode) {
		[[ObjectivePlurk sharedInstance] addNewMessageWithContent:content qualifier:@"shares" othersCanComment:YES lang:@"tr_ch" limitToUsers:nil delegate:self userInfo:nil];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
	else if (composer.mode == TWSocialComposerTwitterMode) {
		[TWTwitterEngine sharedEngine].delegate = self;
		MGTwitterEngine *engine = [TWTwitterEngine sharedEngine].engine;
		self.currentConnectionID = [engine sendUpdate:content];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}	
}

#pragma mark -
#pragma mark UITextView delegate methods

- (void)textViewDidChange:(UITextView *)textView
{
	[self updateWordCount];
}

#pragma mark -
#pragma mark ObjectivePlurk delegate methods

- (void)endPosting
{
	[loadingView stopAnimating];
	loadingView.hidden = YES;
	loadingLabel.hidden = YES;
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

}
- (void)plurk:(ObjectivePlurk *)plurk didAddMessage:(NSDictionary *)result
{
	[self endPosting];
	[self cancelAction:self];	
}
- (void)plurk:(ObjectivePlurk *)plurk didFailAddingMessage:(NSError *)error
{
	[self endPosting];
	textView.editable = YES;
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed to post on Plurk", @"") message:[error localizedDescription] delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
	[alertView show];
	[alertView release];
}


#pragma mark MGTwiiterEngine delegate methods

- (void)requestSucceeded:(NSString *)requestIdentifier
{
	if (![requestIdentifier isEqualToString:currentConnectionID]) {
		return;
	}
	self.currentConnectionID = nil;
	[self endPosting];
	[self cancelAction:self];
}
- (void)requestFailed:(NSString *)requestIdentifier withError:(NSError *)error
{
	if (![requestIdentifier isEqualToString:currentConnectionID]) {
		return;
	}	
	self.currentConnectionID = nil;
	[self endPosting];
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed to post on Twitter", @"") message:[error localizedDescription] delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
	[alertView show];
	[alertView release];	
}

@synthesize textView;
@synthesize currentConnectionID;

@end
