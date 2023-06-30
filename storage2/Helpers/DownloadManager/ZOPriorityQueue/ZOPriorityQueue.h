//
//  ZOPriorityQueue.h
//  storage2
//
//  Created by LAP14885 on 30/06/2023.
//

#import <Foundation/Foundation.h>
#import "ZOHeap.h"

@interface ZOPriorityQueue : NSObject
-(void) enqueue:(id) object;
-(id) dequeue;
-(void)remove:(id)object;
@end

