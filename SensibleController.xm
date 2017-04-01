#import "SensibleController.h"
#import "libactivator/libactivator.h"
#import "SensibleConst.h"

static SensibleController *sensibleController;

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
	const SpringBoard *springBoard = [%c(SpringBoard) sharedApplication];
	IOHIDEventRef event = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), 12, 48, 1, 0);        
	[springBoard _lockButtonDown:event fromSource:1];    
	CFRelease(event);
	event = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), 12, 48, 0, 0); 
	[springBoard _lockButtonUp:event fromSource:1];    
	CFRelease(event);

}

- (void)simulateHomeButtonDown
{   
	const SpringBoard *springBoard = [%c(SpringBoard) sharedApplication];
	const IOHIDEventRef event = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), 12, 64, 1, 0);    
	[springBoard _menuButtonDown:event];    
	CFRelease(event);
}

- (void)simulateHomeButtonUp
{   
	const SpringBoard *springBoard = [%c(SpringBoard) sharedApplication];
	const IOHIDEventRef event = IOHIDEventCreateKeyboardEvent(kCFAllocatorDefault, mach_absolute_time(), 12, 64, 0, 0);    
	[springBoard _menuButtonUp:event];    
	CFRelease(event);
}

/* Handle Touch on TouchID sensor */

-(void)biometricEventMonitor:(id)monitor handleBiometricEvent:(unsigned)event {

	/* TouchID Finger is DOWN */
	if(event == TouchIDFingerDown){

		[self performSelectorInBackground:@selector(vibrate) withObject:nil];

		[[%c(SBLockScreenManager) sharedInstance] noteMenuButtonDown];

		[[NSNotificationCenter defaultCenter] postNotificationName:@"SBMenuButtonPressedNotification" object:nil];
		if(_optimize){
			const float timeInterval = CACurrentMediaTime() - startTime;
			if((timeInterval <= 0.3) && (timeInterval >= 0.15)){
				const float timeToAdd = timeInterval;
				const float newWaitTime = (_waitTime+timeToAdd)/2;
				_waitTime = newWaitTime;
			}
			startTime = CACurrentMediaTime();
		}
		if((_doubleTouchAction == DoNothingIndex) && (_tripleTouchAction == DoNothingIndex) && (_singleTouchAndHoldAction == DoNothingIndex)){
			[self sendEventFromSource:SingleTouch];
			return;
		}
		else if(numberOfTouch == -1){
			numberOfTouch = 0;
		}
		else if(numberOfTouch == 0){
			[self performSelector:@selector(getActionForHold) withObject:nil afterDelay:1];
		}
		else if(numberOfTouch == 1){
			[touchTimer invalidate], touchTimer = nil;
			if((_tripleTouchAction == DoNothingIndex) && (_singleTouchAndHoldAction == DoNothingIndex)){
				numberOfTouch = 0;
				[self sendEventFromSource:DoubleTouch];
			}
			else if(_singleTouchAndHoldAction != DoNothingIndex){
				[self performSelector:@selector(getActionForHoldingAfterTouch) withObject:nil afterDelay:_waitTime+0.1];
			}
		}
	}

	/* TouchID Finger is UP */
	if(event == TouchIDFingerUp){

		if(numberOfTouch > -1){
			numberOfTouch++;
		
			if(numberOfTouch == 1){
				[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getActionForHold) object:nil];
				touchTimer = [NSTimer scheduledTimerWithTimeInterval:_waitTime target:self selector:@selector(singleTouchTimer:) userInfo:nil repeats:NO];
			}
			else if(numberOfTouch == 2){
				[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getActionForHoldingAfterTouch) object:nil];
				if(_tripleTouchAction == DoNothingIndex){
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

- (void)_stopTimerIfLaunched
{
	numberOfTouch = -1;
	if(touchTimer != nil){
		[touchTimer invalidate], touchTimer = nil;
	}
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getActionForHold) object:nil];
}

- (void)singleTouchTimer:(NSTimer *)timer
{
	[touchTimer invalidate], touchTimer = nil;
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
	const SBUIBiometricEventMonitor* monitor = [[%c(BiometricKit) manager] delegate];
	[monitor addObserver:self];
	[monitor setFingerDetectEnabled:YES requester:CFSTR("SensibleController")];
	numberOfTouch = 0;
}

-(void)stopMonitoring {
	/*  From BioTesting by NoahSaso */
	if(!isMonitoring) {
		return;
	}
	isMonitoring = NO;
	const SBUIBiometricEventMonitor* monitor = [[%c(BiometricKit) manager] delegate];
	[monitor removeObserver:self];

	[monitor setFingerDetectEnabled:NO requester:CFSTR("SensibleController")];
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
	/*
	0 : Home Button
	1 : Multitask
	2 : Sleep
	3 : Siri/VoiceControl
	4 : Reachability
	5 : Screenshot
	6 : Launch last app
	7 : Kill current application
	8 : Do nothing
        9 : Activator (if installed)
	*/
	switch (action){
		case 0:{
			/*  Home button */
			const SBIconController *iconController = [%c(SBIconController) sharedInstance];
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
			/*  Siri / VoiceControl */
			[self simulateHomeButtonDown];
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
				[self simulateHomeButtonUp];
   			});
		break;
		}
		case 4:{
			/*  Reachability */
			const SBReachabilityManager *reachManager = [%c(SBReachabilityManager) sharedInstance];
			if([reachManager reachabilityEnabled]){
				if([reachManager reachabilityModeActive]){
					[reachManager _handleReachabilityDeactivated];
				}else{
					[reachManager _handleReachabilityActivated];
				}
			}
		break;
		}
		case 5:{
			/*  Screenshot */
			[self simulateHomeButtonDown];
			[self simulateLockButton];
			[self simulateHomeButtonUp];
		break;
		}
		case 6:{
			/*  Launch last app */
			[[%c(SBUIController) sharedInstance] programmaticSwitchAppGestureMoveToRight];
		break;
		}
		case 7:{
			/*  Kill current application */
			const SBUIController *uiController = [%c(SBUIController) sharedInstance];
			const NSString *currentBundleID = [[[uiController _switchAppList] list] objectAtIndex:0];
			const BOOL applicationSuspended = [uiController _handleButtonEventToSuspendDisplays:NO displayWasSuspendedOut:NO];
			if(applicationSuspended){
				const SBApplication *app = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:currentBundleID];
				const NSTask *killallTask = [[NSTask alloc] init];
				[killallTask setLaunchPath:@"/bin/bash"];
				const NSString *command = [NSString stringWithFormat:@"/bin/kill %@", [NSString stringWithFormat:@"%i", [app pid]]];
				[killallTask setArguments:@[ @"-c", command]];
				[killallTask launch];
				killallTask = nil;
			}
				
		break;
		}
		case 9:{
			/*  Activator */
			const LAActivator *sharedActivator = [%c(LAActivator) sharedInstance];
			LAEvent *event = [%c(LAEvent) eventWithName:source mode:[sharedActivator currentEventMode]];
			[sharedActivator sendEventToListener:event];
		break;
		}
	}
}

@end

static void loadPrefs() {

	const CFStringRef SensiblePrefs = (__bridge CFStringRef)SensiblePlist;
	const CFStringRef isTweakEnabled = (__bridge CFStringRef)EnableKey;
	const CFStringRef protectCC = (__bridge CFStringRef)ProtectCCKey;
	const CFStringRef optimizeKey = (__bridge CFStringRef)OptimizeKey;
	const CFStringRef waitTimeMS = (__bridge CFStringRef)WaitTimeKey;
	const CFStringRef vibrationIntensity = (__bridge CFStringRef)VibrationIntensityKey;
	const CFStringRef vibrationDuration = (__bridge CFStringRef)VibrationDurationKey;
	const CFStringRef singleTouchList = (__bridge CFStringRef)SingleTouchList;
	const CFStringRef doubleTouchList = (__bridge CFStringRef)DoubleTouchList;
	const CFStringRef tripleTouchList = (__bridge CFStringRef)TripleTouchList;
	const CFStringRef hold = (__bridge CFStringRef)HoldTouchList;
	const CFStringRef singleTouchAndHold = (__bridge CFStringRef)SingleTouchAndHoldList;

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
	int sHoldTouchAction = 3;
	int sSingleTouchAndHoldAction = 2;
	
	CFPreferencesAppSynchronize(SensiblePrefs);

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

	[sensibleController setIsEnabled:isEnabled];
	const SBLockScreenManager *possibleSharedInstance = [%c(SBLockScreenManager) sharedInstanceIfExists];
	if(possibleSharedInstance != nil || [possibleSharedInstance isUILocked] != false){
		if(isEnabled){
			[sensibleController startMonitoring];
		}else{
			[sensibleController stopMonitoring];
		}
	}
	[sensibleController setIntensity:sIntensity];
	[sensibleController setDuration:sDuration];
	[sensibleController setSingleTouchAction:sSingleTouchAction];
	[sensibleController setDoubleTouchAction:sDoubleTouchAction];
	[sensibleController setTripleTouchAction:sTripleTouchAction];
	[sensibleController setHoldTouchAction:sHoldTouchAction];
	[sensibleController setSingleTouchAndHoldAction:sSingleTouchAndHoldAction];
	[sensibleController setProtectCC:sShouldProtectCC];
	[sensibleController setOptimize:sShouldOptimize];
	[sensibleController setWaitTime:sWaitTimeinMs];
}

static void updatePlistIfNecessary() {

	const CFStringRef SensiblePrefs = (__bridge CFStringRef)SensiblePlist;
	const CFStringRef activatorKey = CFSTR("isActivatorInstalled");
	bool activatorWasInstalled = false;

	CFPreferencesAppSynchronize(SensiblePrefs);

	if(CFBridgingRelease(CFPreferencesCopyAppValue(activatorKey, SensiblePrefs))){
		activatorWasInstalled = [(id)CFBridgingRelease(CFPreferencesCopyAppValue(activatorKey, SensiblePrefs)) boolValue];
	}

	if([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libactivator.dylib"]){
		/* Activator is installed */
		CFPreferencesSetValue(activatorKey, kCFBooleanTrue, SensiblePrefs, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
	}else{
		/* Activator isn't installed */
		if(activatorWasInstalled){
			/* Activator was installed before - Need to update the plist */
			const CFArrayRef CFAllKeys = CFPreferencesCopyKeyList(SensiblePrefs, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
			const NSArray *allKeys = (NSArray *)CFBridgingRelease(CFAllKeys);
			for(NSString *key in allKeys){
				const int value = [(id)CFBridgingRelease(CFPreferencesCopyAppValue((__bridge CFStringRef)key, SensiblePrefs)) intValue];
				if(value == DoNothingIndex+1){
					CFPreferencesSetValue((__bridge CFStringRef)key, CFNumberCreate(NULL, kCFNumberIntType, &DoNothingIndex), SensiblePrefs, kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);
				}
			}
		}
		CFPreferencesSetValue(activatorKey, kCFBooleanFalse, SensiblePrefs, kCFPreferencesCurrentUser, kCFPreferencesCurrentUser);
	}
	CFPreferencesAppSynchronize(SensiblePrefs);
}

/* Hooks */

%hook SBControlCenterController

-(void)_showControlCenterGestureBeganWithGestureRecognizer:(id)arg1
{
	if([sensibleController protectCC]){
		[sensibleController _stopTimerIfLaunched];
	}
	%orig;
}

%end

%hook SpringBoard

- (void)_menuButtonDown:(CFTypeRef)event
{
	if([sensibleController isEnabled]){
		[sensibleController _stopTimerIfLaunched];
	}
	%orig;
}

%end

%hook SBDeviceLockController

-(void)_lockStateChangedFrom:(int)oldLockState to:(int)lockState
{
	%orig;
	if([sensibleController isEnabled]){
		if(lockState == 1){
			[sensibleController startMonitoring];
		}
		if(lockState == 0){
			[sensibleController stopMonitoring];
		}
	}
		
}

%end

%hook SBReachabilityTrigger

-(void)biometricEventMonitor:(id)arg1 handleBiometricEvent:(unsigned long long)arg2
{
	if(![sensibleController isEnabled]){
		%orig;
	}
}

%end

%ctor
{
	%init;
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.tonyciroussel.sensible/reloadSettings"), NULL, CFNotificationSuspensionBehaviorCoalesce);
	sensibleController = [SensibleController sharedInstance];
	updatePlistIfNecessary();
	loadPrefs();
}
