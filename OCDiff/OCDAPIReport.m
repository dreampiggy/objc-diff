//
//  OCDAPIReport.m
//  OCDiff
//
//  Created by lizhuoli on 2019/9/18.
//

#import "OCDAPIReport.h"
#import "NSString+OCDPathUtilities.h"

@implementation OCDAPIReport

+ (instancetype)reportWithCursor:(PLClangCursor *)cursor {
    OCDAPIReport *report = [[OCDAPIReport alloc] init];
    report.kind = cursor.kind;
    report.name = cursor.spelling;
    report.type = [cursor.type typeByRemovingOuterNullability].spelling;
    report.path = cursor.location.path;
    report.lineNumber = cursor.location.lineNumber;
    return report;
}

- (NSString *)description {
    NSString *kind = @"Unknown";
    switch (self.kind) {
        case PLClangCursorKindObjCInterfaceDeclaration:
            kind = @"Interface";
            break;
        case PLClangCursorKindObjCProtocolDeclaration:
            kind = @"Protocol";
            break;
        case PLClangCursorKindObjCCategoryDeclaration:
            kind = @"Category";
            break;
        case PLClangCursorKindObjCPropertyDeclaration:
            kind = @"Property";
            break;
        case PLClangCursorKindObjCClassMethodDeclaration:
            kind = @"ClassMethod";
            break;
        case PLClangCursorKindObjCInstanceMethodDeclaration:
            kind = @"InstanceMethod";
            break;
        case PLClangCursorKindVariableDeclaration:
            kind = @"Constant";
            break;
        case PLClangCursorKindEnumDeclaration:
            kind = @"Enum";
            break;
        case PLClangCursorKindEnumConstantDeclaration:
            kind = @"Case";
            break;
        case PLClangCursorKindStructDeclaration:
            kind = @"Struct";
            break;
        case PLClangCursorKindUnionDeclaration:
            kind = @"Union";
            break;
        case PLClangCursorKindFieldDeclaration:
            kind = @"Filed";
            break;
        case PLClangCursorKindTypedefDeclaration:
            kind = @"Typedef";
            break;
        case PLClangCursorKindFunctionDeclaration:
            kind = @"Function";
            break;
        default:
            break;
    }
    if (self.className) {
        return [NSString stringWithFormat:@"ClassName: %@, Name: %@, Kind: %@", self.className, self.name, kind];
    } else {
        return [NSString stringWithFormat:@"Name: %@, Kind: %@", self.name, kind];
    }
}

@end
