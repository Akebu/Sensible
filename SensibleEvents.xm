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
                [sharedActivator registerEventDataSource:self forEventName:SingleTouch];
		[sharedActivator registerEventDataSource:self forEventName:DoubleTouch];
		[sharedActivator registerEventDataSource:self forEventName:TripleTouch];
		[sharedActivator registerEventDataSource:self forEventName:Hold];
		[sharedActivator registerEventDataSource:self forEventName:SingleTouchAndHold];
        }
        return self;
}

- (void)dealloc {
	LAActivator *sharedActivator = [%c(LAActivator) sharedInstance];
	[sharedActivator unregisterEventDataSourceWithEventName:SingleTouch];
	[sharedActivator unregisterEventDataSourceWithEventName:DoubleTouch];
	[sharedActivator unregisterEventDataSourceWithEventName:TripleTouch];
	[sharedActivator unregisterEventDataSourceWithEventName:Hold];
	[sharedActivator unregisterEventDataSourceWithEventName:SingleTouchAndHold];
        [super dealloc];
}

- (NSString *)localizedTitleForEventName:(NSString *)eventName {
	NSString *title = nil;
	if([eventName isEqualToString:SingleTouch]){
		title = @"Single touch";
	}
	else if([eventName isEqualToString:DoubleTouch]){
		title = @"Double touch";
	}
	else if([eventName isEqualToString:TripleTouch]){
		title = @"Triple touch";
	}
	else if([eventName isEqualToString:Hold]){
		title = @"Hold";
	}
	else if([eventName isEqualToString:SingleTouchAndHold]){
		title = @"Single touch and hold";
	}
        return title;
}

- (NSString *)localizedGroupForEventName:(NSString *)eventName {
        return @"Sensible";
}

- (NSString *)localizedDescriptionForEventName:(NSString *)eventName {
	NSString *description;
	if([eventName isEqualToString:SingleTouch]){
		description = @"Touch sensor once";
	}
	if([eventName isEqualToString:DoubleTouch]){
		description = @"Touch sensor twice";
	}
	if([eventName isEqualToString:TripleTouch]){
		description = @"Touch sensor thrice";
	}
	if([eventName isEqualToString:Hold]){
		description = @"Hold on the sensor";
	}
	if([eventName isEqualToString:SingleTouchAndHold]){
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
