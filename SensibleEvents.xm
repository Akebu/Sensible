#import "SensibleConst.h"
#import "libactivator/libactivator.h"

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
		LAActivator *sharedActivator = [%c(LAActivator) sharedInstance];
                [sharedActivator registerEventDataSource:self forEventName:kSingleTouch];
		[sharedActivator registerEventDataSource:self forEventName:kDoubleTouch];
		[sharedActivator registerEventDataSource:self forEventName:kTripleTouch];
		[sharedActivator registerEventDataSource:self forEventName:kHold];
		[sharedActivator registerEventDataSource:self forEventName:kSingleTouchAndHold];
        }
        return self;
}

- (void)dealloc {
	LAActivator *sharedActivator = [%c(LAActivator) sharedInstance];
	[sharedActivator unregisterEventDataSourceWithEventName:kSingleTouch];
	[sharedActivator unregisterEventDataSourceWithEventName:kDoubleTouch];
	[sharedActivator unregisterEventDataSourceWithEventName:kTripleTouch];
	[sharedActivator unregisterEventDataSourceWithEventName:kHold];
	[sharedActivator unregisterEventDataSourceWithEventName:kSingleTouchAndHold];
        [super dealloc];
}

- (NSString *)localizedTitleForEventName:(NSString *)eventName {
	NSString *title = nil;
	if([eventName isEqualToString:kSingleTouch]){
		title = @"Single touch";
	}
	else if([eventName isEqualToString:kDoubleTouch]){
		title = @"Double touch";
	}
	else if([eventName isEqualToString:kTripleTouch]){
		title = @"Triple touch";
	}
	else if([eventName isEqualToString:kHold]){
		title = @"Hold";
	}
	else if([eventName isEqualToString:kSingleTouchAndHold]){
		title = @"Single touch and hold";
	}
        return title;
}

- (NSString *)localizedGroupForEventName:(NSString *)eventName {
        return @"Sensible";
}

- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
	NSString *description;
	if([eventName isEqualToString:kSingleTouch]){
		description = @"Touch sensor once";
	}
	if([eventName isEqualToString:kDoubleTouch]){
		description = @"Touch sensor twice";
	}
	if([eventName isEqualToString:kTripleTouch]){
		description = @"Touch sensor thrice";
	}
	if([eventName isEqualToString:kHold]){
		description = @"Hold on the sensor";
	}
	if([eventName isEqualToString:kSingleTouchAndHold]){
		description = @"Touch sensor once and hold";
	}
        return description;
}

@end

%ctor
{
	%init;
	dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
	Class la = %c(LAActivator);
	if(la){
		[SensibleEvent load];
	}
}
