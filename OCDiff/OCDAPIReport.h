//
//  OCDAPIReport.h
//  OCDiff
//
//  Created by lizhuoli on 2019/9/18.
//

#import <Foundation/Foundation.h>
#import <ObjectDoc/ObjectDoc.h>

@interface OCDAPIReport : NSObject

@property (nonatomic, readwrite) PLClangCursorKind kind;
@property (nonatomic, readwrite) NSString *name;
@property (nonatomic, readwrite) NSString *type;
@property (nonatomic, readwrite) NSString *className;
@property (nonatomic, readwrite) NSArray<NSString *> *propertyAttributes;
@property (nonatomic, readwrite) NSString *propertyGetterName;
@property (nonatomic, readwrite) NSString *propertySetterName;
@property (nonatomic, readwrite) NSArray<NSString *> *methodArguments;
@property (nonatomic, readwrite) NSString *methodReturnType;
@property (nonatomic, readwrite) NSString *path;
@property (nonatomic, readwrite) NSUInteger lineNumber;

+ (instancetype)reportWithCursor:(PLClangCursor *)cursor;

@end
