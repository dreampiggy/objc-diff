#import "OCDModification.h"

@implementation OCDModification

- (instancetype)initWithType:(OCDModificationType)type previousValue:(NSString *)previousValue currentValue:(NSString *)currentValue semversion:(OCDSemversion)semversion {
    if (!(self = [super init]))
        return nil;

    _type = type;
    _semversion = semversion;
    _previousValue = [previousValue copy];
    _currentValue = [currentValue copy];

    return self;
}

+ (instancetype)modificationWithType:(OCDModificationType)type previousValue:(NSString *)previousValue currentValue:(NSString *)currentValue semversion:(OCDSemversion)semversion {
    return [[self alloc] initWithType:type previousValue:previousValue currentValue:currentValue semversion:semversion];
}

+ (NSString *)stringForModificationType:(OCDModificationType)type {
    switch (type) {
        case OCDModificationTypeDeclaration:
            return @"Declaration";

        case OCDModificationTypeAvailability:
            return @"Availability";

        case OCDModificationTypeDeprecationMessage:
            return @"Deprecation Message";

        case OCDModificationTypeReplacement:
            return @"Replacement";

        case OCDModificationTypeSuperclass:
            return @"Superclass";

        case OCDModificationTypeProtocols:
            return @"Protocols";

        case OCDModificationTypeOptional:
            return @"Optional";

        case OCDModificationTypeHeader:
            return @"Header";
            
        case OCDModificationTypeMacro:
            return @"Macro";
    }

    abort();
}

+ (NSString *)stringForSemversion:(OCDSemversion)semversion {
    switch (semversion) {
        case OCDSemversionMajor:
            return @"Major";
        case OCDSemversionMinor:
            return @"Minor";
        case OCDSemversionPatch:
            return @"Patch";
    }
    
    abort();
}

- (NSString *)description {
    NSMutableString *result = [NSMutableString string];
    [result appendString:@"["];
    [result appendString:[OCDModification stringForSemversion:self.semversion]];
    [result appendString:@"]"];
    [result appendString:[OCDModification stringForModificationType:self.type]];
    [result appendString:@": "];
    [result appendString:[self.previousValue length] > 0 ? self.previousValue : @"(none)"];
    [result appendString:@" to "];
    [result appendString:[self.currentValue length] > 0 ? self.currentValue : @"(none)"];
    return result;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[OCDModification class]])
        return NO;

    OCDModification *other = object;

    return
    other.type == self.type &&
    other.semversion == self.semversion &&
    (other.previousValue == self.previousValue || [other.previousValue isEqual:self.previousValue]) &&
    (other.currentValue == self.currentValue || [other.currentValue isEqual:self.currentValue]);
}

- (NSUInteger)hash {
    return self.type ^ self.semversion ^ [self.previousValue hash] ^ [self.currentValue hash];
}

@end
