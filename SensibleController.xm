#import "SensibleController.h"
#import "SensibleConst.h"
#import <libactivator/libactivator.h>

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

/* Handle Touch on TouchID sensor */

-(void)biometricEventMonitor:(id)monitor handleBiometricEvent:(unsigned)event {

	/* TouchID Finger is DOWN */
	if(event == TouchIDFingerDown){

		[self performSelectorInBackground:@selector(vibrate) withObject:nil];
		[[%c(SBLockScreenManager) sharedInstance] noteMenuButtonDown];
		if([[%c(SBUIPluginManager) sharedInstance] handleButtonDownEventFromSource:1]){
			return;
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SBMenuButtonPressedNotification" object:nil];
		if(_optimize){
			float timeInterval = CACurrentMediaTime() - startTime;
			if((timeInterval <= 0.3) && (timeInterval >= 0.15)){
				float timeToAdd = timeInterval;
				float newWaitTime = (_waitTime+timeToAdd)/2;
				_waitTime = newWaitTime;
			}
			startTime = CACurrentMediaTime();
		}
		if((_doubleTouchAction == 5) && (_tripleTouchAction == 5) && (_singleTouchAndHoldAction == 5)){
			[self performSelector:@selector(getActionForHoldingAfterTouch) withObject:nil afterDelay:0];
			return;
		}
		else if(numberOfTouch == -1){
			numberOfTouch = 0;
		}
		else if(numberOfTouch == 0){
			[self preheatHoldAction];
			[self performSelector:@selector(getActionForHold) withObject:nil afterDelay:1];
		}
		else if(numberOfTouch == 1){
			[touchTimer invalidate], touchTimer = nil;
			if((_tripleTouchAction == 5) && (_singleTouchAndHoldAction == 5)){
				numberOfTouch = 0;
				[self performSelector:@selector(sendEvenFromSource) withObject:DoubleTouch afterDelay:0];
			}
			if(_singleTouchAndHoldAction != 5){
				[self performSelector:@selector(getActionForHoldingAfterTouch) withObject:nil afterDelay:_waitTime+0.1];
			}
		}
	}

	/* TouchID Finger is UP */
	if(event == TouchIDFingerUp){
		[[%c(SBLockScreenManager) sharedInstance] noteMenuButtonUp];
		[[%c(SBVoiceControlController) sharedInstance] preheatForMenuButtonWithFireDate:[NSDate dateWithTimeIntervalSinceNow:nil]];
		if([[%c(SBUIPluginManager) sharedInstance] handleButtonUpEventFromSource:1]){
			return;
		}
		if(numberOfTouch > -1){
			numberOfTouch++;
		
			if(numberOfTouch == 1){
				[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getActionForHold) object:nil];
				[self resetHoldAction];
				touchTimer = [NSTimer scheduledTimerWithTimeInterval:_waitTime target:self selector:@selector(singleTouchTimer:) userInfo:nil repeats:NO];
			}
			else if(numberOfTouch == 2){
				[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getActionForHoldingAfterTouch) object:nil];
				if(_tripleTouchAction == 5){
					numberOfTouch = 0;
					[self sendEventFromSource:DoubleTouch];
				}else{
					[self performSelector:@selector(sendEventFromSource:) withObject:DoubleTouch afterDelay:_waitTime];
				}
			}
			else if(numberOfTouch == 3){
				[NSObject cancelPreviousPerformRequestsWithTarget:self];
				numberOfTouch = 0;
				[self sendEventFromSource:TripleTouch];
			}
		}
		else
		{
			numberOfTouch = 0;
		}
	}
}

- (void) preheatHoldAction
{
	[[%c(SBUIPluginManager) sharedInstance] prepareForActivationEvent:1 eventSource:1 afterInterval:0.5];
	[[%c(SBVoiceControlController) sharedInstance] preheatForMenuButtonWithFireDate:[NSDate dateWithTimeIntervalSinceNow:1.0f]];
}

- (void)resetHoldAction
{
	[[%c(SBUIPluginManager) sharedInstance] cancelPendingActivationEvent:1];
}

- (void)_stopTimerIfLaunched
{
	numberOfTouch = -1;
	if([touchTimer isValid]){
		[touchTimer invalidate], touchTimer = nil;
	}
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getActionForHold) object:nil];
	[self resetHoldAction];
}

- (void)singleTouchTimer:(NSTimer *)timer
{
	[timer invalidate], timer = nil;
	numberOfTouch = 0;
	[self sendEventFromSource:SingleTouch];
}

- (void)getActionForHold
{
	[self sendEventFromSource:Hold];
	numberOfTouch = -1;
}

- (void)getActionForHoldingAfterTouch
{
	numberOfTouch = 0;
	[self sendEventFromSource:SingleTouchAndHold];
}

-(void)vibrate
{
	NSArray* arr = @[[NSNumber numberWithBool:YES], [NSNumber numberWithFloat:[self duration]]];
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:arr,@"VibePattern",[NSNumber numberWithFloat:[self intensity]],@"Intensity", nil];
	AudioServicesPlaySystemSoundWithVibration(kSystemSoundID_Vibrate, nil, dict);
}

-(void)startMonitoring {
	/*  From BioTesting by NoahSaso */
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
	/*  From BioTesting by NoahSaso */
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
	numberOfTouch = 0;

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
			/*  Home button */
			SBIconController *iconController = [%c(SBIconController) sharedInstance];
			if([iconController isEditing]){
				[iconController setIsEditing:false];
			}else{
				[[%c(SpringBoard) sharedApplication] _handleMenuButtonEvent];
			}
		break;
		}
		case 1:{
			/*  Multitask */
			[[%c(SpringBoard) sharedApplication] handleMenuDoubleTap];
		break;
		}
		case 2:{
			/*  Sleep! */
			[self simulateLockButton];
		break;
		}
		case 3:{
			/*  Activator */
			LAEvent *event = [LAEvent eventWithName:source mode:[LASharedActivator currentEventMode]];
			[LASharedActivator sendEventToListener:event];
		break;
		}
		case 4:{
			/*  Siri / VoiceControl */
			[[%c(SpringBoard) sharedApplication] _menuButtonWasHeld];
		break;
		}
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

	/*  Defaults values */
	bool isEnabled = true;
	bool sShouldProtectCC = true;
	bool sShouldOptimize = true;
	float sWaitTimeinMs = 0.20;
	float sIntensity = 1.0;
	float sDuration = 35.0;
	int sSingleTouchAction = 0;
	int sDoubleTouchAction = 1;
	int sTripleTouchAction = 5;
	int sHoldTouchAction = 4;
	int sSingleTouchAndHoldAction = 2;

	CFPreferencesAppSynchronize(SensiblePrefs);
	SensibleController *sController = [SensibleController sharedInstance];

	/*  Activation */
	if (CFBridgingRelease(CFPreferencesCopyAppValue(isTweakEnabled, SensiblePrefs))) {
		isEnabled = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(isTweakEnabled, SensiblePrefs)) boolValue];
	}

	/*  Vibrations */
	if (CFBridgingRelease(CFPreferencesCopyAppValue(vibrationIntensity, SensiblePrefs))) {
		sIntensity = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(vibrationIntensity, SensiblePrefs)) floatValue];
	}
	if (CFBridgingRelease(CFPreferencesCopyAppValue(vibrationDuration, SensiblePrefs))) {
		sDuration = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(vibrationDuration, SensiblePrefs)) floatValue];
	}

	/*  Events */
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
		sWaitTimeinMs = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(waitTimeMS, SensiblePrefs)) floatValue];
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

/* Hooks */

%hook SBControlCenterController

-(void)_showControlCenterGestureBeganWithGestureRecognizer:(id)arg1
{
	SensibleController *sController = [SensibleController sharedInstance];
	if([sController protectCC]){
		SensibleController *sController = [SensibleController sharedInstance];
		[sController _stopTimerIfLaunched];
	}
	%orig;
}

%end

%hook SpringBoard

- (void)_menuButtonDown:(CFTypeRef)event
{
	SensibleController *sController = [SensibleController sharedInstance];
	[sController _stopTimerIfLaunched];
	%orig;
}

%end

%hook SBDeviceLockController

-(void)_lockStateChangedFrom:(int)oldLockState to:(int)lockState
{
	%orig;
	SensibleController *sController = [SensibleController sharedInstance];
	if([sController isEnabled]){
		if(lockState == 1){
			[sController startMonitoring];
		}
		if(lockState == 0){
			[sController stopMonitoring];
		}
	}
		
}

%end

%hook SBReachabilityManager

-(BOOL)reachabilityEnabled
{
	SensibleController *sController = [SensibleController sharedInstance];
	if([sController isEnabled]){
		return false;
	}else{
		return %orig;
	}
}

%end

%ctor
{
	%init;
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.tonyciroussel.sensible/reloadSettings"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	loadPrefs();
}
