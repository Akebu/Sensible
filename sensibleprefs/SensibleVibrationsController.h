#include "Headers.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AudioToolbox/AudioServices.h>

@interface SensibleVibrationsController : PSListController
{
}
- (id) specifiers;
- (void)sendVibrationWithValue:(id)value specifier:(PSSpecifier*)specifier;
@end
