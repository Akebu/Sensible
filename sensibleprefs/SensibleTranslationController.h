#include "Headers.h"

@interface SensibleTranslationController : PSListController
{
}
- (id) specifiers;
- (void)openTranslation;
- (id)countryForTranslator:(PSSpecifier *)specifier;
- (NSDictionary *)getTranslators;
@end
