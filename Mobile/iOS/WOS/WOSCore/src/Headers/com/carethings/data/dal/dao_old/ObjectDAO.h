//
// Created by lsuarez on 11/3/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class ResdbResult;


@interface ObjectDAO : NSObject {
}

- (void)transferData:(id)daoObject :(sqlite3_stmt*)sqlRow;
- (id)allocateDaoObject;
- (void)executeStatement:(NSString*)sql withParams:(NSMutableArray*)params andStatement:(sqlite3_stmt**)sqlStatement;
- (ResdbResult*)findSingleRow:(NSString*)sql withParams:(NSMutableArray*)params;
- (ResdbResult*)findMultiRow:(NSString *)sql withParams:(NSMutableArray*)params;
- (ResdbResult*)findCount:(NSString*)sql withParams:(NSMutableArray*)params;
- (ResdbResult*)insertUpdateRow:(NSString*)sql withParams:(NSMutableArray*)params andObject:(id)daoObject;
- (ResdbResult*)deleteRow:(NSString*)sql withParams:(NSMutableArray*)params;

@end