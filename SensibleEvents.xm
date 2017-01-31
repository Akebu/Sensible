#import <libactivator/libactivator.h>

@interface SensibleEvent : NSObject <LAEventDataSource>
@end

@implementation SensibleEvent

static SensibleEvent *sensibleEvent;

+ (void)load
{
        @autoreleasepool {
		sensibleEvent = [[SensibleEvent alloc] init];
        }
}

- (id)init {
        if ((self = [super init])) {
                [LASharedActivator registerEventDataSource:self forEventName:@"com.sensible.singletouch"];
		[LASharedActivator registerEventDataSource:self forEventName:@"com.sensible.doubletouch"];
		[LASharedActivator registerEventDataSource:self forEventName:@"com.sensible.tripletouch"];
		[LASharedActivator registerEventDataSource:self forEventName:@"com.sensible.hold"];
		[LASharedActivator registerEventDataSource:self forEventName:@"com.sensible.singletouchandhold"];
        }
        return self;
}

- (void)dealloc {
	[LASharedActivator unregisterEventDataSourceWithEventName:@"com.sensible.singletouch"];
	[LASharedActivator unregisterEventDataSourceWithEventName:@"com.sensible.doubletouch"];
	[LASharedActivator unregisterEventDataSourceWithEventName:@"com.sensible.tripletouch"];
	[LASharedActivator unregisterEventDataSourceWithEventName:@"com.sensible.hold"];
	[LASharedActivator unregisterEventDataSourceWithEventName:@"com.sensible.singletouchandhold"];
        [super dealloc];
}

- (NSString *)localizedTitleForEventName:(NSString *)eventName {
	NSString *title = nil;
	if([eventName isEqualToString:@"com.sensible.singletouch"]){
		title = @"Single touch";
	}
	else if([eventName isEqualToString:@"com.sensible.doubletouch"]){
		title = @"Double touch";
	}
	else if([eventName isEqualToString:@"com.sensible.tripletouch"]){
		title = @"Triple touch";
	}
	else if([eventName isEqualToString:@"com.sensible.singletouchandhold"]){
		title = @"Single touch and hold";
	}
	else if([eventName isEqualToString:@"com.sensible.hold"]){
		title = @"Hold";
	}
        return title;
}

- (NSString *)localizedGroupForEventName:(NSString *)eventName {
        return @"Sensible";
}

- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
	NSString *description;
	if([eventName isEqualToString:@"com.sensible.singletouch"]){
		description = @"Touch sensor once";
	}
	if([eventName isEqualToString:@"com.sensible.doubletouch"]){
		description = @"Touch sensor twice";
	}
	if([eventName isEqualToString:@"com.sensible.tripletouch"]){
		description = @"Touch sensor thrice";
	}
	if([eventName isEqualToString:@"com.sensible.singletouchandhold"]){
		description = @"Touch sensor once and hold";
	}
	if([eventName isEqualToString:@"com.sensible.hold"]){
		description = @"Put sensor once and hold";
	}
        return description;
}

@end

%ctor
{
	%init;
	[SensibleEvent load];
}
