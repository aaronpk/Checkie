#import "CIFoursquareEngine.h"
#import "CIVenue.h"
#import "JSONKit.h"

#warning Foursquare OAuth token has been omitted from the open source version of Checkie
#define OAUTH_TOKEN @"[ REDACTED ]"

@interface CIFoursquareEngine ()

- (NSOperationQueue *)_queue;

@end

@implementation CIFoursquareEngine

@synthesize checkingInVenue;
@synthesize checkedInVenue;
@synthesize checkedInPoints;

#pragma mark -
#pragma mark Location Monitoring

- (CLLocationManager *)locationManager {
	static CLLocationManager *manager = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		dispatch_sync(dispatch_get_main_queue(), ^{
			manager = [[CLLocationManager alloc] init];
			[manager startUpdatingLocation];
		});
	});
	
	return manager;
}

#pragma mark -
#pragma mark Actions

- (void)getNearbyVenuesWithSearchString:(NSString *)searchString andCallback:(void (^)(NSArray *results))callback {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	[[self _queue] addOperationWithBlock:^{
		
		// Stall while grabbing location or while there is no user
		while (!([CIFoursquareEngine token] && [[self locationManager] location])) {
			[NSThread sleepForTimeInterval:0.1f];
		}
		
		[NSThread sleepForTimeInterval:1.0f];
		
		NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/search?ll=%f,%f&intent=checkin&%@oauth_token=%@&v=20120129", [self locationManager].location.coordinate.latitude, [self locationManager].location.coordinate.longitude, searchString ? [NSString stringWithFormat:@"query=%@&", searchString] : @"", [CIFoursquareEngine token]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
		NSMutableArray *venues = [[NSMutableArray alloc] init];
		
		if (data) {
			NSArray *response = [[[JSONDecoder decoder] objectWithData:data] valueForKeyPath:@"response.venues"];
			
			for (NSDictionary *dict in response) {
				CIVenue *venue = [CIVenue venueFromDictionary:dict];
				
				if (venue.uniqueID) {
					[venues addObject:venue];
				}
			}
		}
		
		if (callback) {
			dispatch_sync(dispatch_get_main_queue(), ^{
				callback(venues);
			});
		}
		
		[venues autorelease];
		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}];
}

- (void)checkInAtVenue:(CIVenue *)venue withCallback:(void (^)(BOOL result))callback {
	self.checkingInVenue = venue;
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	UIBackgroundTaskIdentifier task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
	
	[[self _queue] addOperationWithBlock:^{
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.foursquare.com/v2/checkins/add?venueId=%@&oauth_token=%@", venue.uniqueID, [CIFoursquareEngine token]]]];
		[request setHTTPMethod:@"POST"];
		
		NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
		
		id object = nil;
		if (data) {
			object = [[JSONDecoder decoder] objectWithData:data];
		}
		
		dispatch_sync(dispatch_get_main_queue(), ^{
			BOOL success = ([[object valueForKey:@"meta"] valueForKey:@"code"] && [[[object valueForKey:@"meta"] valueForKey:@"code"] intValue] == 200);
			
			if (success) {
				self.checkedInVenue = venue;
				
				int points = 0;
				for (NSDictionary *dict in [object valueForKey:@"notifications"]) {
					if ([[dict valueForKey:@"type"] isEqualToString:@"score"]) {
						dict = [dict valueForKey:@"item"];
						for (NSDictionary *score in [dict valueForKey:@"scores"]) {
							points += [[score valueForKey:@"points"] intValue];
						}
					}
				}
				
				self.checkedInPoints = points;
			}
			self.checkingInVenue = nil;
			
			callback(success);
		});
		
		[[UIApplication sharedApplication] endBackgroundTask:task];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}];
}

- (void)updateLastCheckedInVenueWithCallback:(void (^)(CIVenue *result))callback {
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	UIBackgroundTaskIdentifier task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{}];
	
	[[self _queue] addOperationWithBlock:^{
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.foursquare.com/v2/users/self/checkins?limit=1&oauth_token=%@", [CIFoursquareEngine token]]]];
		[request setHTTPMethod:@"GET"];
		
		NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
		
		id object = nil;
		if (data) {
			object = [[JSONDecoder decoder] objectWithData:data];
		}
		
		dispatch_sync(dispatch_get_main_queue(), ^{
			BOOL success = ([[object valueForKey:@"meta"] valueForKey:@"code"] && [[[object valueForKey:@"meta"] valueForKey:@"code"] intValue] == 200);
			
			CIVenue *venue = nil;
			
			if (success) {
				NSDictionary *dict = [[[[[object valueForKey:@"response"] valueForKey:@"checkins"] objectForKey:@"items"] lastObject] objectForKey:@"venue"];
				if (dict) {
					venue = [CIVenue venueFromDictionary:dict];
					if (![self.checkedInVenue isEqual:venue]) {
						self.checkedInPoints = 0;
					}
					self.checkedInVenue = venue;
				}
			}
			
			if (callback) {
				callback(venue);
			}
		});
		
		[[UIApplication sharedApplication] endBackgroundTask:task];
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}];
}

#pragma mark -
#pragma mark Getters

- (void)getVenueWithID:(NSString *)uniqueID andCallback:(void (^)(CIVenue *venue))callback {
	[[self _queue] addOperationWithBlock:^{
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@?oauth_token=%@", uniqueID, [CIFoursquareEngine token]]]];
		[request setHTTPMethod:@"GET"];
		
		NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
		
		id object = nil;
		if (data) {
			object = [[JSONDecoder decoder] objectWithData:data];
		}
		
		dispatch_sync(dispatch_get_main_queue(), ^{
			BOOL success = ([[object valueForKey:@"meta"] valueForKey:@"code"] && [[[object valueForKey:@"meta"] valueForKey:@"code"] intValue] == 200);
			
			CIVenue *venue = nil;
			
			if (success) {
				NSDictionary *dict = [[object valueForKey:@"response"] valueForKey:@"venue"];
				if (dict) {
					venue = [CIVenue venueFromDictionary:dict];
				}
			}
			
			if (callback) {
				callback(venue);
			}
		});
		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}];
}

#pragma mark -
#pragma mark State Checking

- (BOOL)isCurrentlyCheckedInAtVenue:(CIVenue *)venue {
	return [venue isEqual:self.checkedInVenue];
}

- (BOOL)isCheckingInAtVenue:(CIVenue *)venue {
	return [venue isEqual:self.checkingInVenue];
}

#pragma mark -
#pragma mark Class Methods

+ (CIFoursquareEngine *)sharedEngine {
	static CIFoursquareEngine *shared = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		shared = [[CIFoursquareEngine alloc] init];
	});
	
	return shared;
}

+ (NSString *)clientID {
#warning Foursquare client ID omitted from open source version of Checkie
	return @"[ READCTED ]";
}

+ (NSString *)clientSecret {
#warning Foursquare client secret omitted from open source version of Checkie
	return @"[ REDACTED ]";
}

+ (NSString *)callbackURL {
	return @"http://www.google.com";
}

+ (BOOL)isLoggedIn {
	return ([CIFoursquareEngine token] != nil);
}

+ (NSString *)token {
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
}

- (void)logout {
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"token"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	self.checkingInVenue = nil;
	self.checkedInVenue = nil;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:nil];
}

#pragma mark -
#pragma mark Private

- (NSOperationQueue *)_queue {
	static NSOperationQueue *queue = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		queue = [[NSOperationQueue alloc] init];
		[queue setMaxConcurrentOperationCount:5];
	});
	
	return queue;
}

@end
