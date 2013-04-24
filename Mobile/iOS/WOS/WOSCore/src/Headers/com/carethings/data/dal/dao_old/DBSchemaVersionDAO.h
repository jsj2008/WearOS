//
//  Created by lsuarez on 2/7/12.
//
// To change the template use AppCode | Preferences | File Templates.
//

#import <sqlite3.h>
#import "DBSchemaVersion.h"

@class ResdbResult;

@interface DBSchemaVersionDAO : NSObject {
}

- (ResdbResult *)retrieve;
- (ResdbResult *)insert:(NSString *)version;
- (ResdbResult *)update:(NSString *)version;

@end