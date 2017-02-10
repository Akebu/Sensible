#import "SensibleController.h"
#import "SensibleConst.h"
#import <libactivator/libactivator.h>
#import <QuartzCore/QuartzCore.h>

FOUNDATION_EXTERN void AudioServicesPlaySystemSoundWithVibration(unsigned long, objc_object*, NSDictionary*);
typedef uint32_t IOHIDEventOptionBits;
typedef CFTypeRef IOHIDEventRef;
extern "C" {
    IOHIDEventRef IOHIDEventCreateKeyboardEvent(CFAllocatorRef allocator, uint64_t time, uint16_t page, uint16_t usage, Boolean down, IOHIDEventOptionBits flags);
}

@implementation SensibleController

+ (id)sharedInstance {
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

// === Handle touch on sensor

-(void)biometricEventMonitor:(id)monitor handleBiometricEvent:(unsigned)event {
	if(event == TouchIDFingerDown){
		[self vibrate];
		isHolding = true;
		holdTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(getHold) userInfo:nil repeats:NO];
		numberOfTouch++;
		if(_optimize){
			float timeInterval = CACurrentMediaTime() - startTime;
			if((timeInterval <= 0.3) && (timeInterval > 0.15)){
				float timeToAdd = timeInterval;
				[touchRecord addObject:[NSNumber numberWithFloat:timeToAdd]];
				float newWaitTime = [[touchRecord valueForKeyPath:@"@avg.floatValue"] floatValue]+0.05;
				_waitTime = [NSNumber numberWithFloat:newWaitTime];
			}
		}
		if(numberOfTouch == 3){
			[self getTouch];
			[self resetTouchTimer];
			return;
		}
		else if(numberOfTouch == 2){
			[_touchTimer invalidate], _touchTimer = nil;
			if(_singleTouchAndHoldAction == 5){
				[self sendEventFromSource:DoubleTouch];
				[holdTimer invalidate], holdTimer = nil;
				[self resetTouchTimer];
			}else{
				_touchTimer = [NSTimer scheduledTimerWithTimeInterval:[_waitTime floatValue] target:self selector:@selector(getTouch) userInfo:nil repeats:NO];
			}
			return;
		}
		else
		{
			_touchTimer = [NSTimer scheduledTimerWithTimeInterval:[_waitTime floatValue] target:self selector:@selector(getTouch) userInfo:nil repeats:NO];
			startTime = CACurrentMediaTime();
			return;
		}
	}
	if(event == TouchIDFingerUp){
		if([holdTimer isValid]){
			[holdTimer invalidate], holdTimer = nil;
		}
		isHolding = false;
	}
}

- (void)getTouch
{
	if(numberOfTouch == 1){
		if(!isHolding){
			[self sendEventFromSource:SingleTouch];
		}
	}else if(numberOfTouch == 2){
		if(isHolding){
			[self sendEventFromSource:SingleTouchAndHold];
			[holdTimer invalidate], holdTimer = nil;
		}else{
			[self sendEventFromSource:DoubleTouch];
		}
	}else{
		[self sendEventFromSource:TripleTouch];
	}
	if(_optimize){
		if([touchRecord count] == 50){
			[touchRecord removeAllObjects];
			[touchRecord addObject:_waitTime];
		}
	}

	numberOfTouch = 0;
}

- (void)getHold
{
	[self sendEventFromSource:Hold];
	numberOfTouch = 0;
}

- (void)resetTouchTimer
{
	[_touchTimer invalidate], _touchTimer = nil;
	numberOfTouch = 0;
}

-(void)vibrate
{
	NSArray* arr = @[[NSNumber numberWithBool:YES], [NSNumber numberWithFloat:[self duration]]];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:arr,@"VibePattern",[NSNumber numberWithFloat:[self intensity]],@"Intensity", nil];
	AudioServicesPlaySystemSoundWithVibration(kSystemSoundID_Vibrate, nil, dict);
}

-(void)startMonitoring {
	if(isMonitoring) {
		return;
	}
	isMonitoring = YES;
	SBUIBiometricEventMonitor* monitor = [[%c(BiometricKit) manager] delegate];
	[monitor addObserver:self];
	numberOfTouch = 0;
	[[%c(SBUIBiometricEventMonitor) sharedInstance] setFingerDetectEnabled:YES requester:CFSTR("SensibleController")];
}

-(void)stopMonitoring {
	if(!isMonitoring) {
		return;
	}
	isMonitoring = NO;
	SBUIBiometricEventMonitor* monitor = [[%c(BiometricKit) manager] delegate];
	[monitor removeObserver:self];

	[[%c(SBUIBiometricEventMonitor) sharedInstance] setFingerDetectEnabled:NO requester:CFSTR("SensibleController")];
}

- (void)sendEventFromSource:(NSString *)source
{
	int action = -1;

	if([source isEqualToString:SingleTouch]){
		action = [self singleTouchAction];
	}
	else if([source isEqualToString:DoubleTouch]){
		action = [self doubleTouchAction];
	}
	else if([source isEqualToString:TripleTouch]){
		action = [self tripleTouchAction];
	}
	else if([source isEqualToString:Hold]){
		action = [self holdTouchAction];
	}
	else if([source isEqualToString:SingleTouchAndHold]){
		action = [self singleTouchAndHoldAction];
	}
	switch (action){
		case 0:{
			// ===== Simulate home button =====

			if([[%c(SBControlCenterController) sharedInstance] isVisible]){
				[[%c(SBControlCenterController) sharedInstance] dismissAnimated:true completion:nil];
			}
			else if([[%c(SBNotificationCenterController) sharedInstance] isVisible]){
				[[%c(SBNotificationCenterController) sharedInstance] dismissAnimated:true];
			}
			else
			{
				[[%c(SBUIController) sharedInstance] clickedMenuButton];
			}
			//[self simulateHomeButtonDown];
			//[self simulateHomeButtonUp];
		break;
		}
		case 1:{
			// ===== Multitask =====
			[[%c(SBUIController) sharedInstance] handleMenuDoubleTap];
		break;
		}
		case 2:{
			// ===== Simulate lock button =====
			[self simulateLockButton];
		break;
		}
		case 3:{
			// ===== Call activator action =====
			LAEvent *event = [LAEvent eventWithName:source mode:[LASharedActivator currentEventMode]];
			[LASharedActivator sendEventToListener:event];
		break;
		}
		case 4:{
			// ===== Siri / VoiceControl =====
			[[%c(SBVoiceControlController) sharedInstance] handleHomeButtonHeld];
		break;
		}
	}
}

- (void) setOptimize:(BOOL)shouldEnable
{
	_optimize = shouldEnable;
	if(_optimize){
		if(touchRecord == nil){
			touchRecord = [[NSMutableArray alloc] init];
		}
	}else{
		touchRecord = nil;
	}
}

@end

static void loadPrefs() {

	CFStringRef SensiblePrefs = (__bridge CFStringRef)SensiblePlist;
	CFStringRef isTweakEnabled = (__bridge CFStringRef)EnableKey;
	CFStringRef protectCC = (__bridge CFStringRef)ProtectCCKey;
	CFStringRef optimizeKey = (__bridge CFStringRef)OptimizeKey;
	CFStringRef waitTimeMS = (__bridge CFStringRef)WaitTimeKey;
	CFStringRef vibrationIntensity = (__bridge CFStringRef)VibrationIntensityKey;
	CFStringRef vibrationDuration = (__bridge CFStringRef)VibrationDurationKey;
	CFStringRef singleTouchList = (__bridge CFStringRef)SingleTouchList;
	CFStringRef doubleTouchList = (__bridge CFStringRef)DoubleTouchList;
	CFStringRef tripleTouchList = (__bridge CFStringRef)TripleTouchList;
	CFStringRef hold = (__bridge CFStringRef)HoldTouchList;
	CFStringRef singleTouchAndHold = (__bridge CFStringRef)SingleTouchAndHoldList;

	bool isEnabled = true;
	bool sShouldProtectCC = true;
	bool sShouldOptimize = true;
	NSNumber *sWaitTimeinMs = [NSNumber numberWithFloat:0.20];
	float sIntensity = 1.0;
	float sDuration = 35.0;
	int sSingleTouchAction = 0;
	int sDoubleTouchAction = 1;
	int sTripleTouchAction = 5;
	int sHoldTouchAction = 4;
	int sSingleTouchAndHoldAction = 2;

	CFPreferencesAppSynchronize(SensiblePrefs);
	SensibleController *sController = [SensibleController sharedInstance];

	// ===== Activation =====
	if (CFBridgingRelease(CFPreferencesCopyAppValue(isTweakEnabled, SensiblePrefs))) {
		isEnabled = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(isTweakEnabled, SensiblePrefs)) boolValue];
	}

	// ===== Vibrations =====
	if (CFBridgingRelease(CFPreferencesCopyAppValue(vibrationIntensity, SensiblePrefs))) {
		sIntensity = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(vibrationIntensity, SensiblePrefs)) floatValue];
	}
	if (CFBridgingRelease(CFPreferencesCopyAppValue(vibrationDuration, SensiblePrefs))) {
		sDuration = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(vibrationDuration, SensiblePrefs)) floatValue];
	}

	// ===== Actions =====
	if (CFBridgingRelease(CFPreferencesCopyAppValue(singleTouchList, SensiblePrefs))) {
		sSingleTouchAction = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(singleTouchList, SensiblePrefs)) intValue];
	}
	if (CFBridgingRelease(CFPreferencesCopyAppValue(doubleTouchList, SensiblePrefs))) {
		sDoubleTouchAction = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(doubleTouchList, SensiblePrefs)) intValue];
	}
	if (CFBridgingRelease(CFPreferencesCopyAppValue(tripleTouchList, SensiblePrefs))) {
		sTripleTouchAction = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(tripleTouchList, SensiblePrefs)) intValue];
	}
	if (CFBridgingRelease(CFPreferencesCopyAppValue(hold, SensiblePrefs))) {
		sHoldTouchAction = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(hold, SensiblePrefs)) intValue];
	}
	if (CFBridgingRelease(CFPreferencesCopyAppValue(singleTouchAndHold, SensiblePrefs))) {
		sSingleTouchAndHoldAction = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(singleTouchAndHold, SensiblePrefs)) intValue];
	}
	if (CFBridgingRelease(CFPreferencesCopyAppValue(protectCC, SensiblePrefs))) {
		sShouldProtectCC = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(protectCC, SensiblePrefs)) boolValue];
	}
	if (CFBridgingRelease(CFPreferencesCopyAppValue(optimizeKey, SensiblePrefs))) {
		sShouldOptimize = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(optimizeKey, SensiblePrefs)) boolValue];
	}
	if (CFBridgingRelease(CFPreferencesCopyAppValue(waitTimeMS, SensiblePrefs))) {
		sWaitTimeinMs = [NSNumber numberWithFloat:[(id)CFBridgingRelease(CFPreferencesCopyAppValue(waitTimeMS, SensiblePrefs)) floatValue]];
	}

	[sController setIsEnabled:isEnabled];
	SBLockScreenManager *possibleSharedInstance = [%c(SBLockScreenManager) sharedInstanceIfExists];
	if(possibleSharedInstance != nil || [possibleSharedInstance isUILocked] != false){
		if(isEnabled){
			[[SensibleController sharedInstance] startMonitoring];
		}else{
			[[SensibleController sharedInstance] stopMonitoring];
		}
	}
	[sController setIntensity:sIntensity];
	[sController setDuration:sDuration];
	[sController setSingleTouchAction:sSingleTouchAction];
	[sController setDoubleTouchAction:sDoubleTouchAction];
	[sController setTripleTouchAction:sTripleTouchAction];
	[sController setHoldTouchAction:sHoldTouchAction];
	[sController setSingleTouchAndHoldAction:sSingleTouchAndHoldAction];
	[sController setProtectCC:sShouldProtectCC];
	[sController setOptimize:sShouldOptimize];
	[sController setWaitTime:sWaitTimeinMs];
}

%hook SBControlCenterController

-(void)_showControlCenterGestureBeganWithGestureRecognizer:(id)arg1
{
	SensibleController *sController = [SensibleController sharedInstance];
	if([[sController touchTimer] isValid]){
		[sController resetTouchTimer];
	}
	%orig;
}

%end

%ctor
{
	%init;
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.tonyciroussel.sensible/reloadSettings"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	loadPrefs();
}
