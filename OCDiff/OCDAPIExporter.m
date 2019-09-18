//
//  OCDAPIExporter.m
//  OCDiff
//
//  Created by lizhuoli on 2019/9/18.
//

#import "OCDAPIExporter.h"
#import "NSString+OCDPathUtilities.h"
#import "PLClangCursor+OCDExtensions.h"

@implementation OCDAPIExporter {
    OCDAPISource *_APISource;
    NSString *_baseDirectory;
}

- (instancetype)initWithAPISource:(OCDAPISource *)APISource {
    self = [super init];
    if (self) {
        _APISource = APISource;
        _baseDirectory = [[APISource.translationUnit.spelling stringByDeletingLastPathComponent] ocd_absolutePath];
    }
    return self;
}

+ (NSArray<OCDAPIReport *> *)reportsWithAPISource:(OCDAPISource *)APISource {
    OCDAPIExporter *exporter = [[self alloc] initWithAPISource:APISource];
    return [exporter reports];
}

- (NSArray<OCDAPIReport *> *)reports {
    NSDictionary *API = [self APIForSource:_APISource];
    NSMutableArray *reports = [NSMutableArray arrayWithCapacity:API.count];
    for (NSString *USR in API) {
        PLClangCursor *cursor = API[USR];
        NSString *relativePath = [cursor.location.path ocd_stringWithPathRelativeToDirectory:_baseDirectory];
        OCDAPIReport *report = [OCDAPIReport reportWithKind:cursor.kind name:[self displayNameForCursor:cursor] path:relativePath lineNumber:cursor.location.lineNumber USR:cursor.USR];
        [reports addObject:report];
    }
    return [reports copy];
}

- (NSDictionary *)APIForSource:(OCDAPISource *)source {
    NSMutableDictionary *api = [NSMutableDictionary dictionary];

    [source.translationUnit.cursor visitChildrenUsingBlock:^PLClangCursorVisitResult(PLClangCursor *cursor) {
        if (source.includeSystemHeaders == NO && cursor.location.isInSystemHeader)
            return PLClangCursorVisitContinue;

        if (cursor.location.path == nil)
            return PLClangCursorVisitContinue;

        if (source.containingPath.length > 0 && [cursor.location.path hasPrefix:source.containingPath] == NO)
            return PLClangCursorVisitContinue;

        if ([self shouldIncludeEntityAtCursor:cursor] == NO) {
            if (cursor.kind == PLClangCursorKindEnumDeclaration) {
                // Enum declarations are excluded, but enum constants are included.
                return PLClangCursorVisitRecurse;
            } else {
                return PLClangCursorVisitContinue;
            }
        }

        // If a category or class extension is extending a class within this
        // module (always the case for a class extension), exclude the category
        // declaration itself but include its childen and register the category
        // against its class. Modifications the category makes to the class
        // (e.g. extending protocol conformance) will then be reported as
        // modifications of the class.
        if (cursor.kind == PLClangCursorKindObjCCategoryDeclaration) {
            PLClangCursor *classCursor = [self classCursorForCategoryAtCursor:cursor];
            classCursor = classCursor ? api[[self keyForCursor:classCursor]] : nil;
            if (classCursor != nil) {
                [classCursor ocd_addCategory:cursor];
                return PLClangCursorVisitRecurse;
            }
        }

        [api setObject:cursor forKey:[self keyForCursor:cursor]];

        switch (cursor.kind) {
            case PLClangCursorKindObjCInterfaceDeclaration:
            case PLClangCursorKindObjCCategoryDeclaration:
            case PLClangCursorKindObjCProtocolDeclaration:
            case PLClangCursorKindEnumDeclaration:
                return PLClangCursorVisitRecurse;
            default:
                break;
        }

        return PLClangCursorVisitContinue;
    }];

    return api;
}

/**
 * Returns a key suitable for identifying the specified cursor across translation units.
 *
 * For declarations that are not externally visible Clang includes location information in the USR if the declaration
 * is not in a system header. This makes the USR an inappropriate key for comparison between two API versions, as
 * moving the declaration to a different file or line number would be detected as a removal and addition. As a result
 * a custom key is generated in place of the USR for these declarations.
 */
- (NSString *)keyForCursor:(PLClangCursor *)cursor {
    NSString *prefix = nil;

    switch (cursor.kind) {
        case PLClangCursorKindEnumConstantDeclaration:
            prefix = @"ocd_E_";
            break;

        case PLClangCursorKindTypedefDeclaration:
            prefix = @"ocd_T_";
            break;

        case PLClangCursorKindMacroDefinition:
            prefix = @"ocd_M_";
            break;

        case PLClangCursorKindFunctionDeclaration:
            prefix = @"ocd_F_";
            break;

        case PLClangCursorKindVariableDeclaration:
            prefix = @"ocd_V_";
            break;

        default:
            break;
    }

    return prefix ? [prefix stringByAppendingString:cursor.spelling] : cursor.USR;
}

- (PLClangCursor *)classCursorForCategoryAtCursor:(PLClangCursor *)categoryCursor {
    __block PLClangCursor *classCursor = nil;
    [categoryCursor visitChildrenUsingBlock:^PLClangCursorVisitResult(PLClangCursor *cursor) {
        if (cursor.kind == PLClangCursorKindObjCClassReference) {
            classCursor = cursor.referencedCursor ?: cursor;
            return PLClangCursorVisitBreak;
        }

        return PLClangCursorVisitContinue;
    }];

    return classCursor;
}

/**
 * Returns a Boolean value indicating whether the entity at the specified cursor should be included in the API.
 */
- (BOOL)shouldIncludeEntityAtCursor:(PLClangCursor *)cursor {
    // Exclude macro as public API for exporter
    if (cursor.isDeclaration && [self shouldIncludeDeclarationAtCursor:cursor]) {
        // Exclude private APIs indicated by name
        if ([cursor.spelling hasPrefix:@"_"]) {
            return NO;
        }

        // Class extensions have an empty spelling but should be included
        if (cursor.kind == PLClangCursorKindObjCCategoryDeclaration) {
            return YES;
        }

        return ([cursor.spelling length] > 0);
    }

    return NO;
}

/**
 * Returns a Boolean value indicating whether the declaration at the specified cursor should be included in the API.
 */
- (BOOL)shouldIncludeDeclarationAtCursor:(PLClangCursor *)cursor {
    if ([self isCanonicalCursor:cursor] == NO) {
        return NO;
    }

    switch (cursor.kind) {
        // Exclude declarations that are typically accessed through an appropriate typedef.
        case PLClangCursorKindStructDeclaration:
        case PLClangCursorKindUnionDeclaration:
        case PLClangCursorKindEnumDeclaration:
            return NO;

        case PLClangCursorKindObjCInstanceVariableDeclaration:
            return NO;

        case PLClangCursorKindTemplateTypeParameter:
            return NO;

        case PLClangCursorKindModuleImportDeclaration:
            return NO;

        default:
            break;
    }

    if (cursor.availability.kind == PLClangAvailabilityKindUnavailable ||
        cursor.availability.kind == PLClangAvailabilityKindInaccessible) {
        return NO;
    }

    return YES;
}

/**
 * Returns a Boolean value indicating whether the specified cursor represents the canonical cursor for a declaration.
 *
 * This works around a Clang bug where a forward declaration of a class or protocol appearing before the actual
 * declaration is incorrectly considered the canonical declaration. Since the actual declaration for these types are
 * the only cursors that will have a cursor kind of Objective-C class or protocol, it is safe to special-case them to
 * always be considered canonical.
 */
- (BOOL)isCanonicalCursor:(PLClangCursor *)cursor {
    switch (cursor.kind) {
        case PLClangCursorKindObjCInterfaceDeclaration:
        case PLClangCursorKindObjCCategoryDeclaration:
        case PLClangCursorKindObjCProtocolDeclaration:
            return YES;
        default:
        {
            BOOL isCanonical = [cursor.canonicalCursor isEqual:cursor];
            if (isCanonical == NO && cursor.kind == PLClangCursorKindFunctionDeclaration) {
                // TODO: Clang has an issue with declarations for functions that exist in its builtin function database
                // (e.g., NSLog, objc_msgSend). The canonical cursor for these functions has an identical source
                // location as the declaration in the file we're parsing, but an extent that covers only the function's
                // name, so libclang does not consider them equal. See if this can be fixed in Clang so we don't need a
                // hack here to include them.
                isCanonical = [cursor.location isEqual:cursor.canonicalCursor.location];
            }

            return isCanonical;
        }
    }
}


- (NSString *)displayNameForObjCParentCursor:(PLClangCursor *)cursor {
    if (cursor.kind == PLClangCursorKindObjCCategoryDeclaration) {
        return [self classCursorForCategoryAtCursor:cursor].spelling;
    }

    return cursor.spelling;
}

- (NSString *)displayNameForCursor:(PLClangCursor *)cursor {
    switch (cursor.kind) {
        case PLClangCursorKindObjCCategoryDeclaration:
            return [NSString stringWithFormat:@"%@ (%@)", [self displayNameForObjCParentCursor:cursor], cursor.spelling];

        case PLClangCursorKindObjCInstanceMethodDeclaration:
            return [NSString stringWithFormat:@"-[%@ %@]", [self displayNameForObjCParentCursor:cursor.semanticParent], cursor.spelling];

        case PLClangCursorKindObjCClassMethodDeclaration:
            return [NSString stringWithFormat:@"+[%@ %@]", [self displayNameForObjCParentCursor:cursor.semanticParent], cursor.spelling];

        case PLClangCursorKindObjCPropertyDeclaration:
            return [NSString stringWithFormat:@"%@.%@", [self displayNameForObjCParentCursor:cursor.semanticParent], cursor.spelling];

        case PLClangCursorKindFunctionDeclaration:
            return [NSString stringWithFormat:@"%@()", cursor.spelling];

        case PLClangCursorKindMacroDefinition:
            return [NSString stringWithFormat:@"#def %@", cursor.spelling];

        default:
            return cursor.displayName;
    }
}

@end
