#import "CIVenuesTableViewController.h"
#import "CIVenueViewController.h"
#import "CISettingsViewController.h"
#import "CIVenueCell.h"
#import "CICheckInCell.h"
#import "CIAlertView.h"
#import "UITableView + PullToRefresh.h"

const NSString *kCISearchObject = @"search";
const NSString *kCICheckInObject = @"checkIn";
const NSString *kCISettingsObject = @"settings";

const NSString *kCITypeKey = @"type";
const NSString *kCIVenueKey = @"venue";

@interface CIVenuesTableViewController ()

- (void)_longPressed:(UIGestureRecognizer *)gestureRecognizer;
- (void)tableView:(UITableView *)tableView didLongPressRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation CIVenuesTableViewController

@synthesize cellObjects;

#pragma mark -
#pragma mark NSObject

- (void)dealloc {
	self.cellObjects = nil;
	[_searchField setDelegate:nil];
	[_searchField release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark UIViewController

- (void)loadView {
	[super loadView];
	
	[[self tableView] setupPullToRefresh];
	[[self tableView] setContentInset:UIEdgeInsetsMake(0, 0, -736, 0)];		// hack for settings button, also in PTR
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(login:) name:@"login" object:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if (!self.cellObjects) {
		[self refresh];
	}
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	[_searchField setDelegate:nil];
	[_searchField release];
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	if ([_searchField isFirstResponder]) {
		[_searchField resignFirstResponder];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	[[self tableView] scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[[self tableView] scrollViewDidScroll:scrollView];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (int)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (int)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 1;
		case 1:
			return [self.cellObjects count];
		case 2:
			return 1;
	}
	
	return 0;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		
		[_searchField becomeFirstResponder];
		
	} else if (indexPath.section == 1) {
		
		[_searchField resignFirstResponder];
		
		id object = [self objectForIndexPath:indexPath];
		
		if ([object isKindOfClass:[CIVenue class]] && ![[CIFoursquareEngine sharedEngine] isCurrentlyCheckedInAtVenue:(CIVenue *)object] && ![[CIFoursquareEngine sharedEngine] isCheckingInAtVenue:(CIVenue *)object]) {
			
			// Deselect the cell
			[[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
			
			// Check in!
			[self checkInAtVenue:(CIVenue *)object];
			
		} else {
			[[self tableView] deselectRowAtIndexPath:indexPath animated:YES];
		}
	}
}

#pragma mark -
#pragma mark Special Cell Operations

- (void)_longPressed:(UIGestureRecognizer *)gestureRecognizer {
	
	return;
	
	if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
		[self tableView:[self tableView] didLongPressRowAtIndexPath:[[self tableView] indexPathForCell:(UITableViewCell *)[gestureRecognizer view]]];
	}
}

- (void)tableView:(UITableView *)tableView didLongPressRowAtIndexPath:(NSIndexPath *)indexPath {
	id object = [self objectForIndexPath:indexPath];
	
	if ([object isKindOfClass:[CIVenue class]]) {
		[[self navigationController] pushViewController:[[[CIVenueViewController alloc] initWithVenue:object] autorelease] animated:YES];
	}
}

#pragma mark -
#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	
	// start searching...
	if ([textField text] && ![[[textField text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""]) {
		[self refreshWithSearch:YES];
	}
	
	return NO;
}

#pragma mark -
#pragma mark CITableViewController

- (id)objectForIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.section) {
		case 0:
			return kCISearchObject;
		case 1:
			return [self.cellObjects objectAtIndex:indexPath.row];
		case 2:
			return kCISettingsObject;
	}
	return nil;
}

- (CGFloat)heightForObject:(id)object {
	if ([object isEqual:kCISearchObject]) {
		return 44.0f;
	} else if ([object isEqual:kCISettingsObject]) {
		return 780.0f;
	} else if ([object isKindOfClass:[NSDictionary class]] && [[object valueForKey:(NSString *)kCITypeKey] isEqual:kCICheckInObject]) {
		return [CICheckInCell height];
	} else if ([object isKindOfClass:[CIVenue class]]) {
		return [CIVenueCell heightWithVenue:object];
	}
	
	return [super heightForObject:object];
}

- (UITableViewCell *)cellForObject:(id)object {
	if ([object isEqual:kCISearchObject]) {
		UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:(NSString *)kCISearchObject];
		if (!cell) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:(NSString *)kCISearchObject] autorelease];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			[cell setBackgroundColor:[UIColor blackColor]];
			[[cell contentView] setBackgroundColor:[UIColor blackColor]];
			
			UIImageView *search = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search"]];
			[search setFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
			[search setContentMode:UIViewContentModeCenter];
			[search setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
			[cell addSubview:search];
			[search release];
		}
		
		if (!_searchField) {
			_searchField = [[UITextField alloc] initWithFrame:CGRectMake(44.0f, 3.0f, self.view.bounds.size.width - 44.0f, 38.0f)];
			[_searchField setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth];
			[_searchField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
			[_searchField setDelegate:self];
			[_searchField setPlaceholder:@"Search..."];
			[_searchField setFont:[UIFont systemFontOfSize:16.0f]];
			[_searchField setKeyboardAppearance:UIKeyboardAppearanceAlert];
			[_searchField setAutocorrectionType:UITextAutocorrectionTypeNo];
			[_searchField setClearButtonMode:UITextFieldViewModeWhileEditing];
			[_searchField setReturnKeyType:UIReturnKeySearch];
			
			[_searchField setBackgroundColor:[UIColor blackColor]];
			[_searchField setTextColor:[UIColor whiteColor]];
		}
		
		[cell addSubview:_searchField];
		
		return cell;
	} else if ([object isEqual:kCISettingsObject]) {
		UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:(NSString *)kCISettingsObject];
		if (!cell) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:(NSString *)kCISettingsObject] autorelease];
			[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
			
			UIButton *settingsButton = [[UIButton alloc] init];
			[settingsButton setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
			[settingsButton setFrame:CGRectMake(0.0f, 0.0f, 44.0f, 44.0f)];
			[settingsButton setContentMode:UIViewContentModeCenter];
			[settingsButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
			[settingsButton addTarget:self action:@selector(settings) forControlEvents:UIControlEventTouchUpInside];
			[cell addSubview:settingsButton];
			[settingsButton release];
		}
		
		return cell;
	} else if ([object isKindOfClass:[NSDictionary class]] && [[object valueForKey:(NSString *)kCITypeKey] isEqual:kCICheckInObject]) {
		CICheckInCell *cell = [self.tableView dequeueReusableCellWithIdentifier:(NSString *)kCICheckInObject];
		if (!cell) {
			cell = [[[CICheckInCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:(NSString *)kCICheckInObject] autorelease];
		}
		
		[cell setVenue:[object valueForKey:(NSString *)kCIVenueKey]];
		
		return cell;
	} else if ([object isKindOfClass:[CIVenue class]]) {
		CIVenueCell *cell = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CIVenueCell class])];
		if (!cell) {
			cell = [[[CIVenueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([CIVenueCell class])] autorelease];
			
			[cell addGestureRecognizer:[[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_longPressed:)] autorelease]];
		}
		
		[cell setVenue:object];
		
		return cell;
	}
	
	return nil;
}

#pragma mark -
#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Retry"]) {
		[self checkInAtVenue:[(CIAlertView *)alertView context]];
	}
}

#pragma mark -
#pragma mark CIVenuesTableViewController

- (void)refresh {
	[self refreshWithSearch:NO];
}

- (void)refreshWithSearch:(BOOL)search {
	
	[[CIFoursquareEngine sharedEngine] updateLastCheckedInVenueWithCallback:^(CIVenue *venue) {
		[self updateCellObjects];
	}];
	
	// don't allow if open to a venue's details...
	
	if (!search) {
		[_searchField setText:nil];
	}
	
	[[CIFoursquareEngine sharedEngine] getNearbyVenuesWithSearchString:(search ? _searchField.text : nil) andCallback:^(NSArray *results) {
		self.cellObjects = [[results mutableCopy] autorelease];
		
		for (int i = 0 ; i < [self.cellObjects count] ; i++) {
			if ([[self.cellObjects objectAtIndex:i] isKindOfClass:[CIVenue class]]) {
				CIVenue *venue = (CIVenue *)[self.cellObjects objectAtIndex:i];
				// if is checking in here, add cell below
				
				BOOL isCheckingIn = [[CIFoursquareEngine sharedEngine] isCheckingInAtVenue:venue];
				BOOL isCheckedIn = [[CIFoursquareEngine sharedEngine] isCurrentlyCheckedInAtVenue:venue];
				
				if (isCheckedIn || isCheckingIn) {
					NSDictionary *object = [NSDictionary dictionaryWithObjectsAndKeys:kCICheckInObject, kCITypeKey, venue, kCIVenueKey, nil];				
					if (i == [self.cellObjects count] - 1) {
						[self.cellObjects addObject:object];
					} else {
						[self.cellObjects insertObject:object atIndex:i + 1];
					}
				}
			}
		}
		[[self tableView] reloadData];
		
		[[self tableView] stopLoading];
	}];
}

- (void)checkInAtVenue:(CIVenue *)venue {
	// Start Checking in here
	[[CIFoursquareEngine sharedEngine] checkInAtVenue:venue withCallback:^(BOOL result){
		[self updateCellObjects];
		
		if (!result) {
			if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
				// we try non-stop if we're in the background
				[self checkInAtVenue:venue];
			} else {
				CIAlertView *alertView = [[[CIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Failed to check in at %@", [venue name]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Retry", nil] autorelease];
				[alertView setContext:venue];
				[alertView show];
			}
		}
	}];
	
	// Remove old cells
	[self updateCellObjects];
}

- (void)updateCellObjects {
	
	// Perform UITableView alchemy
	
	[self.tableView beginUpdates];
	
	NSMutableArray *objectsToRemove = [[[NSMutableArray alloc] init] autorelease];
	
	// Scrub through my list to remove other places that might be getting checked in at
	for (int i = 0 ; i < [self.cellObjects count] ; i++) {
		id object = [self.cellObjects objectAtIndex:i];
		if ([object isKindOfClass:[NSDictionary class]] && [[object valueForKey:(NSString *)kCITypeKey] isEqual:kCICheckInObject]) {
			BOOL isCheckingIn = [[CIFoursquareEngine sharedEngine] isCheckingInAtVenue:[object valueForKey:(NSString *)kCIVenueKey]];
			BOOL isCheckedIn = [[CIFoursquareEngine sharedEngine] isCurrentlyCheckedInAtVenue:[object valueForKey:(NSString *)kCIVenueKey]];
			
			if (!isCheckedIn && !isCheckingIn) {
				[objectsToRemove addObject:object];
				[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:1]] withRowAnimation:UITableViewRowAnimationBottom];
			} else {
				[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
			}
		}
	}
	
	// TODO: Do the same for adding cells...
	
	for (int i = 0 ; i < [self.cellObjects count] ; i++) {
		id object = [self.cellObjects objectAtIndex:i];
		if ([object isKindOfClass:[CIVenue class]]) {
			CIVenue *venue = (CIVenue *)object;
			if ([[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]] isKindOfClass:[CIVenueCell class]]) {
				[(CIVenueCell *)[[self tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]] update];
			}
			
			if ([[CIFoursquareEngine sharedEngine] isCurrentlyCheckedInAtVenue:venue] || [[CIFoursquareEngine sharedEngine] isCheckingInAtVenue:venue]) {
				id nextObject = i == [self.cellObjects count] - 1 ? nil : [self.cellObjects objectAtIndex:i + 1];
				if (![nextObject isKindOfClass:[NSDictionary class]] || ![[nextObject valueForKey:(NSString *)kCIVenueKey] isEqual:venue]) {
					// insert there
					NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:kCICheckInObject, kCITypeKey, object, kCIVenueKey, nil];
					if (i == [self.cellObjects count] - 1) {
						[self.cellObjects addObject:dict];
					} else {
						[self.cellObjects insertObject:dict atIndex:i + 1];
					}
					
					[[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:i + 1 inSection:1]] withRowAnimation:UITableViewRowAnimationBottom];
				}
			}
		}
	}
	
	[self.cellObjects removeObjectsInArray:objectsToRemove];
	
	[self.tableView endUpdates];
}

- (void)settings {
	[[self navigationController] pushViewController:[[[CISettingsViewController alloc] init] autorelease] animated:YES];
}

#pragma mark -
#pragma mark Observing

- (void)login:(NSNotification *)notification {
	[self refresh];
	[[self tableView] scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

@end
