//
//  OCDAPIReport.m
//  OCDiff
//
//  Created by lizhuoli on 2019/9/18.
//

#import "OCDAPIReport.h"

@implementation OCDAPIReport

- (instancetype)initWithKind:(PLClangCursorKind)kind name:(NSString *)name path:(NSString *)path lineNumber:(NSUInteger)lineNumber USR:(NSString *)USR {
    self = [super init];
    if (self) {
        _kind = kind;
        _name = name;
        _path = path;
        _lineNumber = lineNumber;
        _USR = USR;
    }
    return self;
}

+ (instancetype)reportWithKind:(PLClangCursorKind)kind name:(NSString *)name path:(NSString *)path lineNumber:(NSUInteger)lineNumber USR:(NSString *)USR {
    OCDAPIReport* report = [[OCDAPIReport alloc] initWithKind:kind name:name path:path lineNumber:lineNumber USR:USR];
    return report;
}

- (NSString *)description {
    NSString *kind = @"Unknown";
    switch (self.kind) {
        case PLClangCursorKindObjCClassMethodDeclaration:
            kind = @"ClassMethod";
            break;
        case PLClangCursorKindObjCInstanceMethodDeclaration:
            kind = @"InstanceMethod";
            break;
        case PLClangCursorKindStructDeclaration:
            kind = @"Struct";
            break;
        case PLClangCursorKindEnumDeclaration:
            kind = @"Enum";
            break;
        case PLClangCursorKindUnionDeclaration:
            kind = @"Union";
            break;
        case PLClangCursorKindFunctionDeclaration:
            kind = @"Function";
            break;
        default:
            break;
    }
    return [NSString stringWithFormat:@"Name: %@, Kind: %@", self.name, kind];
}

@end
