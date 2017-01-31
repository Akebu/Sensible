#include "SensibleTranslationController.h"

@implementation SensibleTranslationController : PSListController

- (id)specifiers {
	if(_specifiers == nil){

		NSMutableArray *specifiers = [[NSMutableArray alloc] init];

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
			specifier->action = @selector(sendMailToTranslate);
			//[specifier setProperty:[allIcons objectForKey:bundleID] forKey:@"iconImage"];
			specifier;
		})];
		_specifiers = specifiers;
	}
	return _specifiers;
}

- (void)sendMailToTranslate
{
	if ([MFMailComposeViewController canSendMail]){
		MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
		mail.mailComposeDelegate = self;
		[mail setSubject:@"Sensible translations"];
		[mail setToRecipients:@[@"tony.ciroussel@riseup.net"]];

   		[self presentViewController:mail animated:YES completion:NULL];
	}
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}


- (id)countryForTranslator:(PSSpecifier *)specifier
{
	return specifier.identifier;
}

- (NSDictionary *)getTranslators
{
	    return @{	
			@"Sarah Mathan": @"English",
			@"Tony Ciroussel ": @"Français"
		    };
}


@end
