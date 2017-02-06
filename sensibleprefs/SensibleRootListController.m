#include "SensibleRootListController.h"

@implementation TitleCell
- (id)initWithSpecifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" specifier:specifier];
	if (self) {
		UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:42];
		NSDictionary *titleDict = [NSDictionary dictionaryWithObject: titleFont forKey:NSFontAttributeName];
		NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:@"Sensible\n" attributes:titleDict];
		[titleString addAttribute:NSKernAttributeName value:@(1.5f) range:NSMakeRange(0, [titleString length])];
		[titleString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, [titleString length])];

		NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
		paraStyle.lineSpacing = 8.0f;
		[titleString addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, [titleString length])];

		UIFont *creditFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
		NSString *creditStringLocalized = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/SensiblePrefs.bundle"] localizedStringForKey:@"Crafted by Tony Ciroussel" value:@"Crafted by Tony Ciroussel" table:nil];
		NSDictionary *creditDict = [NSDictionary dictionaryWithObject:creditFont forKey:NSFontAttributeName];
		NSMutableAttributedString *creditString = [[NSMutableAttributedString alloc] initWithString:creditStringLocalized attributes:creditDict];
		[creditString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithWhite: 0.40 alpha:1] range:NSMakeRange(0, creditString.length)];

		[titleString appendAttributedString:creditString];

		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 125)];
		[label setNumberOfLines:0];
		label.attributedText = titleString;
		[label setBackgroundColor:[UIColor clearColor]];
		[label setTextAlignment:NSTextAlignmentCenter];
		[self addSubview:label];
	}
	return self;
}


- (CGFloat)preferredHeightForWidth:(CGFloat)width
{
	return 125.0f;
}
@end

@implementation SensibleRootListController

- (NSArray *)specifiers {
	if (_specifiers == nil) {
			NSMutableArray *specifiers = [[NSMutableArray alloc] init];

			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:Nil target:self set:Nil get:Nil detail:Nil cell:PSGroupCell edit:Nil];
				[specifier setProperty:@"TitleCell" forKey:@"headerCellClass"];
				specifier;
			})];

			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Enabled") target:self set:@selector(setPreferenceValue:specifier:) get:@selector(readPreferenceValue:) detail:Nil cell:PSSwitchCell edit:Nil];
				
				[specifier setProperty:@YES forKey:@"default"];
				[specifier setProperty:@"com.tonyciroussel.sensibleprefs" forKey:@"defaults"];
				[specifier setProperty:@"isEnabled" forKey:@"key"];
				[specifier setProperty:@"com.tonyciroussel.sensible/reloadSettings" forKey:@"PostNotification"];
				specifier;
			})];

			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Options") target:self set:Nil get:Nil detail:Nil cell:PSGroupCell edit:Nil];
				specifier;

			})];

			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Actions")  target:self set:Nil get:Nil detail:NSClassFromString(@"SensibleBehaviorController") cell:PSLinkCell edit:Nil];
				specifier;
			})];

			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Vibrations")  target:self set:Nil get:Nil detail:NSClassFromString(@"SensibleVibrationsController") cell:PSLinkCell edit:Nil];
				specifier;
			})];

			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"About") target:self set:Nil get:Nil detail:Nil cell:PSGroupCell edit:Nil];
				specifier;

			})];
			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Source code") target:self set:NULL get:NULL detail:Nil cell:PSButtonCell edit:Nil];
				[specifier setIdentifier:@"Source_Code"];
				specifier->action = @selector(buttonPressedForSpecifier:);
				//[specifier setProperty:[allIcons objectForKey:bundleID] forKey:@"iconImage"];
				specifier;
			})];
			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Send me a mail") target:self set:NULL get:NULL detail:Nil cell:PSButtonCell edit:Nil];
				[specifier setIdentifier:@"Mail"];
				specifier->action = @selector(buttonPressedForSpecifier:);
				//[specifier setProperty:[allIcons objectForKey:bundleID] forKey:@"iconImage"];
				specifier;
			})];
			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Add my repository") target:self set:NULL get:NULL detail:Nil cell:PSButtonCell edit:Nil];
				[specifier setIdentifier:@"Repo"];
				specifier->action = @selector(buttonPressedForSpecifier:);
				//[specifier setProperty:[allIcons objectForKey:bundleID] forKey:@"iconImage"];
				specifier;
			})];
			[specifiers addObject:({
				PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:LocalizedString(@"Translation")  target:self set:Nil get:Nil detail:NSClassFromString(@"SensibleTranslationController") cell:PSLinkCell edit:Nil];
				specifier;
			})];
			_specifiers = specifiers;
		
	}
	return _specifiers;
}

- (void)buttonPressedForSpecifier:(PSSpecifier *)specifier
{
	NSString *identifier = specifier.identifier;
	if([identifier isEqualToString:@"Source_Code"]){
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/Akebu/Sensible"]];
	}
	else if([identifier isEqualToString:@"Mail"]){
		if ([MFMailComposeViewController canSendMail]){
			MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
			mail.mailComposeDelegate = self;
			[mail setSubject:@"Sensible"];
			[mail setToRecipients:@[@"tony.ciroussel@riseup.net"]];

    			[self presentViewController:mail animated:YES completion:NULL];
		}

	}
	else if([identifier isEqualToString:@"Repo"]){
				UIAlertController * alert = [UIAlertController
			alertControllerWithTitle:@"Sensible"
			message:@"Open with Cydia ?"
			preferredStyle:UIAlertControllerStyleAlert];

		UIAlertAction* yesButton = [UIAlertAction
			actionWithTitle:@"Yes"
			style:UIAlertActionStyleDefault
			handler:^(UIAlertAction * action) {
                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://url/https://cydia.saurik.com/api/share#?source=https://akebu.github.io/cydia/"]];
			}];

		UIAlertAction* noButton = [UIAlertAction
			actionWithTitle:@"No"
			style:UIAlertActionStyleDefault
			handler:nil];

			[alert addAction:yesButton];
			[alert addAction:noButton];

			[self presentViewController:alert animated:YES completion:nil];
	}
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end
