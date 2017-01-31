#import "SensibleController.h"

%hook SBDeviceLockController

-(void)_lockStateChangedFrom:(int)oldLockState to:(int)lockState
{
	%orig;

	if(lockState == 1){
		[[SensibleController sharedInstance] startMonitoring];
		[[%c(SBUIBiometricEventMonitor) sharedInstance] setFingerDetectEnabled:YES requester:CFSTR("SensibleController")];
	}
	if(lockState == 0){
		[[SensibleController sharedInstance] stopMonitoring];
		[[%c(SBUIBiometricEventMonitor) sharedInstance] setFingerDetectEnabled:NO requester:CFSTR("SensibleController")];
	}
		
}

%end
