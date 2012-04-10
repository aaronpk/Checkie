#import "CIVenue.h"
#import "CIFoursquareEngine.h"

@implementation CIVenue

@synthesize name;
@synthesize uniqueID;
@synthesize location;

@synthesize twitter;
@synthesize phone;
@synthesize category;
@synthesize city;
@synthesize url;
@synthesize menu;
@synthesize description;
@synthesize photos;

#pragma mark -
#pragma mark NSObject

+ (CIVenue *)venueFromDictionary:(NSDictionary *)dictionary {
	CIVenue *venue = [[CIVenue alloc] init];
	
	[venue updateFromDictionary:dictionary];
	
	return [venue autorelease];
}

- (void)updateFromDictionary:(NSDictionary *)dictionary {
	[self setUniqueID:[dictionary valueForKey:@"id"]];
	[self setName:[dictionary valueForKey:@"name"]];
	double latitude = [[[dictionary valueForKey:@"location"] valueForKey:@"lat"] doubleValue];
	double longitude = [[[dictionary valueForKey:@"location"] valueForKey:@"lng"] doubleValue];
	[self setLocation:[[[CLLocation alloc] initWithLatitude:latitude longitude:longitude] autorelease]];
	
	[self setTwitter:[[dictionary valueForKey:@"contact"] valueForKey:@"twitter"]];
	NSString *aPhone = [[dictionary valueForKey:@"contact"] valueForKey:@"formattedPhone"];
	if (!aPhone) {
		aPhone = [[dictionary valueForKey:@"contact"] valueForKey:@"phone"];
	}
	[self setPhone:aPhone];
	for (NSDictionary *aCategory in [dictionary valueForKey:@"categories"]) {
		if ([[aCategory valueForKey:@"primary"] boolValue]) {
			[self setCategory:[aCategory valueForKey:@"name"]];
			break;
		}
	}
	[self setCity:[[dictionary valueForKey:@"location"] valueForKey:@"city"]];
	[self setUrl:[dictionary valueForKey:@"url"]];
	[self setMenu:[dictionary valueForKey:@"menu"]];
	[self setDescription:[dictionary valueForKey:@"description"]];
	
	NSMutableArray *allPhotos = [[NSMutableArray alloc] init];
	for (NSDictionary *group in [[dictionary valueForKey:@"photos"] valueForKey:@"groups"]) {
		for (NSDictionary *photo in [group valueForKey:@"items"]) {
			[allPhotos addObject:[photo valueForKey:@"url"]];
		}
	}
	[self setPhotos:allPhotos];
	[allPhotos release];
}

- (void)dealloc {
	self.name = nil;
	self.uniqueID = nil;
	
	[super dealloc];
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:[CIVenue class]] && [[(CIVenue *)object uniqueID] isEqual:self.uniqueID]) {
		return YES;
	}
	return NO;
}

- (double)distance {
	CLLocation *currentLocation = [[[CIFoursquareEngine sharedEngine] locationManager] location];
	
	return [currentLocation distanceFromLocation:self.location];
}

@end
