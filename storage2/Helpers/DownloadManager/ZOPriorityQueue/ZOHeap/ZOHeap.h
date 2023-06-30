//
//  ZOHeap.h
//  storage2
//
//  Created by LAP14885 on 30/06/2023.
//

#import <Foundation/Foundation.h>

@interface ZOHeap : NSObject

-(id) extractMax;
-(void) insert:(id) data;
-(void) remove:(id) object;

@end
