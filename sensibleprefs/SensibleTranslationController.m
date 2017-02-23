#include "SensibleTranslationController.h"

@implementation SensibleTranslationController : PSListController

- (id)specifiers {
	if(_specifiers == nil){

		NSMutableArray *specifiers = [[NSMutableArray alloc] init];
		NSString *mainBundle = [[self bundle] bundlePath];

		PSSpecifier *specifier = [PSSpecifier groupSpecifierWithName:nil];
		[specifier setProperty:LocalizedString(@"♥") forKey:@"footerText"];
		[specifier setProperty:@"1" forKey:@"footerAlignment"];
		[specifiers addObject:specifier];
		[specifiers addObject:[PSSpecifier groupSpecifierWithName:nil]];
		NSDictionary *translators = [self getTranslators];
		for(NSString *translator in translators){
			NSString *country = [translators objectForKey:translator];
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:country target:self set:NULL get:@selector(countryForTranslator:) detail:Nil cell:PSTitleValueCell edit:Nil];
			[specifier setIdentifier:translator];
			[specifiers addObject:specifier];
		}
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"About translation") target:self set:Nil get:Nil detail:Nil cell:PSGroupCell edit:Nil];
			specifier;
		})];
		[specifiers addObject:({
			PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Help me to translate") target:self set:NULL get:NULL detail:Nil cell:PSButtonCell edit:Nil];
			[specifier setIdentifier:@"Repo"];
			specifier->action = @selector(openTranslation);
			UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/Translate.png", mainBundle]];
			[specifier setProperty:image forKey:@"iconImage"];
			specifier;
		})];
		_specifiers = specifiers;
	}
	return _specifiers;
}

- (void)openTranslation
{
	NSString *filza = @"filza://";
	NSString *iFile = @"iFile://";
	NSString *path = @"/Library/PreferenceBundles/SensiblePrefs.bundle/TranslateMe!/Localizable.strings";
	BOOL canOpenFilza = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:filza]];
	BOOL canOpeniFile = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:iFile]];
	if(canOpenFilza){
		NSString *pathForFilza = [NSString stringWithFormat:@"%@%@", filza, path];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:pathForFilza]];
		return;
	}
	else if(canOpeniFile){
		NSString *pathForiFile = [NSString stringWithFormat:@"%@%@", iFile, path];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:pathForiFile]];
		return;
	}
	else
	{
		UIAlertController * alert = [UIAlertController
			alertControllerWithTitle:@"Sensible"
			message:LocalizedString(@"It seems that you have neither iFile nor Filza. It's simpler to translate from these applications, however you can also navigate into the PreferenceBundle and grab Localizable.strings\nOnce finished you can send me the file by email :)")
			preferredStyle:UIAlertControllerStyleAlert];

			UIAlertAction* yesButton = [UIAlertAction
				actionWithTitle:@"Ok"
				style:UIAlertActionStyleDefault
				handler:nil];

			[alert addAction:yesButton];
			[self presentViewController:alert animated:YES completion:nil];
	}
	
}

- (id)countryForTranslator:(PSSpecifier *)specifier
{
	return specifier.identifier;
}

- (NSDictionary *)getTranslators
{
	    return @{	
			@"Sarah Mathan": @"English",
			@"Tony Ciroussel ": @"Français",
			@"Eng-mohammed Alhajaji" : @"العربية"
		    };
}


@end
