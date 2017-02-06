#import <libactivator/libactivator.h>
#import "SensibleConst.h"

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
                [LASharedActivator registerEventDataSource:self forEventName:SingleTouch];
		[LASharedActivator registerEventDataSource:self forEventName:DoubleTouch];
		[LASharedActivator registerEventDataSource:self forEventName:TripleTouch];
		[LASharedActivator registerEventDataSource:self forEventName:Hold];
		[LASharedActivator registerEventDataSource:self forEventName:SingleTouchAndHold];
        }
        return self;
}

- (void)dealloc {
	[LASharedActivator unregisterEventDataSourceWithEventName:SingleTouch];
	[LASharedActivator unregisterEventDataSourceWithEventName:DoubleTouch];
	[LASharedActivator unregisterEventDataSourceWithEventName:TripleTouch];
	[LASharedActivator unregisterEventDataSourceWithEventName:Hold];
	[LASharedActivator unregisterEventDataSourceWithEventName:SingleTouchAndHold];
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
	[SensibleEvent load];
}
