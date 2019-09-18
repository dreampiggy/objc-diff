//
//  OCDAPIReport.h
//  OCDiff
//
//  Created by lizhuoli on 2019/9/18.
//

#import <Foundation/Foundation.h>
#import <ObjectDoc/ObjectDoc.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCDAPIReport : NSObject

@property (nonatomic, readonly) PLClangCursorKind kind;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) NSUInteger lineNumber;
@property (nonatomic, readonly) NSString *USR;

+ (instancetype)reportWithKind:(PLClangCursorKind)kind name:(NSString *)name path:(NSString *)path lineNumber:(NSUInteger)lineNumber USR:(NSString *)USR;

@end

NS_ASSUME_NONNULL_END
