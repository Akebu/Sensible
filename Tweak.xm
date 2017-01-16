#define TouchIDFingerDown  1
#define TouchIDFingerUp    0

#import <objc/runtime.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>
#import <CoreFoundation/CFNotificationCenter.h>
#include <mach/mach.h>
#include <mach/mach_time.h>


FOUNDATION_EXTERN void AudioServicesPlaySystemSoundWithVibration(unsigned long, objc_object*, NSDictionary*);
typedef uint32_t IOHIDEventOptionBits;
typedef CFTypeRef IOHIDEventRef;
extern "C" {
    IOHIDEventRef IOHIDEventCreateKeyboardEvent(CFAllocatorRef allocator, uint64_t time, uint16_t page, uint16_t usage, Boolean down, IOHIDEventOptionBits flags);
}
static NSOperationQueue *uninstallQueue;


@protocol SBUIBiometricEventMonitorDelegate
@required
-(void)biometricEventMonitor:(id)monitor handleBiometricEvent:(unsigned)event;
@end

@interface SBUIBiometricEventMonitor : NSObject
+ (id)sharedInstance;
- (void)addObserver:(id)arg1;
- (void)removeObserver:(id)arg1;
- (void)_stopFingerDetection;
- (void)setFingerDetectEnabled:(BOOL)arg1 requester:(id)arg2;
@end

@interface BiometricKit : NSObject
+ (id)manager;
@end

@interface SpringBoard : NSObject
+ (id) sharedApplication;
- (void)_menuButtonDown:(IOHIDEventRef)event;
- (void)_menuButtonUp:(IOHIDEventRef)event;
- (void)_lockButtonDown:(IOHIDEventRef)arg1 fromSource:(int)arg2;
- (void)_lockButtonUp:(IOHIDEventRef)arg1 fromSource:(int)arg2;
@end

@interface BTTouchIDController : NSObject <SBUIBiometricEventMonitorDelegate> {
	BOOL isMonitoring;
}

+ (id)sharedInstance;
- (void)startMonitoring;
- (void)stopMonitoring;
- (void)vibrateWithDuration:(int)duration ForIntensity:(float)intensity;
- (void)simulateHomeButtonDown;
- (void)simulateHomeButtonUp;
- (void)simulateLockButton;
@end

@implementation BTTouchIDController

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
	IOHIDEventRef event = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), 0xC, 48, 1, 0);        
	[springBoard _lockButtonDown:event fromSource:1];    
	CFRelease(event);
	event = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), 0xC, 48, 0, 0); 
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

%hook SBDeviceLockController

-(void)_lockStateChangedFrom:(int)oldLockState to:(int)lockState
{
	%orig;

	if(lockState == 1){
		NSLog(@"[Sensible] Start Monitoring TouchID");
		[[BTTouchIDController sharedInstance] startMonitoring];
		[[%c(SBUIBiometricEventMonitor) sharedInstance] setFingerDetectEnabled:true requester:@""];
	}
	if(lockState == 0){
		
		NSLog(@"[Sensible] Stop Monitoring TouchID");
		[[BTTouchIDController sharedInstance] stopMonitoring];
		[[%c(SBUIBiometricEventMonitor) sharedInstance] _stopFingerDetection];
	}
		
}

%end

%ctor {
uninstallQueue = [[NSOperationQueue alloc] init];
}
