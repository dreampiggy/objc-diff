//
//  OCDAPIExporter.h
//  OCDiff
//
//  Created by lizhuoli on 2019/9/18.
//

#import <Foundation/Foundation.h>
#import "OCDAPIReport.h"
#import "OCDAPISource.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCDAPIExporter : NSObject

+ (NSArray<OCDAPIReport *> *)reportsWithAPISource:(OCDAPISource *)APISource;

@end

NS_ASSUME_NONNULL_END
