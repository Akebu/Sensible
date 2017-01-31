#include "SensibleBehaviorController.h"
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
	if((long)index.row == 4){
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
		NSArray *options = [NSArray arrayWithObjects:LocalizedString(@"Home button"), LocalizedString(@"Multitask"), LocalizedString(@"Sleep"), LocalizedString(@"Just vibrate"), LocalizedString(@"Assign an activator action"), LocalizedString(@"Siri / VoiceControl"), LocalizedString(@"Do nothing"), nil];
		NSArray *validOptions = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", nil];

		[specifiers addObject:({
		PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Custom actions for TouchID") target:self set:Nil get:Nil detail:Nil cell:PSGroupCell edit:Nil];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Single touch") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"SListItemsController") cell:PSLinkListCell edit:Nil];
			[specifier setProperty:@YES forKey:@"enabled"];
			[specifier setProperty:@"singlePressList" forKey:@"key"];
			[specifier setIdentifier:@"com.sensible.singletouch"];
			[specifier setProperty:@"com.tonyciroussel.sensibleprefs" forKey:@"defaults"];
			[specifier setProperty:@"0" forKey:@"default"];
			specifier.values = validOptions;
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:options forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:options forKeys:specifier.values];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Double touch") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"SListItemsController") cell:PSLinkListCell edit:Nil];
			[specifier setProperty:@YES forKey:@"enabled"];
			[specifier setProperty:@"DoublePressList" forKey:@"key"];
			[specifier setIdentifier:@"com.sensible.doubletouch"];
			[specifier setProperty:@"com.tonyciroussel.sensibleprefs" forKey:@"defaults"];
			[specifier setProperty:@"1" forKey:@"default"];		
			specifier.values = validOptions;
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:options forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:options forKeys:specifier.values];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Triple touch") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"SListItemsController") cell:PSLinkListCell edit:Nil];
			[specifier setProperty:@YES forKey:@"enabled"];
			[specifier setProperty:@"SinglePressAndHoldList" forKey:@"key"];
			[specifier setIdentifier:@"com.sensible.tripletouch"];
			[specifier setProperty:@"com.tonyciroussel.sensibleprefs" forKey:@"defaults"];
			[specifier setProperty:@"6" forKey:@"default"];	
			specifier.values = validOptions;
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:options forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:options forKeys:specifier.values];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Hold") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"SListItemsController") cell:PSLinkListCell edit:Nil];
			[specifier setProperty:@YES forKey:@"enabled"];
			[specifier setProperty:@"HoldList" forKey:@"key"];
			[specifier setIdentifier:@"com.sensible.singlepressandhold"];
			[specifier setProperty:@"com.tonyciroussel.sensibleprefs" forKey:@"defaults"];
			[specifier setProperty:@"5" forKey:@"default"];	
			specifier.values = validOptions;
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:options forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:options forKeys:specifier.values];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier* specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Single touch and hold") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:NSClassFromString(@"SListItemsController") cell:PSLinkListCell edit:Nil];
			[specifier setProperty:@YES forKey:@"enabled"];
			[specifier setProperty:@"SinglePressAndHoldList" forKey:@"key"];
			[specifier setIdentifier:@"com.sensible.singlepressandhold"];
			[specifier setProperty:@"com.tonyciroussel.sensibleprefs" forKey:@"defaults"];
			[specifier setProperty:@"2" forKey:@"default"];	
			specifier.values = validOptions;
			specifier.titleDictionary = [NSDictionary dictionaryWithObjects:options forKeys:specifier.values];
			specifier.shortTitleDictionary = [NSDictionary dictionaryWithObjects:options forKeys:specifier.values];
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
			[specifier setProperty:@"com.tonyciroussel.sensibleprefs" forKey:@"defaults"];
			[specifier setProperty:@"ProtectCC" forKey:@"key"];
			specifier;
		})];
		_specifiers = specifiers;
	}
	return _specifiers;
}

@end
