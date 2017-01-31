#import "SensibleController.h"

FOUNDATION_EXTERN void AudioServicesPlaySystemSoundWithVibration(unsigned long, objc_object*, NSDictionary*);
typedef uint32_t IOHIDEventOptionBits;
typedef CFTypeRef IOHIDEventRef;
extern "C" {
    IOHIDEventRef IOHIDEventCreateKeyboardEvent(CFAllocatorRef allocator, uint64_t time, uint16_t page, uint16_t usage, Boolean down, IOHIDEventOptionBits flags);
}

@implementation SensibleController

+(id)sharedInstance {
	static id sharedInstance = nil;
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		sharedInstance = [self new];
	});

	return sharedInstance;
}

- (void)simulateHomeButtonDown
{   
	SpringBoard *springBoard = [%c(SpringBoard) sharedApplication];
	IOHIDEventRef event = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), 12, 64, 1, 0);    
	[springBoard _menuButtonDown:event];    
	CFRelease(event);
}

- (void)simulateHomeButtonUp
{   
	SpringBoard *springBoard = [%c(SpringBoard) sharedApplication];
	IOHIDEventRef event = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), 12, 64, 0, 0);    
	[springBoard _menuButtonUp:event];    
	CFRelease(event);
}

- (void)simulateLockButton
{
	SpringBoard *springBoard = [%c(SpringBoard) sharedApplication];
	IOHIDEventRef event = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), 12, 48, 1, 0);        
	[springBoard _lockButtonDown:event fromSource:1];    
	CFRelease(event);
	event = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), 12, 48, 0, 0); 
	[springBoard _lockButtonUp:event fromSource:1];    
	CFRelease(event);

}

-(void)biometricEventMonitor:(id)monitor handleBiometricEvent:(unsigned)event {
	if(event == TouchIDFingerDown){
		[self vibrateWithDuration:35 ForIntensity:1];
		[self simulateHomeButtonDown];
		
	}
	if(event == TouchIDFingerUp){
		[self simulateHomeButtonUp];
	}
}

-(void)vibrateWithDuration:(int)duration ForIntensity:(float)intensity
{
	NSArray* arr = @[[NSNumber numberWithBool:YES], [NSNumber numberWithInt:duration], [NSNumber numberWithBool:NO], [NSNumber numberWithInt:50]];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:arr,@"VibePattern",[NSNumber numberWithFloat:intensity],@"Intensity",nil];
	AudioServicesPlaySystemSoundWithVibration(kSystemSoundID_Vibrate, nil, dict);
}

-(void)startMonitoring {

	if(isMonitoring) {
		return;
	}
	isMonitoring = YES;

	SBUIBiometricEventMonitor* monitor = [[%c(BiometricKit) manager] delegate];
	[monitor addObserver:self];

}

-(void)stopMonitoring {

	if(!isMonitoring) {
		return;
	}
	isMonitoring = NO;

	SBUIBiometricEventMonitor* monitor = [[%c(BiometricKit) manager] delegate];
	[monitor removeObserver:self];
}

@end
