#define TouchIDFingerDown  1
#define TouchIDFingerUp    0

#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>
#include <mach/mach.h>
#include <mach/mach_time.h>

FOUNDATION_EXTERN void AudioServicesPlaySystemSoundWithVibration(unsigned long, objc_object*, NSDictionary*);
typedef uint32_t IOHIDEventOptionBits;
typedef CFTypeRef IOHIDEventRef;
extern "C" {
    IOHIDEventRef IOHIDEventCreateKeyboardEvent(CFAllocatorRef allocator, uint64_t time, uint16_t page, uint16_t usage, Boolean down, IOHIDEventOptionBits flags);
}

@interface NSTask : NSObject
- (void)setLaunchPath:(id)arg1;
- (void)setArguments:(id)arg1;
- (void)launch;
@end

@interface SBApplication : NSObject
-(int)pid;
@end

@interface SBApplicationController
+(id)sharedInstance;
-(id)applicationWithBundleIdentifier:(id)arg1 ;
@end

@interface SBUIController : NSObject
+(id)sharedInstanceIfExists;
+(id)sharedInstance;
-(id)_switchAppList;
-(void)activateApplication:(id)arg1 ;
-(BOOL)_handleButtonEventToSuspendDisplays:(BOOL)arg1 displayWasSuspendedOut:(BOOL)arg2 ;
-(void)programmaticSwitchAppGestureMoveToRight;
@end

@interface SBSwitchAppList : NSObject
-(NSArray *)list;
-(id)applicationBundleIDBeforeBundleID:(id)arg1 ;
-(id)applicationBundleIDAfterBundleID:(id)arg1 ;
@end

@interface SBReachabilityTrigger : NSObject
@end

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

@interface SBReachabilityManager : NSObject
+(id)sharedInstance;
-(void)_handleReachabilityActivated;
-(void)_handleReachabilityDeactivated;
-(BOOL)reachabilityModeActive;
-(BOOL)reachabilityEnabled;
@end

@interface BiometricKit : NSObject
+ (id)manager;
@end

@interface SBVoiceControlController : NSObject
+(id)sharedInstance;
-(void)preheatForMenuButtonWithFireDate:(id)arg1 ;
@end

@interface SBUIPluginManager : NSObject
+(id)sharedInstance;
-(BOOL)handleButtonDownEventFromSource:(int)arg1;
-(BOOL)handleButtonUpEventFromSource:(int)arg1;
-(void)cancelPendingActivationEvent:(int)arg1;
-(void)prepareForActivationEvent:(int)arg1 eventSource:(int)arg2 afterInterval:(double)arg3;
@end

@interface SBIconController : NSObject
+(id)sharedInstance;
-(void)setIsEditing:(BOOL)arg1;
-(BOOL)isEditing;
@end

@interface SpringBoard : NSObject
+ (id) sharedApplication;
- (void)_lockButtonDown:(CFTypeRef)arg1 fromSource:(int)arg2;
- (void)_lockButtonUp:(CFTypeRef)arg1 fromSource:(int)arg2;
- (void)_handleMenuButtonEvent;
- (void)_menuButtonWasHeld;
- (void)handleMenuDoubleTap;
- (void)_menuButtonDown:(IOHIDEventRef)event;
- (void)_menuButtonUp:(IOHIDEventRef)event;
- (void)cancelMenuButtonRequests;
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

- (void)startMonitoring;
- (void)stopMonitoring;
- (void)_stopTimerIfLaunched;
@end

@interface SBLockScreenManager : NSObject
+ (id) sharedInstanceIfExists;
+ (id) sharedInstance;
- (BOOL)isUILocked;
- (void)noteMenuButtonDown;
- (void)noteMenuButtonUp;
@end
