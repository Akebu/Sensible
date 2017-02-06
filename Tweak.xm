#import "SensibleConst.h"
#import "SensibleController.h"

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
