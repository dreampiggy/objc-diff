//
//  OCDJSONReportGenerator.m
//  OCDiff
//
//  Created by 李卓立 on 2019/12/17.
//

#import "OCDJSONReportGenerator.h"

@implementation OCDJSONReportGenerator

- (void)generateReportForAPIReports:(NSArray<OCDAPIReport *> *)reports {
    NSMutableDictionary *root = [NSMutableDictionary dictionary];
    NSMutableDictionary *objcClassNode = [NSMutableDictionary dictionary];
    NSMutableDictionary *cFunctionNode = [NSMutableDictionary dictionary];
    NSMutableDictionary *constantNode = [NSMutableDictionary dictionary];
    root[@"objcClass"] = objcClassNode;
    root[@"cFunction"] = cFunctionNode;
    root[@"constant"] = constantNode;
    for (OCDAPIReport *report in reports) {
        if (report.kind == PLClangCursorKindObjCInstanceMethodDeclaration || report.kind == PLClangCursorKindObjCClassMethodDeclaration || report.kind == PLClangCursorKindObjCPropertyDeclaration) {
            NSString *className = report.className;
            if (!className) {
                // If we can not parse the className, ignore it
                continue;
            }
            NSMutableDictionary *classNode = objcClassNode[className];
            // Class not record
            if (!classNode) {
                classNode = [NSMutableDictionary dictionary];
                objcClassNode[className] = classNode;
            }
            NSMutableDictionary *classMethodsNode = classNode[@"classMethods"];
            if (!classMethodsNode) {
                classMethodsNode = [NSMutableDictionary dictionary];
                classNode[@"classMethods"] = classMethodsNode;
            }
            NSMutableDictionary *instanceMethodsNode = classNode[@"instanceMethods"];
            if (!instanceMethodsNode) {
                instanceMethodsNode = [NSMutableDictionary dictionary];
                classNode[@"instanceMethods"] = instanceMethodsNode;
            }
            NSMutableDictionary *propertiesNode = classNode[@"properties"];
            if (!propertiesNode) {
                propertiesNode = [NSMutableDictionary dictionary];
                classNode[@"properties"] = propertiesNode;
            }
            // Property
            if (report.kind == PLClangCursorKindObjCPropertyDeclaration) {
                NSMutableDictionary *propertyNode = [NSMutableDictionary dictionary];
                propertyNode[@"attributes"] = report.propertyAttributes;
                propertyNode[@"getter"] = report.propertyGetterName;
                propertyNode[@"setter"] = report.propertySetterName;
                propertiesNode[report.name] = propertyNode;
            } else {
                // Method
                NSMutableDictionary *methodNode = [NSMutableDictionary dictionary];
                methodNode[@"arguments"] = report.methodArguments;
                methodNode[@"return"] = report.methodReturnType;
                if (report.kind == PLClangCursorKindObjCInstanceMethodDeclaration) {
                    instanceMethodsNode[report.name] = methodNode;
                } else {
                    classMethodsNode[report.name] = methodNode;
                }
            }
        } else if (report.kind == PLClangCursorKindEnumConstantDeclaration
                   || report.kind == PLClangCursorKindEnumDeclaration
                   || report.kind == PLClangCursorKindTypedefDeclaration
                   || report.kind == PLClangCursorKindVariableDeclaration
                   || report.kind == PLClangCursorKindStructDeclaration
                   || report.kind == PLClangCursorKindFieldDeclaration
                   || report.kind == PLClangCursorKindUnionDeclaration) {
            NSMutableDictionary *constantValueNode = [NSMutableDictionary dictionary];
            constantValueNode[@"type"] = report.type;
            constantNode[report.name] = constantValueNode;
        } else if (report.kind == PLClangCursorKindFunctionDeclaration) {
            NSMutableDictionary *cFunctionValueNode = [NSMutableDictionary dictionary];
            cFunctionValueNode[@"arguments"] = report.methodArguments;
            cFunctionValueNode[@"return"] = report.methodReturnType;
            cFunctionNode[report.name] = cFunctionValueNode;
        }
    }
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:root options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    printf("%s\n", [jsonString UTF8String]);
}

@end
