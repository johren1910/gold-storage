//
//  ZOPrirorityQueue.m
//  storage2
//
//  Created by LAP14885 on 30/06/2023.
//

#import "ZOPriorityQueue.h"

@interface ZOPriorityQueue ()
@property (nonatomic) ZOHeap * maxHeap;
@end

@implementation ZOPriorityQueue

-(instancetype)init {
    if (self == [super init]) {
        self.maxHeap = [[ZOHeap alloc] init];
    }
    return self;
}

-(void) enqueue:(id) object {
    [_maxHeap insert:object];
    
}
-(id) dequeue {
    return [_maxHeap extractMax];
}

-(void)remove:(id)object {
    [_maxHeap remove:object];
}

@end
