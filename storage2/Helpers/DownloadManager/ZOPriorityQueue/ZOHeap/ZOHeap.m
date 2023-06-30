//
//  ZOHeap.m
//  storage2
//
//  Created by LAP14885 on 30/06/2023.
//

#import "ZOHeap.h"

@interface ZOHeap ()
@property (nonatomic) NSMutableArray* arr;
-(void) insertHelper:(int) index;
-(void) maxHeapify:(int) index;
@end

@implementation ZOHeap

-(instancetype)init {
    if (self == [super init]) {
        self.arr = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) insertHelper:(int) index {
    int parent = (index-1)/2;
    if (parent < 0)
        return;
    if([_arr[parent] compare:_arr[index]] == NSOrderedAscending) {
        id tmp = _arr[parent];
        _arr[parent] = _arr[index];
        _arr[index] = tmp;
        
        [self insertHelper:parent];
    }
}

-(void) maxHeapify:(int) index;
{
    int left = index * 2 + 1;
    int right = index * 2 + 2;
    int max = index;
 
    
    if (left >= _arr.count || left < 0)
        left = -1;
    if (right >= _arr.count || right < 0)
        right = -1;
 
 
    if (left != -1 && [_arr[left] compare:_arr[max]] == NSOrderedDescending)
        max = left;
    if (right != -1 && [_arr[right] compare:_arr[max]] == NSOrderedDescending)
        max = right;
 
    // Swapping the nodes
    if (max != index) {
        id temp = _arr[max];
        _arr[max] = _arr[index];
        _arr[index] = temp;
 
        // recursively calling for their child elements
        // to maintain max heap
        [self maxHeapify:max];
    }
}

-(id) extractMax
{
    id maxItem = nil;
    if (_arr.count == 0) {
        return maxItem;
    }
 
    maxItem = _arr[0];
 
    // Replace the deleted node with the last node
    _arr[0] = _arr[_arr.count - 1];
    [_arr removeLastObject];
 
    [self maxHeapify:0];
    return maxItem;
}

-(void) insert:(id) data {
    [_arr addObject:data];
    [self insertHelper:_arr.count-1];
}

-(void) remove:(id) object {
    if (_arr.count == 0) {
        return;
    }
    int index = -1;
    for (int i = 0; i<_arr.count; i++) {
        if ([_arr[i] isEqual:object]) {
            index = i;
            break;
        }
    }
    
    if(index==-1){
        return;
    }
    
    // Swap with last node
    [_arr replaceObjectAtIndex:index withObject:_arr[_arr.count-1]];
    
    // Remove last node
    [_arr removeLastObject];
    
    // Heapifying
    [self maxHeapify:index];
}

@end

