#include "SensibleBehaviorController.h"
#include "SensibleConst.h"
#import <Preferences/PSListItemsController.h>
#import "../libactivator/libactivator.h"

@interface SListItemsController : PSListItemsController
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;
@end

@implementation SListItemsController

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)index
{
	if((long)index.row == kDoNothingIndex+1){
		NSString *sensibleEventName = [[self specifier] identifier];
		LAEventSettingsController *vc = [[NSClassFromString(@"LAEventSettingsController") new] initWithModes:@[@"springboard", @"application"] eventName:sensibleEventName];
		[self.navigationController pushViewController:vc animated:YES];
	}
	[super tableView:table didSelectRowAtIndexPath:index];
}


@end

@implementation SensibleBehaviorController

- (NSArray *)specifiers {
	if (_specifiers == nil) {
		NSMutableArray *specifiers = [[NSMutableArray alloc] init];
		NSMutableArray *validOptions = [[NSMutableArray alloc] init];
		NSMutableArray *Options = [[NSMutableArray alloc] init];

		[Options addObject:LocalizedString(@"Home button")];
		[Options addObject:LocalizedString(@"Multitask")];
		[Options addObject:LocalizedString(@"Sleep")];
		[Options addObject:LocalizedString(@"Siri / VoiceControl")];
		[Options addObject:LocalizedString(@"Reachability")];
		[Options addObject:LocalizedString(@"Screenshot")];
		[Options addObject:LocalizedString(@"Launch last application")];
		[Options addObject:LocalizedString(@"Kill current application")];
		[Options addObject:LocalizedString(@"Do nothing")];
		if([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libactivator.dylib"]){
			[Options addObject:LocalizedString(@"Assign an activator listener")];
		}

		for (int i=0; i<[Options count]; i++){
			[validOptions addObject:[NSString stringWithFormat:@"%i", i]];
		}

		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Custom actions for TouchID") target:self set:Nil get:Nil detail:Nil cell:PSGroupCell edit:Nil];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Single touch") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"SListItemsController") cell:PSLinkListCell edit:Nil];
			[specifier setProperty:@YES forKey:@"enabled"];
			[specifier setProperty:kSingleTouchList forKey:@"key"];
			[specifier setIdentifier:kSingleTouch];
			[specifier setProperty:kSensiblePlist forKey:@"defaults"];
			[specifier setProperty:@"0" forKey:@"default"];
			[specifier setProperty:@"com.tonyciroussel.sensible/reloadSettings" forKey:@"PostNotification"];
			specifier.values = validOptions;
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:Options forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:Options forKeys:specifier.values];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Double touch") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"SListItemsController") cell:PSLinkListCell edit:Nil];
			[specifier setProperty:@YES forKey:@"enabled"];
			[specifier setProperty:kDoubleTouchList forKey:@"key"];
			[specifier setIdentifier:kDoubleTouch];
			[specifier setProperty:kSensiblePlist forKey:@"defaults"];
			[specifier setProperty:@"1" forKey:@"default"];		
			[specifier setProperty:@"com.tonyciroussel.sensible/reloadSettings" forKey:@"PostNotification"];
			specifier.values = validOptions;
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:Options forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:Options forKeys:specifier.values];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Triple touch") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"SListItemsController") cell:PSLinkListCell edit:Nil];
			[specifier setProperty:@YES forKey:@"enabled"];
			[specifier setProperty:kTripleTouchList forKey:@"key"];
			[specifier setIdentifier:kTripleTouch];
			[specifier setProperty:kSensiblePlist forKey:@"defaults"];
			[specifier setProperty:[NSNumber numberWithInt:kDoNothingIndex] forKey:@"default"];
			[specifier setProperty:@"com.tonyciroussel.sensible/reloadSettings" forKey:@"PostNotification"];
			specifier.values = validOptions;
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:Options forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:Options forKeys:specifier.values];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Hold") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"SListItemsController") cell:PSLinkListCell edit:Nil];
			[specifier setProperty:@YES forKey:@"enabled"];
			[specifier setProperty:kHoldTouchList forKey:@"key"];
			[specifier setIdentifier:kHold];
			[specifier setProperty:kSensiblePlist forKey:@"defaults"];
			[specifier setProperty:@"3" forKey:@"default"];	
			[specifier setProperty:@"com.tonyciroussel.sensible/reloadSettings" forKey:@"PostNotification"];
			specifier.values = validOptions;
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:Options forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:Options forKeys:specifier.values];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Single touch and hold") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"SListItemsController") cell:PSLinkListCell edit:Nil];
			[specifier setProperty:@YES forKey:@"enabled"];
			[specifier setProperty:kSingleTouchAndHoldList forKey:@"key"];
			[specifier setIdentifier:kSingleTouchAndHold];
			[specifier setProperty:kSensiblePlist forKey:@"defaults"];
			[specifier setProperty:@"2" forKey:@"default"];
			[specifier setProperty:@"com.tonyciroussel.sensible/reloadSettings" forKey:@"PostNotification"];
			specifier.values = validOptions;
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:Options forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:Options forKeys:specifier.values];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Protect CC") target:self set:Nil get:Nil detail:Nil cell:PSGroupCell edit:Nil];
			[specifier setProperty:LocalizedString(@"Prevent accidentally register a touch when invoking the Control Center") forKey:@"footerText"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Protect CC") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:Nil cell:PSSwitchCell edit:Nil];
			
			[specifier setProperty:@YES forKey:@"default"];
			[specifier setProperty:kSensiblePlist forKey:@"defaults"];
			[specifier setProperty:kProtectCCKey forKey:@"key"];
			[specifier setProperty:@"com.tonyciroussel.sensible/reloadSettings" forKey:@"PostNotification"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Touch wait time (ms)") target:self set:Nil get:Nil detail:Nil cell:PSGroupCell edit:Nil];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Optimize wait time") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:Nil cell:PSSwitchCell edit:Nil];
				
			[specifier setProperty:@YES forKey:@"default"];
			[specifier setProperty:kSensiblePlist forKey:@"defaults"];
			[specifier setProperty:kOptimizeKey forKey:@"key"];
			[specifier setProperty:@"com.tonyciroussel.sensible/reloadSettings" forKey:@"PostNotification"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:nil target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:Nil cell:PSSliderCell edit:Nil];
	
			[specifier setProperty:@0.25 forKey:@"default"];
			[specifier setProperty:@YES forKey:@"showValue"];
			[specifier setProperty:kSensiblePlist forKey:@"defaults"];
			[specifier setProperty:kWaitTimeKey forKey:@"key"];
			[specifier setProperty:@0.10 forKey:@"min"];
			[specifier setProperty:@0.50 forKey:@"max"];
			[specifier setProperty:@YES forKey:@"isSegmented"];
			[specifier setProperty:@8 forKey:@"segmentCount"];
			[specifier setProperty:@"com.tonyciroussel.sensible/reloadSettings" forKey:@"PostNotification"];
			specifier;
		})];
		_specifiers = specifiers;
	}
	return _specifiers;
}

@end
