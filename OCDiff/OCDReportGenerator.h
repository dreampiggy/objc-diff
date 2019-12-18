#import <Foundation/Foundation.h>
#import "OCDAPIDifferences.h"
#import "OCDAPIReport.h"

@protocol OCDReportGenerator <NSObject>

- (void)generateReportForDifferences:(OCDAPIDifferences *)differences title:(NSString *)title semversion:(BOOL)semversion;

@end

@protocol OCDAPIReportGenerator <NSObject>

- (void)generateReportForAPIReports:(NSArray<OCDAPIReport *> *)reports;

@end
