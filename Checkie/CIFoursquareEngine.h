#import <Foundation/Foundation.h>
#import "CIVenue.h"

@interface CIFoursquareEngine : NSObject

@property (nonatomic, retain) CIVenue *checkingInVenue;
@property (nonatomic, retain) CIVenue *checkedInVenue;
@property (nonatomic, assign) int checkedInPoints;

+ (CIFoursquareEngine *)sharedEngine;
+ (NSString *)clientID;
+ (NSString *)clientSecret;
+ (NSString *)callbackURL;
+ (BOOL)isLoggedIn;
+ (NSString *)token;
- (void)logout;

- (CLLocationManager *)locationManager;

- (void)getNearbyVenuesWithSearchString:(NSString *)string andCallback:(void (^)(NSArray *results))callback;
- (void)checkInAtVenue:(CIVenue *)venue withCallback:(void (^)(BOOL result))callback;
- (void)updateLastCheckedInVenueWithCallback:(void (^)(CIVenue *result))callback;
- (BOOL)isCurrentlyCheckedInAtVenue:(CIVenue *)venue;
- (BOOL)isCheckingInAtVenue:(CIVenue *)venue;

- (void)getVenueWithID:(NSString *)uniqueID andCallback:(void (^)(CIVenue *venue))callback;


@end
