#include "Headers.h"

@interface SensibleBehaviorController : PSListController
{
}
- (id) specifiers;
@end

@interface PSSpecifier (value)
- (id)values;
- (id)setValues:(id)value;
@end
