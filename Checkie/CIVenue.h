#import <Foundation/Foundation.h>

@interface CIVenue : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *uniqueID;
@property (nonatomic, retain) CLLocation *location;

@property (nonatomic, retain) NSString *twitter;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSString *city;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *menu;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSArray *photos;

//@property (nonatomic, retain) NSArray *hereNow;

+ (CIVenue *)venueFromDictionary:(NSDictionary *)dictionary;
- (void)updateFromDictionary:(NSDictionary *)dictionary;

- (double)distance;

@end
