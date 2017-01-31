#include "Headers.h"

@interface SensibleTranslationController : PSListController <MFMailComposeViewControllerDelegate>
{
}
- (id) specifiers;
- (void)sendMailToTranslate;
- (id)countryForTranslator:(PSSpecifier *)specifier;
- (NSDictionary *)getTranslators;
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error;
@end
