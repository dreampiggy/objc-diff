#import "OCDifference.h"

@implementation OCDifference

- (instancetype)initWithType:(OCDifferenceType)type name:(NSString *)name path:(NSString *)path lineNumber:(NSUInteger)lineNumber USR:(NSString *)USR modifications:(NSArray *)modifications {
    if (!(self = [super init]))
        return nil;

    _type = type;
    _name = [name copy];
    _path = [path copy];
    _lineNumber = lineNumber;
    _USR = USR;
    _modifications = [modifications copy];

    return self;
}

+ (instancetype)differenceWithType:(OCDifferenceType)type name:(NSString *)name path:(NSString *)path lineNumber:(NSUInteger)lineNumber {
    return [[self alloc] initWithType:type name:name path:path lineNumber:lineNumber USR:nil modifications:nil];
}

+ (instancetype)differenceWithType:(OCDifferenceType)type name:(NSString *)name path:(NSString *)path lineNumber:(NSUInteger)lineNumber USR:(NSString *)USR {
    return [[self alloc] initWithType:type name:name path:path lineNumber:lineNumber USR:USR modifications:nil];
}

+ (instancetype)modificationDifferenceWithName:(NSString *)name path:(NSString *)path lineNumber:(NSUInteger)lineNumber modifications:(NSArray *)modifications {
    return [[self alloc] initWithType:OCDifferenceTypeModification name:name path:path lineNumber:lineNumber USR:nil modifications:modifications];
}

+ (instancetype)modificationDifferenceWithName:(NSString *)name path:(NSString *)path lineNumber:(NSUInteger)lineNumber USR:(NSString *)USR modifications:(NSArray *)modifications {
    return [[self alloc] initWithType:OCDifferenceTypeModification name:name path:path lineNumber:lineNumber USR:USR modifications:modifications];
}

- (OCDSemversion)semversion {
    // See https://semver.org/
    switch (self.type) {
        case OCDifferenceTypeRemoval:
            /**
             Major version X (X.y.z | X > 0) MUST be incremented if any backwards incompatible changes are introduced to the public API.
             */
            return OCDSemversionMajor;
        case OCDifferenceTypeAddition:
            /**
             Minor version Y (x.Y.z | x > 0) MUST be incremented if new, backwards compatible functionality is introduced to the public API
             */
            return OCDSemversionMinor;
        case OCDifferenceTypeModification: {
            /**
             Modification need to check each individual changes
             */
            size_t majorCount = 0;
            size_t minorCount = 0;
            size_t patchCount = 0;
            for (OCDModification *modification in self.modifications) {
                switch (modification.semversion) {
                    case OCDSemversionMajor:
                        majorCount++;
                        break;
                    case OCDSemversionMinor:
                        minorCount++;
                        break;
                    case OCDSemversionPatch:
                        patchCount++;
                        break;
                }
            }
            if (majorCount > 0) {
                return OCDSemversionMajor;
            } else if (minorCount > 0) {
                return OCDSemversionMinor;
            } else if (patchCount > 0) {
                return OCDSemversionPatch;
            } else {
                return OCDSemversionPatch;
            }
        }
    }
    
    abort();
}

- (NSString *)description {
    NSMutableString *result = [NSMutableString stringWithString:@"["];
    switch (self.type) {
        case OCDifferenceTypeAddition:
            [result appendString:@"A"];
            break;
        case OCDifferenceTypeRemoval:
            [result appendString:@"R"];
            break;
        case OCDifferenceTypeModification:
            [result appendString:@"M"];
            break;
    }
    [result appendString:@"] "];
    [result appendString:self.name];

    if (self.path) {
        [result appendFormat:@" %@:%tu", self.path, self.lineNumber];
    }

    if ([self.modifications count]) {
        // TODO
        [result appendString:[self.modifications description]];
    }

    return result;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[OCDifference class]])
        return NO;

    OCDifference *other = object;

    return
    other.type == self.type &&
    (other.name == self.name || [other.name isEqual:self.name]) &&
    (other.path == self.path || [other.path isEqual:self.path]) &&
    other.lineNumber == self.lineNumber &&
    (other.modifications == self.modifications || [other.modifications isEqual:self.modifications]);
}

- (NSUInteger)hash {
    return self.type ^ [self.name hash] ^ [self.path hash] ^ self.lineNumber ^ [self.modifications hash];
}

@end
