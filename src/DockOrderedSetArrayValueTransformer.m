#import "DockOrderedSetArrayValueTransformer.h"

@implementation DockOrderedSetArrayValueTransformer

+(Class)transformedValueClass
{
    return [NSArray class];
}

+(BOOL)allowsReverseTransformation
{
    return YES;
}

-(id)transformedValue:(id)value
{
    return [(NSOrderedSet*)value array];
}

-(id)reverseTransformedValue:(id)value
{
    return [NSOrderedSet orderedSetWithArray: value];
}

@end
