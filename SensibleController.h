#define TouchIDFingerDown  1
#define TouchIDFingerUp    0

#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>
#import <CoreFoundation/CFNotificationCenter.h>
#include <mach/mach.h>
#include <mach/mach_time.h>
#import <objc/runtime.h>

@protocol SBUIBiometricEventMonitorDelegate
@required
-(void)biometricEventMonitor:(id)monitor handleBiometricEvent:(unsigned)event;
@end

@interface SBUIBiometricEventMonitor : NSObject
+ (id)sharedInstance;
- (void)addObserver:(id)arg1;
- (void)removeObserver:(id)arg1;
- (void)_stopFingerDetection;
- (void)setFingerDetectEnabled:(BOOL)arg1 requester:(CFStringRef)arg2;
- (void)_startFingerDetection;
- (void)setMatchingDisabled:(BOOL)arg1 requester:(CFStringRef)arg2;
- (void) _setMatchingEnabled:(BOOL)arg1;
@end

@interface BiometricKit : NSObject
+ (id)manager;
@end

@interface SpringBoard : NSObject
+ (id) sharedApplication;
- (void)_menuButtonDown:(CFTypeRef)event;
- (void)_menuButtonUp:(CFTypeRef)event;
- (void)_lockButtonDown:(CFTypeRef)arg1 fromSource:(int)arg2;
- (void)_lockButtonUp:(CFTypeRef)arg1 fromSource:(int)arg2;
@end

@interface SensibleController : NSObject <SBUIBiometricEventMonitorDelegate> {
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
