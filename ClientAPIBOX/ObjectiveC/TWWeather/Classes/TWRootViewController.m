//
// TWRootViewController.m
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

#import "TWRootViewController.h"
#import "TWLoadingCell.h"
#import "TWAPIBox.h"
#import "TWErrorViewController.h"
#import "TWOBSTableViewController.h"
#import "TWOverviewViewController.h"
#import "TWForecastTableViewController.h"
#import "TWForecastResultTableViewController.h"
#import "TWWeekTableViewController.h"
#import "TWWeekTravelTableViewController.h"
#import "TWThreeDaySeaTableViewController.h"
#import "TWNearSeaTableViewController.h"
#import "TWTideTableViewController.h"
#import "TWGlobalTableViewController.h"
#import "TWImageTableViewController.h"
#import "TWWeatherAppDelegate.h"

@implementation TWRootViewController

- (void)dealloc
{
	[super dealloc];
}
- (void)viewDidUnload
{
	[super viewDidLoad];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.title = NSLocalizedString(@"Forecasts", @"");
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
	// Work around for iOS 7
	if ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0) {
		self.tableView.contentInset = UIEdgeInsetsMake(64.0, 0.0, 44.0, 0.0);
	}
#endif
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 10;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#define U8(x) [NSString stringWithUTF8String:x]

	static NSString *CellIdentifier = @"Cell";
	TWLoadingCell *cell = (TWLoadingCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[TWLoadingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0];
	cell.imageView.image = nil;
	if (indexPath.row != 0) {
		[cell stopAnimating];
	}
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"目前天氣";
			break;
		case 1:
			cell.textLabel.text = @"關心天氣";
			if (isLoadingOverview) {
				[cell startAnimating];
			}
			else {
				[cell stopAnimating];
			}
			break;
		case 2:
			cell.textLabel.text = @"今明預報";
			break;
		case 3:
			cell.textLabel.text = @"一週天氣";
			break;
		case 4:
			cell.textLabel.text = @"一週旅遊";
			break;
		case 5:
			cell.textLabel.text = @"三天漁業";
			break;
		case 6:
			cell.textLabel.text = @"台灣近海";
			break;
		case 7:
			cell.textLabel.text = @"三天潮汐";
			break;
		case 8:
			cell.textLabel.text = @"全球都市";
			break;
		case 9:
			cell.textLabel.text = @"天氣觀測雲圖";
			break;
		default:
			break;
	}
	return cell;

#undef U8

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewController *controller = nil;
	if (indexPath.row == 0) {
		controller = [[TWOBSTableViewController alloc] initWithStyle:UITableViewStylePlain];
	}
	else if (indexPath.row == 1) {
		isLoadingOverview = YES;
		[self.tableView reloadData];
		self.tableView.userInteractionEnabled = NO;
		[[TWAPIBox sharedBox] fetchOverviewWithFormat:TWOverviewPlainFormat delegate:self userInfo:nil];
	}
	else if (indexPath.row == 2) {
		controller = [[TWForecastTableViewController alloc] initWithStyle:UITableViewStylePlain];
	}
	else if (indexPath.row == 3) {
		controller = [[TWWeekTableViewController alloc] initWithStyle:UITableViewStylePlain];
	}
	else if (indexPath.row == 4) {
		controller = [[TWWeekTravelTableViewController alloc] initWithStyle:UITableViewStylePlain];
	}
	else if (indexPath.row == 5) {
		controller = [[TWThreeDaySeaTableViewController alloc] initWithStyle:UITableViewStylePlain];
	}
	else if (indexPath.row == 6) {
		controller = [[TWNearSeaTableViewController alloc] initWithStyle:UITableViewStylePlain];
	}
	else if (indexPath.row == 7) {
		controller = [[TWTideTableViewController alloc] initWithStyle:UITableViewStylePlain];
	}
	else if (indexPath.row == 8) {
		controller = [[TWGlobalTableViewController alloc] initWithStyle:UITableViewStylePlain];
	}
	else if (indexPath.row == 9) {
		controller = [[TWImageTableViewController alloc] initWithStyle:UITableViewStylePlain];
	}
	if (controller) {
		[[TWWeatherAppDelegate sharedDelegate] pushViewController:controller animated:YES];
		[controller release];
	}
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 45.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 0.0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return nil;
}

#pragma mark -

- (void)APIBox:(TWAPIBox *)APIBox didFetchOverview:(NSString *)string userInfo:(id)userInfo
{
	isLoadingOverview = NO;
	[self.tableView reloadData];
	self.tableView.userInteractionEnabled = YES;
	TWOverviewViewController *controller = [[TWOverviewViewController alloc] init];
	[[TWWeatherAppDelegate sharedDelegate] pushViewController:controller animated:YES];
	[controller setText:string];
	[controller release];
}
- (void)APIBox:(TWAPIBox *)APIBox didFailedFetchOverviewWithError:(NSError *)error
{
	isLoadingOverview = NO;
	[self.tableView reloadData];
	self.tableView.userInteractionEnabled = YES;
	TWErrorViewController *controller = [[TWErrorViewController alloc] init];
	controller.error = error;
	[[TWWeatherAppDelegate sharedDelegate] pushViewController:controller animated:YES];
	[controller release];
}

@end
