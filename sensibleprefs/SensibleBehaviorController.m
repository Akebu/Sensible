#include "SensibleBehaviorController.h"
#include "SensibleConst.h"
#import <Preferences/PSListItemsController.h>
#import <libactivator/libactivator.h>

@interface SListItemsController : PSListItemsController
{
	NSString *listener;
}
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;
@end

@implementation SListItemsController

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)index
{
	if((long)index.row == 3){
		NSString *sensibleEventName = [[self specifier] identifier];
		LAEventSettingsController *vc = [[LAEventSettingsController new] initWithModes:@[@"springboard", @"application"] eventName:sensibleEventName];
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
		NSArray *Options = [NSArray arrayWithObjects:LocalizedString(@"Home button"), LocalizedString(@"Multitask"), LocalizedString(@"Sleep"), LocalizedString(@"Assign an activator action"), LocalizedString(@"Siri / VoiceControl"), LocalizedString(@"Do nothing"), nil];
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
			[specifier setProperty:SingleTouchList forKey:@"key"];
			[specifier setIdentifier:SingleTouch];
			[specifier setProperty:SensiblePlist forKey:@"defaults"];
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
			[specifier setProperty:DoubleTouchList forKey:@"key"];
			[specifier setIdentifier:DoubleTouch];
			[specifier setProperty:SensiblePlist forKey:@"defaults"];
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
			[specifier setProperty:TripleTouchList forKey:@"key"];
			[specifier setIdentifier:TripleTouch];
			[specifier setProperty:SensiblePlist forKey:@"defaults"];
			[specifier setProperty:@"5" forKey:@"default"];
			[specifier setProperty:@"com.tonyciroussel.sensible/reloadSettings" forKey:@"PostNotification"];
			specifier.values = validOptions;
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:Options forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:Options forKeys:specifier.values];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Hold") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"SListItemsController") cell:PSLinkListCell edit:Nil];
			[specifier setProperty:@YES forKey:@"enabled"];
			[specifier setProperty:HoldTouchList forKey:@"key"];
			[specifier setIdentifier:Hold];
			[specifier setProperty:SensiblePlist forKey:@"defaults"];
			[specifier setProperty:@"4" forKey:@"default"];	
			[specifier setProperty:@"com.tonyciroussel.sensible/reloadSettings" forKey:@"PostNotification"];
			specifier.values = validOptions;
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:Options forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:Options forKeys:specifier.values];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Single touch and hold") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"SListItemsController") cell:PSLinkListCell edit:Nil];
			[specifier setProperty:@YES forKey:@"enabled"];
			[specifier setProperty:SingleTouchAndHoldList forKey:@"key"];
			[specifier setIdentifier:SingleTouchAndHold];
			[specifier setProperty:SensiblePlist forKey:@"defaults"];
			[specifier setProperty:@"2" forKey:@"default"];
			[specifier setProperty:@"com.tonyciroussel.sensible/reloadSettings" forKey:@"PostNotification"];
			specifier.values = validOptions;
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:Options forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:Options forKeys:specifier.values];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Protection Control center") target:self set:Nil get:Nil detail:Nil cell:PSGroupCell edit:Nil];
			[specifier setProperty:LocalizedString(@"Prevent accidentally register a touch when invoking the Control Center") forKey:@"footerText"];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Protect CC") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:Nil cell:PSSwitchCell edit:Nil];
			
			[specifier setProperty:@YES forKey:@"default"];
			[specifier setProperty:SensiblePlist forKey:@"defaults"];
			[specifier setProperty:@"ProtectCC" forKey:@"key"];
			[specifier setProperty:@"com.tonyciroussel.sensible/reloadSettings" forKey:@"PostNotification"];
			specifier;
		})];
		_specifiers = specifiers;
	}
	return _specifiers;
}

@end
