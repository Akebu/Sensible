#define TouchIDFingerDown  1
#define TouchIDFingerUp    0

#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>
#include <mach/mach.h>
#include <mach/mach_time.h>

@protocol SBUIBiometricEventMonitorDelegate
@required
-(void)biometricEventMonitor:(id)monitor handleBiometricEvent:(unsigned)event;
@end

@interface SBUIBiometricEventMonitor : NSObject
+ (id)sharedInstance;
- (void)addObserver:(id)arg1;
- (void)removeObserver:(id)arg1;
- (void)setFingerDetectEnabled:(BOOL)arg1 requester:(CFStringRef)arg2;
@end

@interface BiometricKit : NSObject
+ (id)manager;
@end

@interface SpringBoard : NSObject
+ (id) sharedApplication;
- (void)_lockButtonDown:(CFTypeRef)arg1 fromSource:(int)arg2;
- (void)_lockButtonUp:(CFTypeRef)arg1 fromSource:(int)arg2;
- (void)_handleMenuButtonEvent;
- (void)_menuButtonWasHeld;
- (void)handleMenuDoubleTap;
@end

@interface SensibleController : NSObject <SBUIBiometricEventMonitorDelegate> {
	BOOL isMonitoring;
	int numberOfTouch;
	float touchRecord;
	CFTimeInterval startTime;
	NSTimer *touchTimer;
}

@property (nonatomic, assign) BOOL isEnabled;
@property (nonatomic, assign) BOOL protectCC;
@property (nonatomic, assign) BOOL optimize;
@property (nonatomic, assign) float duration;
@property (nonatomic, assign) float intensity;
@property (nonatomic, assign) float waitTime;
@property (nonatomic, assign) int singleTouchAction;
@property (nonatomic, assign) int doubleTouchAction;
@property (nonatomic, assign) int tripleTouchAction;
@property (nonatomic, assign) int holdTouchAction;
@property (nonatomic, assign) int singleTouchAndHoldAction;

+ (id)sharedInstance;
- (void)startMonitoring;
- (void)stopMonitoring;
- (void)_stopTimerIfLaunched;
@end

@interface SBLockScreenManager : NSObject
+ (id) sharedInstanceIfExists;
- (BOOL)isUILocked;
@end
