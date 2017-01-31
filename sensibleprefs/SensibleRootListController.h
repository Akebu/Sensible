#include "Headers.h"

@interface SensibleRootListController : PSListController <MFMailComposeViewControllerDelegate>
{
}
- (id) specifiers;
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error;
- (void)buttonPressedForSpecifier:(PSSpecifier *)specifier;
@end

@protocol PreferencesTableCustomView
- (id)initWithSpecifier:(PSSpecifier *)specifier;
- (CGFloat)preferredHeightForWidth:(CGFloat)width;
@end

@interface TitleCell : PSTableCell <PreferencesTableCustomView>
{
}
@end

@interface SensibleTranslationController : PSListController
{
}
- (id) specifiers;
@end
