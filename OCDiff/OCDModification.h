#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, OCDModificationType) {
    OCDModificationTypeDeclaration,
    OCDModificationTypeAvailability,
    OCDModificationTypeDeprecationMessage,
    OCDModificationTypeReplacement,
    OCDModificationTypeSuperclass,
    OCDModificationTypeProtocols,
    OCDModificationTypeOptional,
    OCDModificationTypeHeader,
    OCDModificationTypeMacro
};

typedef NS_ENUM(NSUInteger, OCDSemversion) {
    OCDSemversionPatch = 0,
    OCDSemversionMinor,
    OCDSemversionMajor
};

@interface OCDModification : NSObject

+ (instancetype)modificationWithType:(OCDModificationType)type previousValue:(NSString *)previousValue currentValue:(NSString *)currentValue semversion:(OCDSemversion)semversion;

@property (nonatomic, readonly) OCDModificationType type;
@property (nonatomic, readonly) OCDSemversion semversion;
@property (nonatomic, readonly) NSString *previousValue;
@property (nonatomic, readonly) NSString *currentValue;

+ (NSString *)stringForModificationType:(OCDModificationType)type;
+ (NSString *)stringForSemversion:(OCDSemversion)semversion;

@end
